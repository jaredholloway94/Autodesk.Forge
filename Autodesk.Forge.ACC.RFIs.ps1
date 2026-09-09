#   "Autodesk Forge PowerShell Cmdlets - ACC RFIs API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")


# ACC RFIs API ___________________________________________________________________________________________________
# Note: the ACC RFIs API (v3) addresses projects by their raw id (without the "b." prefix), just like the ACC
# Admin and Issues APIs. Use ConvertTo-B360Id on $Project.id when building request URIs. Listing RFIs is done via
# POST .../search:rfis (not a plain GET).


# ACC RFIs API - RFIs ____________________________________________________________________________________________

function Get-RFIs
{
    <#
    .SYNOPSIS
    Get all RFIs in a Project (via POST .../search:rfis).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-rfi-search-POST/
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

    if ( (-not $Project.rfis) -or ($Force) )
    {
        $RFIs = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        # ACC RFIs API can only retrieve a limited number of RFIs at a time. Batch to get all RFIs at once.
        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/search:rfis?limit=100&offset=$offset"
                Method = "POST"
                Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
                Body = '{}'
                ContentType = 'application/json'
            }
            $response = Invoke-RestMethod @request
            # cache request,response pair for debugging
            $null = $Global:RequestResponseHistory.Add(@{
                function = $MyInvocation.MyCommand.Name
                request = $request
                response = $response
            })

            $response.results | foreach { $null = $RFIs.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($RFIs.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $RFIs = $Project.rfis
    }

    if ($null -ne $RFIs)
    {
        $RFIs | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'project' -NotePropertyValue $Project -Force
        }

        $Project | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'rfis' -NotePropertyValue $RFIs -Force
        }

        return $RFIs
    }
    else
    {
        throw "RFIs not found."
    }
}


function RFICompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for RFIs, keyed on customIdentifier with the title as a comment.
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

        $RFIs = Get-RFIs -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $RFIDict = @{}
        $RFIs | foreach { $null = $RFIDict["$($_.customIdentifier)"] = "$($_.title)" }

        $completer_args = @{
            CommentsDict = $RFIDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on customIdentifier, show title as comment
        $Completions = CommentedCompleterFromKeys @completer_args

        if ($Completions.Count -eq 0)
        {
            $Completions = @('<#  No matching RFIs found. Check spelling or -Force to reload.  #>')
        }
    }

    $Completions | foreach {$_}
}


function ConvertTo-RFI
{
    <#
    .SYNOPSIS
    Coerce $RFI to [RFI] from (tab-completed) [String] (matched on customIdentifier, id, or title).
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
        [ArgumentCompleter({ RFICompleter @args })]
        [AllowNull()]
        $RFI,

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

    if ($null -eq $RFI)
    {
        return $null
    }
    elseif (($RFI -is [PSCustomObject]) -and ($null -ne $RFI.id))
    {
        return $RFI
    }
    elseif (($RFI -is [String]) -or ($RFI -is [Int]))
    {
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $Hub = $Project.hub

        $RFI = Get-RFIs -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged |
        where { ("$($_.customIdentifier)" -eq "$RFI") -or ($_.id -eq $RFI) -or ($_.title -eq $RFI) } |
        select -First 1

        return $RFI
    }
    else
    {
        throw "`$RFI is unexpected type."
    }
}


function Get-RFI
{
    <#
    .SYNOPSIS
    Get one RFI from a Project, by customIdentifier, id, or title.
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
        [ArgumentCompleter({ RFICompleter @args })]
        $RFI,

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

    $RFI = ConvertTo-RFI -Hub $Hub -Project $Project -RFI $RFI -Force:$Force -ThreeLegged:$ThreeLegged

    return $RFI
}


function Get-RFIFromAPI
{
    <#
    .SYNOPSIS
    Get one RFI by exact id, directly from the API.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-v2-rfis-rfiId-GET/
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
        $RFIId,

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
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis/$RFIId"
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


function New-RFI
{
    <#
    .SYNOPSIS
    Create a new RFI in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-v2-rfis-POST/
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
        $Title,

        # id of the RFI type (get from Get-RFITypes)
        [Parameter(Mandatory)]
        [ArgumentCompleter({ RFITypeCompleter @args })]
        $RFITypeId,

        [Parameter()]
        [ArgumentCompleter({ RFIStatusCompleter @args })]
        $Status = 'draft',

        [Parameter()]
        $Question,

        [Parameter()]
        $SuggestedAnswer,

        [Parameter()]
        $DueDate,

        [Parameter()]
        $CustomIdentifier,

        # Autodesk id of the assignee (used with -AssignedToType)
        [Parameter()]
        $AssignedToId,

        [Parameter()]
        [ArgumentCompleter({ RFIAssignedToTypeCompleter @args })]
        $AssignedToType,

        # Array of custom attribute hashtables: @{ id = '<attr id>'; values = @('...') }
        [Parameter()]
        [Object[]]
        $CustomAttributes,

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
        title = $Title
        rfiTypeId = $RFITypeId
    }

    # optional parameters
    if ($Status)           {$Body['status']           = $Status}
    if ($Question)         {$Body['question']         = $Question}
    if ($SuggestedAnswer)  {$Body['suggestedAnswer']  = $SuggestedAnswer}
    if ($DueDate)          {$Body['dueDate']          = $DueDate}
    if ($CustomIdentifier) {$Body['customIdentifier'] = $CustomIdentifier}
    if ($CustomAttributes) {$Body['customAttributes'] = $CustomAttributes}
    if ($AssignedToId)     {$Body['assignedTo']       = @( @{ id = $AssignedToId; type = $AssignedToType } )}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis"
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

    $RFI = $response

    # Force update $Project.rfis
    $null = Get-RFIs -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $RFI
}


function Set-RFI
{
    <#
    .SYNOPSIS
    Update an existing RFI in a Project (also used to transition RFI workflow status).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-v2-rfis-rfiId-PATCH/
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
        [ArgumentCompleter({ RFICompleter @args })]
        $RFI,

        [Parameter()]
        $Title,

        [Parameter()]
        $Question,

        [Parameter()]
        $SuggestedAnswer,

        [Parameter()]
        [ArgumentCompleter({ RFIStatusCompleter @args })]
        $Status,

        [Parameter()]
        $DueDate,

        # Autodesk id of the assignee (used with -AssignedToType)
        [Parameter()]
        $AssignedToId,

        [Parameter()]
        [ArgumentCompleter({ RFIAssignedToTypeCompleter @args })]
        $AssignedToType,

        [Parameter()]
        [Object[]]
        $CustomAttributes,

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
    $RFI = ConvertTo-RFI -Hub $Hub -Project $Project -RFI $RFI -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $RFIId = $RFI.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    # only send fields the caller provided
    $Body = @{}
    if ($PSBoundParameters.ContainsKey('Title'))            {$Body['title']            = $Title}
    if ($PSBoundParameters.ContainsKey('Question'))         {$Body['question']         = $Question}
    if ($PSBoundParameters.ContainsKey('SuggestedAnswer'))  {$Body['suggestedAnswer']  = $SuggestedAnswer}
    if ($PSBoundParameters.ContainsKey('Status'))           {$Body['status']           = $Status}
    if ($PSBoundParameters.ContainsKey('DueDate'))          {$Body['dueDate']          = $DueDate}
    if ($PSBoundParameters.ContainsKey('CustomAttributes')) {$Body['customAttributes'] = $CustomAttributes}
    if ($PSBoundParameters.ContainsKey('AssignedToId'))     {$Body['assignedTo']       = @( @{ id = $AssignedToId; type = $AssignedToType } )}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis/$RFIId"
        Method = "PATCH"
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

    $RFI = $response

    # Force update $Project.rfis
    $null = Get-RFIs -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $RFI
}


# ACC RFIs API - RFI Responses ___________________________________________________________________________________

function Add-RFIResponse
{
    <#
    .SYNOPSIS
    Submit a response to an RFI.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-rfis-rfiId-responses-POST/
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
        [ArgumentCompleter({ RFICompleter @args })]
        $RFI,

        [Parameter(Mandatory)]
        $Text,

        [Parameter()]
        [ArgumentCompleter({ RFIStatusCompleter @args })]
        $Status,

        # Autodesk id of the user this response is submitted on behalf of
        [Parameter()]
        $OnBehalf,

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
    $RFI = ConvertTo-RFI -Hub $Hub -Project $Project -RFI $RFI -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $RFIId = $RFI.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{ text = $Text }
    if ($Status)   {$Body['status']   = $Status}
    if ($OnBehalf) {$Body['onBehalf'] = $OnBehalf}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis/$RFIId/responses"
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

    return $response
}


# ACC RFIs API - RFI Comments ____________________________________________________________________________________

function Get-RFIComments
{
    <#
    .SYNOPSIS
    Get all Comments on an RFI.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-rfis-rfiId-comments-GET/
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
        [ArgumentCompleter({ RFICompleter @args })]
        $RFI,

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
    $RFI = ConvertTo-RFI -Hub $Hub -Project $Project -RFI $RFI -Force:$Force -ThreeLegged:$ThreeLegged

    $Comments = [System.Collections.ArrayList]@()
    $ProjectId = ConvertTo-B360Id $Project.id
    $RFIId = $RFI.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    function batch ($offset)
    {
        $request = @{
            Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis/$RFIId/comments?limit=100&offset=$offset"
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

        $response.results | foreach { $null = $Comments.Add($_) }

        if ( ($response.results.Count -gt 0) -and ($Comments.Count -lt $response.pagination.totalResults) )
        {
            batch ($offset + 100)
        }
    }

    batch 0

    return $Comments
}


function Add-RFIComment
{
    <#
    .SYNOPSIS
    Add a Comment to an RFI.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-rfis-rfiId-comments-POST/
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
        [ArgumentCompleter({ RFICompleter @args })]
        $RFI,

        [Parameter(Mandatory)]
        $Body,

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
    $RFI = ConvertTo-RFI -Hub $Hub -Project $Project -RFI $RFI -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $RFIId = $RFI.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $RequestBody = @{ body = $Body }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis/$RFIId/comments"
        Method = "POST"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $RequestBody
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    # reformat request.Body as PSObject before caching request,response pair
    $request.Body = $RequestBody
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    return $response
}


function Get-RFIAttachments
{
    <#
    .SYNOPSIS
    List the attachments on an RFI. (Downloading requires the OSS signed-url flow, not covered here.)

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-rfis-rfiId-attachments-GET/
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
        [ArgumentCompleter({ RFICompleter @args })]
        $RFI,

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
    $RFI = ConvertTo-RFI -Hub $Hub -Project $Project -RFI $RFI -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $RFIId = $RFI.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfis/$RFIId/attachments"
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

    return $response.results
}


# ACC RFIs API - RFI Types _______________________________________________________________________________________

function Get-RFITypes
{
    <#
    .SYNOPSIS
    Get the RFI types of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-RFI-types-GET/
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

    if ( (-not $Project.rfi_types) -or ($Force) )
    {
        $RFITypes = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/rfi-types?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $RFITypes.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($RFITypes.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $RFITypes = $Project.rfi_types
    }

    if ($null -ne $RFITypes)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'rfi_types' -NotePropertyValue $RFITypes -Force
        return $RFITypes
    }
    else
    {
        throw "RFITypes not found."
    }
}


function RFITypeCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for RFI types, keyed on id with the title/name as a comment.
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

        $RFITypes = Get-RFITypes -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $RFITypeDict = @{}
        $RFITypes | foreach {
            if ($_.title) {$Label = $_.title} else {$Label = $_.name}
            $null = $RFITypeDict["$($_.id)"] = "$Label"
        }

        $completer_args = @{
            CommentsDict = $RFITypeDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on title/name, show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


# ACC RFIs API - Project Settings ________________________________________________________________________________

function Get-RFIWorkflow
{
    <#
    .SYNOPSIS
    Get the RFI workflow configuration of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-workflow-GET/
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
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/workflow"
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


function Get-RFICustomAttributes
{
    <#
    .SYNOPSIS
    Get the RFI custom attribute definitions of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-attributes-GET/
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
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/attributes"
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


function Get-MyRFIPermissions
{
    <#
    .SYNOPSIS
    Get the calling user's RFI permissions/details for a Project (GET .../rfis/v3/projects/:projectId/users/me).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/rfis-users-me-GET/
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
    # users/me reports the *calling user's* details, so it needs a 3-legged (user) token.
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/rfis/v3/projects/$ProjectId/users/me"
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
