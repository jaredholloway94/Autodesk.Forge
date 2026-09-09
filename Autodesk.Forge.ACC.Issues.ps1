#   "Autodesk Forge PowerShell Cmdlets - ACC Issues API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")


# ACC Issues API _________________________________________________________________________________________________
# Note: the ACC Issues API addresses projects by their raw id (without the "b." prefix), just like the ACC Admin
# API. Use ConvertTo-B360Id on $Project.id when building request URIs.


# ACC Issues API - Issues ________________________________________________________________________________________

function Get-Issues
{
    <#
    .SYNOPSIS
    Get all Issues in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-GET/
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

    if ( (-not $Project.issues) -or ($Force) )
    {
        $Issues = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        # ACC Issues API can only retrieve a limited number of Issues at a time. Batch to get all Issues at once.
        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issues?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $Issues.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Issues.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Issues = $Project.issues
    }

    if ($null -ne $Issues)
    {
        $Issues | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'project' -NotePropertyValue $Project -Force
        }

        $Project | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'issues' -NotePropertyValue $Issues -Force
        }

        return $Issues
    }
    else
    {
        throw "Issues not found."
    }
}


function IssueCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Issues, keyed on displayId with the title as a comment.
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

        $Issues = Get-Issues -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $IssueDict = @{}
        $Issues | foreach { $null = $IssueDict["$($_.displayId)"] = "$($_.title)" }

        $completer_args = @{
            CommentsDict = $IssueDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on displayId, show title as comment
        $Completions = CommentedCompleterFromKeys @completer_args

        if ($Completions.Count -eq 0)
        {
            $Completions = @('<#  No matching Issues found. Check spelling or -Force to reload.  #>')
        }
    }

    $Completions | foreach {$_}
}


function ConvertTo-Issue
{
    <#
    .SYNOPSIS
    Coerce $Issue to [Issue] from (tab-completed) [String] (matched on displayId, id, or title).
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
        [ArgumentCompleter({ IssueCompleter @args })]
        [AllowNull()]
        $Issue,

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

    if ($null -eq $Issue)
    {
        return $null
    }
    elseif (($Issue -is [PSCustomObject]) -and ($null -ne $Issue.id))
    {
        return $Issue
    }
    elseif (($Issue -is [String]) -or ($Issue -is [Int]))
    {
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $Hub = $Project.hub

        $Issue = Get-Issues -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged |
        where { ("$($_.displayId)" -eq "$Issue") -or ($_.id -eq $Issue) -or ($_.title -eq $Issue) } |
        select -First 1

        return $Issue
    }
    else
    {
        throw "`$Issue is unexpected type."
    }
}


function Get-Issue
{
    <#
    .SYNOPSIS
    Get one Issue from a Project, by displayId, id, or title.
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
        [ArgumentCompleter({ IssueCompleter @args })]
        $Issue,

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

    $Issue = ConvertTo-Issue -Hub $Hub -Project $Project -Issue $Issue -Force:$Force -ThreeLegged:$ThreeLegged

    return $Issue
}


function Get-IssueFromAPI
{
    <#
    .SYNOPSIS
    Get one Issue by exact id, directly from the API.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-issueId-GET/
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
        $IssueId,

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
        Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issues/$IssueId"
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

    $Issue = $response

    return $Issue
}


function New-Issue
{
    <#
    .SYNOPSIS
    Create a new Issue in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-POST/
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

        # id of the Issue subtype (get from Get-IssueTypes -IncludeSubtypes)
        [Parameter(Mandatory)]
        [ArgumentCompleter({ IssueSubtypeCompleter @args })]
        $IssueSubtypeId,

        [Parameter()]
        $Description,

        [Parameter()]
        [ArgumentCompleter({ IssueStatusCompleter @args })]
        $Status = 'open',

        # Autodesk id (or company/role id) of the assignee
        [Parameter()]
        $AssignedTo,

        [Parameter()]
        [ArgumentCompleter({ IssueAssignedToTypeCompleter @args })]
        $AssignedToType,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $DueDate,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $StartDate,

        # id of the root cause (get from Get-IssueRootCauseCategories -IncludeRootCauses)
        [Parameter()]
        [ArgumentCompleter({ IssueRootCauseCompleter @args })]
        $RootCauseId,

        [Parameter()]
        $LocationId,

        [Parameter()]
        $LocationDetails,

        # Publish the Issue on creation (default: unpublished/draft, visible only to creator and assignee)
        [Switch]
        $Published,

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
        issueSubtypeId = $IssueSubtypeId
    }

    # optional parameters
    if ($Description)     {$Body['description']     = $Description}
    if ($Status)          {$Body['status']          = $Status}
    if ($AssignedTo)      {$Body['assignedTo']      = $AssignedTo}
    if ($AssignedToType)  {$Body['assignedToType']  = $AssignedToType}
    if ($DueDate)         {$Body['dueDate']         = $DueDate}
    if ($StartDate)       {$Body['startDate']       = $StartDate}
    if ($RootCauseId)     {$Body['rootCauseId']     = $RootCauseId}
    if ($LocationId)      {$Body['locationId']      = $LocationId}
    if ($LocationDetails) {$Body['locationDetails'] = $LocationDetails}
    if ($Published)       {$Body['published']       = $true}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issues"
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

    $Issue = $response

    # Force update $Project.issues
    $null = Get-Issues -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $Issue
}


function Set-Issue
{
    <#
    .SYNOPSIS
    Update an existing Issue in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-issueId-PATCH/
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
        [ArgumentCompleter({ IssueCompleter @args })]
        $Issue,

        [Parameter()]
        $Title,

        [Parameter()]
        $Description,

        [Parameter()]
        [ArgumentCompleter({ IssueStatusCompleter @args })]
        $Status,

        [Parameter()]
        [ArgumentCompleter({ IssueSubtypeCompleter @args })]
        $IssueSubtypeId,

        [Parameter()]
        $AssignedTo,

        [Parameter()]
        [ArgumentCompleter({ IssueAssignedToTypeCompleter @args })]
        $AssignedToType,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $DueDate,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $StartDate,

        [Parameter()]
        [ArgumentCompleter({ IssueRootCauseCompleter @args })]
        $RootCauseId,

        [Parameter()]
        $LocationId,

        [Parameter()]
        $LocationDetails,

        # Publish the Issue
        [Switch]
        $Published,

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
    $Issue = ConvertTo-Issue -Hub $Hub -Project $Project -Issue $Issue -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $IssueId = $Issue.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    # only send fields the caller provided
    $Body = @{}
    if ($PSBoundParameters.ContainsKey('Title'))           {$Body['title']           = $Title}
    if ($PSBoundParameters.ContainsKey('Description'))      {$Body['description']     = $Description}
    if ($PSBoundParameters.ContainsKey('Status'))          {$Body['status']          = $Status}
    if ($PSBoundParameters.ContainsKey('IssueSubtypeId'))  {$Body['issueSubtypeId']  = $IssueSubtypeId}
    if ($PSBoundParameters.ContainsKey('AssignedTo'))      {$Body['assignedTo']      = $AssignedTo}
    if ($PSBoundParameters.ContainsKey('AssignedToType'))  {$Body['assignedToType']  = $AssignedToType}
    if ($PSBoundParameters.ContainsKey('DueDate'))         {$Body['dueDate']         = $DueDate}
    if ($PSBoundParameters.ContainsKey('StartDate'))       {$Body['startDate']       = $StartDate}
    if ($PSBoundParameters.ContainsKey('RootCauseId'))     {$Body['rootCauseId']     = $RootCauseId}
    if ($PSBoundParameters.ContainsKey('LocationId'))      {$Body['locationId']      = $LocationId}
    if ($PSBoundParameters.ContainsKey('LocationDetails')) {$Body['locationDetails'] = $LocationDetails}
    if ($PSBoundParameters.ContainsKey('Published'))       {$Body['published']       = [bool]$Published}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issues/$IssueId"
        Method = "PATCH"
        Headers = @{ "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        Body = ConvertTo-Json $Body
        ContentType = 'application/vnd.api+json'
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

    $Issue = $response

    # Force update $Project.issues
    $null = Get-Issues -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $Issue
}


# ACC Issues API - Issue Comments ________________________________________________________________________________

function Get-IssueComments
{
    <#
    .SYNOPSIS
    Get all Comments on an Issue.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-issueId-comments-GET/
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
        [ArgumentCompleter({ IssueCompleter @args })]
        $Issue,

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
    $Issue = ConvertTo-Issue -Hub $Hub -Project $Project -Issue $Issue -Force:$Force -ThreeLegged:$ThreeLegged

    if ( (-not $Issue.comments) -or ($Force) )
    {
        $Comments = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $IssueId = $Issue.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issues/$IssueId/comments?limit=100&offset=$offset"
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
    }
    else
    {
        $Comments = $Issue.comments
    }

    if ($null -ne $Comments)
    {
        $null = Add-Member -InputObject $Issue -NotePropertyName 'comments' -NotePropertyValue $Comments -Force
    }

    return $Comments
}


function Add-IssueComment
{
    <#
    .SYNOPSIS
    Add a Comment to an Issue.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issues-issueId-comments-POST/
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
        [ArgumentCompleter({ IssueCompleter @args })]
        $Issue,

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
    $Issue = ConvertTo-Issue -Hub $Hub -Project $Project -Issue $Issue -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $IssueId = $Issue.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $RequestBody = @{
        issueId = $IssueId
        body = $Body
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issues/$IssueId/comments"
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

    $Comment = $response

    return $Comment
}


# ACC Issues API - Issue Types (Categories & Subtypes) ___________________________________________________________

function Get-IssueTypes
{
    <#
    .SYNOPSIS
    Get the Issue types (categories) of a Project. Use -IncludeSubtypes to also return each type's subtypes.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issue-types-GET/
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

        # Include each type's subtypes in the results
        [Switch]
        $IncludeSubtypes,

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

    if ( (-not $Project.issue_types) -or ($Force) )
    {
        $IssueTypes = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        if ($IncludeSubtypes) {$IncludeQuery = "&include=subtypes"} else {$IncludeQuery = ""}

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issue-types?limit=100&offset=$offset$IncludeQuery"
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

            $response.results | foreach { $null = $IssueTypes.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($IssueTypes.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $IssueTypes = $Project.issue_types
    }

    if ($null -ne $IssueTypes)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'issue_types' -NotePropertyValue $IssueTypes -Force
        return $IssueTypes
    }
    else
    {
        throw "IssueTypes not found."
    }
}


function IssueTypeCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Issue types (categories), keyed on id with the title as a comment.
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

        $IssueTypes = Get-IssueTypes -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $IssueTypeDict = @{}
        $IssueTypes | foreach { $null = $IssueTypeDict["$($_.id)"] = "$($_.title)" }

        $completer_args = @{
            CommentsDict = $IssueTypeDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on title, show title as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


function IssueSubtypeCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Issue subtypes (assignable to issues via issueSubtypeId),
    keyed on subtype id with "Category > Subtype" as a comment.
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

        $IssueTypes = Get-IssueTypes -Hub $Hub -Project $Project -IncludeSubtypes -Force:$Force -ThreeLegged:$ThreeLegged

        $SubtypeDict = @{}
        $IssueTypes | foreach {
            $Category = $_.title
            $_.subtypes | foreach {
                $null = $SubtypeDict["$($_.id)"] = "$Category > $($_.title)"
            }
        }

        $completer_args = @{
            CommentsDict = $SubtypeDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on "Category > Subtype", show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


# ACC Issues API - Root Cause Categories _________________________________________________________________________

function Get-IssueRootCauseCategories
{
    <#
    .SYNOPSIS
    Get the root cause categories of a Project. Use -IncludeRootCauses to also return each category's root causes.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issue-root-cause-categories-GET/
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

        # Include each category's root causes in the results
        [Switch]
        $IncludeRootCauses,

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

    if ( (-not $Project.issue_root_cause_categories) -or ($Force) )
    {
        $RootCauseCategories = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        if ($IncludeRootCauses) {$IncludeQuery = "&include=rootcauses"} else {$IncludeQuery = ""}

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issue-root-cause-categories?limit=100&offset=$offset$IncludeQuery"
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

            $response.results | foreach { $null = $RootCauseCategories.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($RootCauseCategories.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $RootCauseCategories = $Project.issue_root_cause_categories
    }

    if ($null -ne $RootCauseCategories)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'issue_root_cause_categories' -NotePropertyValue $RootCauseCategories -Force
        return $RootCauseCategories
    }
    else
    {
        throw "Issue root cause categories not found."
    }
}


function IssueRootCauseCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Issue root causes (assignable to issues via rootCauseId),
    keyed on root cause id with "Category > Root Cause" as a comment.
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

        $RootCauseCategories = Get-IssueRootCauseCategories -Hub $Hub -Project $Project -IncludeRootCauses -Force:$Force -ThreeLegged:$ThreeLegged

        $RootCauseDict = @{}
        $RootCauseCategories | foreach {
            $Category = $_.title
            $_.rootCauses | foreach {
                $null = $RootCauseDict["$($_.id)"] = "$Category > $($_.title)"
            }
        }

        $completer_args = @{
            CommentsDict = $RootCauseDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on "Category > Root Cause", show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


# ACC Issues API - Custom Attributes _____________________________________________________________________________

function Get-IssueAttributeDefinitions
{
    <#
    .SYNOPSIS
    Get the custom attribute (custom field) definitions of a Project's issues.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issue-attribute-definitions-GET/
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

    if ( (-not $Project.issue_attribute_definitions) -or ($Force) )
    {
        $AttributeDefinitions = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issue-attribute-definitions?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $AttributeDefinitions.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($AttributeDefinitions.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $AttributeDefinitions = $Project.issue_attribute_definitions
    }

    if ($null -ne $AttributeDefinitions)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'issue_attribute_definitions' -NotePropertyValue $AttributeDefinitions -Force
        return $AttributeDefinitions
    }
    else
    {
        throw "Issue attribute definitions not found."
    }
}


function Get-IssueAttributeMappings
{
    <#
    .SYNOPSIS
    Get the custom attribute (custom field) mappings that assign attributes to a Project's issue types/subtypes.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-issue-attribute-mappings-GET/
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

    if ( (-not $Project.issue_attribute_mappings) -or ($Force) )
    {
        $AttributeMappings = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/issue-attribute-mappings?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $AttributeMappings.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($AttributeMappings.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $AttributeMappings = $Project.issue_attribute_mappings
    }

    if ($null -ne $AttributeMappings)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'issue_attribute_mappings' -NotePropertyValue $AttributeMappings -Force
        return $AttributeMappings
    }
    else
    {
        throw "Issue attribute mappings not found."
    }
}


# ACC Issues API - User Permissions ______________________________________________________________________________

function Get-MyIssuePermissions
{
    <#
    .SYNOPSIS
    Get the calling user's Issues permissions for a Project (GET .../issues/v1/projects/:projectId/users/me).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/issues-users-me-GET/
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
    # users/me reports the *calling user's* permissions, so it needs a 3-legged (user) token.
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/issues/v1/projects/$ProjectId/users/me"
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
