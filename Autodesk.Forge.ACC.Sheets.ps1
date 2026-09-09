#   "Autodesk Forge PowerShell Cmdlets - ACC Sheets API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")


# ACC Sheets API _________________________________________________________________________________________________
# Note: the ACC Sheets API (v1) addresses projects by their raw id (without the "b." prefix), just like the ACC
# Admin / Issues / RFIs / Submittals APIs. Use ConvertTo-B360Id on $Project.id when building request URIs.


# ACC Sheets API - Sheets ________________________________________________________________________________________

function Get-Sheets
{
    <#
    .SYNOPSIS
    Get all (published) Sheets in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-sheets-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ( (-not $Project.sheets) -or ($Force) )
    {
        $Sheets = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        # ACC Sheets API can only retrieve a limited number of sheets at a time. Batch to get all sheets at once.
        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/sheets?limit=100&offset=$offset"
                Method = "GET"
                Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
            }
            $response = Invoke-RestMethod @request
            # cache request,response pair for debugging
            $null = $Global:RequestResponseHistory.Add(@{
                function = $MyInvocation.MyCommand.Name
                request = $request
                response = $response
            })

            $response.results | foreach { $null = $Sheets.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Sheets.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Sheets = $Project.sheets
    }

    if ($null -ne $Sheets)
    {
        $Sheets | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'project' -NotePropertyValue $Project -Force
        }

        $Project | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'sheets' -NotePropertyValue $Sheets -Force
        }

        return $Sheets
    }
    else
    {
        throw "Sheets not found."
    }
}


function SheetCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Sheets, keyed on number with the title as a comment.
    #>

    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # pull params out of $FakeBoundParameters for shorter reference
    if ($FakeBoundParameters.Hub) {$Hub = $FakeBoundParameters.Hub}
    if ($FakeBoundParameters.Project) {$Project = $FakeBoundParameters.Project}
    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ContainsKey('ThreeLegged')) {$ThreeLegged = [Bool]$FakeBoundParameters.ThreeLegged} else {$ThreeLegged = $Global:ForgeThreeLeggedByDefault}
    if ($FakeBoundParameters.ContainsKey('TwoLegged')) {$TwoLegged = [Bool]$FakeBoundParameters.TwoLegged} else {$TwoLegged = $false}

    # Never start an interactive sign-in from tab-completion: New-AccessToken3Legged opens a
    # browser and then blocks on its callback listener, which would freeze the prompt.
    if (-not (Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -NonInteractive))
    {
        return '<#  Not signed in -- run Connect-Forge first  #>'
    }

    if (-not $FakeBoundParameters.Project)
    {
        $Completions = @('<#  !!! Provide $Project parameter value first !!!  #>')
    }
    else
    {
        # coerce tab-completed args from strings to objects
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $Hub = $Project.hub

        $Sheets = Get-Sheets -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $SheetDict = @{}
        $Sheets | foreach { $null = $SheetDict["$($_.number)"] = "$($_.title)" }

        $completer_args = @{
            CommentsDict = $SheetDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on number, show title as comment
        $Completions = CommentedCompleterFromKeys @completer_args

        if ($Completions.Count -eq 0)
        {
            $Completions = @('<#  No matching Sheets found. Check spelling or -Force to reload.  #>')
        }
    }

    $Completions | foreach {$_}
}


function ConvertTo-Sheet
{
    <#
    .SYNOPSIS
    Coerce $Sheet to a Sheet object from (tab-completed) [String] (matched on number, id, or title).
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        [AllowNull()]
        $Hub,

        [Parameter()]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        [AllowNull()]
        $Project,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ SheetCompleter @args })]
        [AllowNull()]
        $Sheet,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    if ($null -eq $Sheet)
    {
        return $null
    }
    elseif (($Sheet -is [PSCustomObject]) -and ($null -ne $Sheet.id))
    {
        return $Sheet
    }
    elseif (($Sheet -is [String]) -or ($Sheet -is [Int]))
    {
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $Hub = $Project.hub

        $Sheet = Get-Sheets -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged |
        where { ("$($_.number)" -eq "$Sheet") -or ($_.id -eq $Sheet) -or ($_.title -eq $Sheet) } |
        select -First 1

        return $Sheet
    }
    else
    {
        throw "`$Sheet is unexpected type."
    }
}


function Get-Sheet
{
    <#
    .SYNOPSIS
    Get one Sheet from a Project, by number, id, or title.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ SheetCompleter @args })]
        $Sheet,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $Sheet = ConvertTo-Sheet -Hub $Hub -Project $Project -Sheet $Sheet -Force:$Force -ThreeLegged:$ThreeLegged

    return $Sheet
}


function Get-SheetsByIds
{
    <#
    .SYNOPSIS
    Get specific Sheets by their ids (POST .../sheets:batch-get).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-sheets-batch-get-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]
        $Ids,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $Body = @{ ids = $Ids }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/sheets:batch-get"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body -Depth 8
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    if ($null -ne $response.results) {return $response.results} else {return $response}
}


function Set-Sheets
{
    <#
    .SYNOPSIS
    Update one or more Sheets (POST .../sheets:batch-update). Applies the same updates to every id.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-sheets-batch-update-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]
        $Ids,

        [Parameter()]
        $Number,

        [Parameter()]
        $Title,

        [Parameter()]
        [Object[]]
        $AddTags,

        [Parameter()]
        [Object[]]
        $RemoveTags,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Updates = @{}
    if ($PSBoundParameters.ContainsKey('Number'))     {$Updates['number']     = $Number}
    if ($PSBoundParameters.ContainsKey('Title'))      {$Updates['title']      = $Title}
    if ($PSBoundParameters.ContainsKey('AddTags'))    {$Updates['addTags']    = $AddTags}
    if ($PSBoundParameters.ContainsKey('RemoveTags')) {$Updates['removeTags'] = $RemoveTags}

    $Body = @{
        ids = $Ids
        updates = $Updates
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/sheets:batch-update"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body -Depth 8
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    # Force update $Project.sheets
    $null = Get-Sheets -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


function Remove-Sheets
{
    <#
    .SYNOPSIS
    Delete one or more Sheets (POST .../sheets:batch-delete).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-sheets-batch-delete-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]
        $Ids,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{ ids = $Ids }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/sheets:batch-delete"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body -Depth 8
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    # Force update $Project.sheets
    $null = Get-Sheets -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


function Restore-Sheets
{
    <#
    .SYNOPSIS
    Restore one or more previously-deleted Sheets (POST .../sheets:batch-restore).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-sheets-batch-restore-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]
        $Ids,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{ ids = $Ids }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/sheets:batch-restore"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body -Depth 8
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    # Force update $Project.sheets
    $null = Get-Sheets -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


# ACC Sheets API - Version Sets __________________________________________________________________________________

function Get-VersionSets
{
    <#
    .SYNOPSIS
    Get the Sheet version sets of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-version-sets-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ( (-not $Project.version_sets) -or ($Force) )
    {
        $VersionSets = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/version-sets?limit=100&offset=$offset"
                Method = "GET"
                Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
            }
            $response = Invoke-RestMethod @request
            # cache request,response pair for debugging
            $null = $Global:RequestResponseHistory.Add(@{
                function = $MyInvocation.MyCommand.Name
                request = $request
                response = $response
            })

            $response.results | foreach { $null = $VersionSets.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($VersionSets.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $VersionSets = $Project.version_sets
    }

    if ($null -ne $VersionSets)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'version_sets' -NotePropertyValue $VersionSets -Force
        return $VersionSets
    }
    else
    {
        throw "Version sets not found."
    }
}


function VersionSetCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Sheet version sets, keyed on id with "name (issuanceDate)" as a comment.
    #>

    param
    (
        [string]
        $CommandName,

        [string]
        $ParameterName,

        [string]
        $WordToComplete,

        [System.Management.Automation.Language.CommandAst]
        $CommandAst,

        [System.Collections.IDictionary]
        $FakeBoundParameters
    )

    # pull params out of $FakeBoundParameters for shorter reference
    if ($FakeBoundParameters.Hub) {$Hub = $FakeBoundParameters.Hub}
    if ($FakeBoundParameters.Project) {$Project = $FakeBoundParameters.Project}
    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ContainsKey('ThreeLegged')) {$ThreeLegged = [Bool]$FakeBoundParameters.ThreeLegged} else {$ThreeLegged = $Global:ForgeThreeLeggedByDefault}
    if ($FakeBoundParameters.ContainsKey('TwoLegged')) {$TwoLegged = [Bool]$FakeBoundParameters.TwoLegged} else {$TwoLegged = $false}

    # Never start an interactive sign-in from tab-completion: New-AccessToken3Legged opens a
    # browser and then blocks on its callback listener, which would freeze the prompt.
    if (-not (Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -NonInteractive))
    {
        return '<#  Not signed in -- run Connect-Forge first  #>'
    }

    if (-not $FakeBoundParameters.Project)
    {
        $Completions = @('<#  !!! Provide $Project parameter value first !!!  #>')
    }
    else
    {
        # coerce tab-completed args from strings to objects
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $Hub = $Project.hub

        $VersionSets = Get-VersionSets -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $VersionSetDict = @{}
        $VersionSets | foreach { $null = $VersionSetDict["$($_.id)"] = "$($_.name) ($($_.issuanceDate))" }

        $completer_args = @{
            CommentsDict = $VersionSetDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on "name (issuanceDate)", show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


function New-VersionSet
{
    <#
    .SYNOPSIS
    Create a new Sheet version set in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-version-sets-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory)]
        $Name,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $IssuanceDate,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{
        name = $Name
        issuanceDate = $IssuanceDate
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/version-sets"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    # Force update $Project.version_sets
    $null = Get-VersionSets -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


function Set-VersionSet
{
    <#
    .SYNOPSIS
    Update a Sheet version set in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-version-sets-versionSetId-PATCH/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ VersionSetCompleter @args })]
        $VersionSetId,

        [Parameter()]
        $Name,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $IssuanceDate,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    # only send fields the caller provided
    $Body = @{}
    if ($PSBoundParameters.ContainsKey('Name'))         {$Body['name']         = $Name}
    if ($PSBoundParameters.ContainsKey('IssuanceDate')) {$Body['issuanceDate'] = $IssuanceDate}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/version-sets/$VersionSetId"
        Method = "PATCH"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    # Force update $Project.version_sets
    $null = Get-VersionSets -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


function Remove-VersionSets
{
    <#
    .SYNOPSIS
    Delete one or more Sheet version sets (POST .../version-sets:batch-delete).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-version-sets-batch-delete-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]
        $Ids,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{ ids = $Ids }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/version-sets:batch-delete"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body -Depth 8
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    # Force update $Project.version_sets
    $null = Get-VersionSets -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


# ACC Sheets API - Collections ___________________________________________________________________________________

function Get-SheetCollections
{
    <#
    .SYNOPSIS
    Get the Sheet collections of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-collections-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/collections"
        Method = "GET"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
    }
    $response = Invoke-RestMethod @request
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    if ($null -ne $response.results) {return $response.results} else {return $response}
}


function Get-SheetCollection
{
    <#
    .SYNOPSIS
    Get one Sheet collection by exact id.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-collections-collectionId-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory)]
        $CollectionId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/collections/$CollectionId"
        Method = "GET"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
    }
    $response = Invoke-RestMethod @request
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    return $response
}


# ACC Sheets API - Exports _______________________________________________________________________________________

function New-SheetExport
{
    <#
    .SYNOPSIS
    Create an export job for one or more Sheets. Poll Get-SheetExport for the result/download link.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-exports-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        # Array of sheet ids to export
        [Parameter(Mandatory,ValueFromPipeline)]
        [Object[]]
        $Sheets,

        [Parameter()]
        $OutputFileName,

        # Optional full options hashtable (overrides -OutputFileName). See API docs for shape.
        [Parameter()]
        [Hashtable]
        $Options,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    if (-not $Options)
    {
        $Options = @{}
        if ($OutputFileName) {$Options['outputFileName'] = $OutputFileName}
    }

    $Body = @{
        sheets = $Sheets
        options = $Options
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/exports"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body -Depth 8
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $Body
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    return $response
}


function Get-SheetExport
{
    <#
    .SYNOPSIS
    Get the result of a Sheet export job (poll until status is complete; includes the download link).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/sheets-exports-exportId-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        $ExportId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    # export id may be an object (from New-SheetExport) or a raw id string
    if ($ExportId -is [PSCustomObject]) {$ExportId = $ExportId.id}
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/sheets/v1/projects/$ProjectId/exports/$ExportId"
        Method = "GET"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
    }
    $response = Invoke-RestMethod @request
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    return $response
}
