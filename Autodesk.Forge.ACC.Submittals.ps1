#   "Autodesk Forge PowerShell Cmdlets - ACC Submittals API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")


# ACC Submittals API _____________________________________________________________________________________________
# Note: the ACC Submittals API (v2) addresses projects by their raw id (without the "b." prefix), just like the
# ACC Admin / Issues / RFIs APIs. Use ConvertTo-B360Id on $Project.id when building request URIs.


# ACC Submittals API - Items _____________________________________________________________________________________

function Get-SubmittalItems
{
    <#
    .SYNOPSIS
    Get all Submittal items in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ( (-not $Project.submittal_items) -or ($Force) )
    {
        $Items = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        # ACC Submittals API can only retrieve a limited number of items at a time. Batch to get all items at once.
        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $Items.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Items.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Items = $Project.submittal_items
    }

    if ($null -ne $Items)
    {
        $Items | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'project' -NotePropertyValue $Project -Force
        }

        $Project | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'submittal_items' -NotePropertyValue $Items -Force
        }

        return $Items
    }
    else
    {
        throw "Submittal items not found."
    }
}


function SubmittalItemCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Submittal items, keyed on identifier with the title as a comment.
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
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

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

        $Items = Get-SubmittalItems -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $ItemDict = @{}
        $Items | foreach {
            if ($_.customIdentifier) {$Key = $_.customIdentifier} else {$Key = $_.identifier}
            $null = $ItemDict["$Key"] = "$($_.title)"
        }

        $completer_args = @{
            CommentsDict = $ItemDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on identifier, show title as comment
        $Completions = CommentedCompleterFromKeys @completer_args

        if ($Completions.Count -eq 0)
        {
            $Completions = @('<#  No matching Submittal items found. Check spelling or -Force to reload.  #>')
        }
    }

    $Completions | foreach {$_}
}


function ConvertTo-SubmittalItem
{
    <#
    .SYNOPSIS
    Coerce $Item to a Submittal item object from (tab-completed) [String] (matched on
    customIdentifier, identifier, id, or title).
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        [AllowNull()]
        $Item,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    if ($null -eq $Item)
    {
        return $null
    }
    elseif (($Item -is [PSCustomObject]) -and ($null -ne $Item.id))
    {
        return $Item
    }
    elseif (($Item -is [String]) -or ($Item -is [Int]))
    {
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $Hub = $Project.hub

        $Item = Get-SubmittalItems -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged |
        where {
            ("$($_.customIdentifier)" -eq "$Item") -or ("$($_.identifier)" -eq "$Item") -or
            ($_.id -eq $Item) -or ($_.title -eq $Item)
        } |
        select -First 1

        return $Item
    }
    else
    {
        throw "`$Item is unexpected type."
    }
}


function Get-SubmittalItem
{
    <#
    .SYNOPSIS
    Get one Submittal item from a Project, by customIdentifier, identifier, id, or title.
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        $Item,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $Item = ConvertTo-SubmittalItem -Hub $Hub -Project $Project -Item $Item -Force:$Force -ThreeLegged:$ThreeLegged

    return $Item
}


function Get-SubmittalItemFromAPI
{
    <#
    .SYNOPSIS
    Get one Submittal item by exact id, directly from the API.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-GET/
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
        $ItemId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items/$ItemId"
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


function New-SubmittalItem
{
    <#
    .SYNOPSIS
    Create a new Submittal item in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-POST/
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

        # id of the spec section (get from Get-SubmittalSpecs)
        [Parameter(Mandatory)]
        [ArgumentCompleter({ SubmittalSpecCompleter @args })]
        $SpecId,

        # id of the item type (get from Get-SubmittalItemTypes)
        [Parameter(Mandatory)]
        [ArgumentCompleter({ SubmittalItemTypeCompleter @args })]
        $TypeId,

        # initial workflow state; 'sbc-1' (subcontractor draft) is the usual creation state
        [Parameter()]
        $StateId = 'sbc-1',

        # Autodesk id of the subcontractor
        [Parameter()]
        $Subcontractor,

        # subcontractor type code ('1' user, '2' company, '3' role)
        [Parameter()]
        $SubcontractorType,

        [Parameter()]
        $SubmitterDueDate,

        [Parameter()]
        $Description,

        # id of the package to add this item to (get from Get-SubmittalPackages)
        [Parameter()]
        [ArgumentCompleter({ SubmittalPackageCompleter @args })]
        $PackageId,

        [Parameter()]
        $CustomIdentifier,

        # Array of Autodesk ids to add as watchers
        [Parameter()]
        [Object[]]
        $Watchers = @(),

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{
        title = $Title
        specId = $SpecId
        typeId = $TypeId
        stateId = $StateId
        watchers = $Watchers
    }

    # optional parameters
    if ($Subcontractor)     {$Body['subcontractor']     = $Subcontractor}
    if ($SubcontractorType) {$Body['subcontractorType'] = $SubcontractorType}
    if ($SubmitterDueDate)  {$Body['submitterDueDate']  = $SubmitterDueDate}
    if ($Description)        {$Body['description']       = $Description}
    if ($PackageId)         {$Body['packageId']         = $PackageId}
    if ($CustomIdentifier)  {$Body['customIdentifier']  = $CustomIdentifier}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items"
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

    $Item = $response

    # Force update $Project.submittal_items
    $null = Get-SubmittalItems -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $Item
}


function Set-SubmittalItem
{
    <#
    .SYNOPSIS
    Update an existing Submittal item in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-PATCH/
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        $Item,

        [Parameter()]
        $Title,

        [Parameter()]
        $Description,

        [Parameter()]
        [ArgumentCompleter({ SubmittalSpecCompleter @args })]
        $SpecId,

        [Parameter()]
        [ArgumentCompleter({ SubmittalPackageCompleter @args })]
        $PackageId,

        [Parameter()]
        $SubmitterDueDate,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $Item = ConvertTo-SubmittalItem -Hub $Hub -Project $Project -Item $Item -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $ItemId = $Item.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    # only send fields the caller provided
    $Body = @{}
    if ($PSBoundParameters.ContainsKey('Title'))            {$Body['title']            = $Title}
    if ($PSBoundParameters.ContainsKey('Description'))       {$Body['description']      = $Description}
    if ($PSBoundParameters.ContainsKey('SpecId'))           {$Body['specId']           = $SpecId}
    if ($PSBoundParameters.ContainsKey('PackageId'))        {$Body['packageId']        = $PackageId}
    if ($PSBoundParameters.ContainsKey('SubmitterDueDate')) {$Body['submitterDueDate'] = $SubmitterDueDate}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items/$ItemId"
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

    $Item = $response

    # Force update $Project.submittal_items
    $null = Get-SubmittalItems -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $Item
}


function Set-SubmittalItemState
{
    <#
    .SYNOPSIS
    Transition a Submittal item to a new workflow state (POST .../items/{itemId}:transition).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-transition-POST/
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        $Item,

        # target workflow state id (e.g. mgr-1, rev, mgr-2, sbc-2)
        [Parameter(Mandatory)]
        $StateId,

        # Autodesk id of the manager (required when transitioning into manager states)
        [Parameter()]
        $Manager,

        # manager type code ('1' user, '2' company, '3' role)
        [Parameter()]
        $ManagerType,

        # Array of attachment ids to duplicate into the new state
        [Parameter()]
        [Object[]]
        $DuplicateAttachments,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $Item = ConvertTo-SubmittalItem -Hub $Hub -Project $Project -Item $Item -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $ItemId = $Item.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{ stateId = $StateId }
    if ($Manager)              {$Body['manager']              = $Manager}
    if ($ManagerType)          {$Body['managerType']          = $ManagerType}
    if ($DuplicateAttachments) {$Body['duplicateAttachments'] = $DuplicateAttachments}

    # NOTE: $($ItemId) subexpression keeps PowerShell from parsing ":transition" as a variable scope.
    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items/$($ItemId):transition"
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

    $Item = $response

    # Force update $Project.submittal_items
    $null = Get-SubmittalItems -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $Item
}


function Get-SubmittalItemRevisions
{
    <#
    .SYNOPSIS
    Get the revisions of a Submittal item.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-revisions-GET/
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        $Item,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $Item = ConvertTo-SubmittalItem -Hub $Hub -Project $Project -Item $Item -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $ItemId = $Item.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items/$ItemId/revisions"
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


function Get-SubmittalItemSteps
{
    <#
    .SYNOPSIS
    Get the workflow steps of a Submittal item.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-steps-GET/
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        $Item,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $Item = ConvertTo-SubmittalItem -Hub $Hub -Project $Project -Item $Item -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $ItemId = $Item.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items/$ItemId/steps"
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


function Get-SubmittalItemAttachments
{
    <#
    .SYNOPSIS
    List the attachments on a Submittal item. (Uploading requires the OSS signed-url flow, not covered here.)

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-itemId-attachments-GET/
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
        [ArgumentCompleter({ SubmittalItemCompleter @args })]
        $Item,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $Item = ConvertTo-SubmittalItem -Hub $Hub -Project $Project -Item $Item -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $ItemId = $Item.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items/$ItemId/attachments"
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


function Get-SubmittalNextCustomIdentifier
{
    <#
    .SYNOPSIS
    Get the next available custom identifier for a new Submittal item.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-items-next-custom-identifier-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/items:next-custom-identifier"
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


# ACC Submittals API - Spec Sections _____________________________________________________________________________

function Get-SubmittalSpecs
{
    <#
    .SYNOPSIS
    Get the spec sections of a Project's submittals.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-specs-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ( (-not $Project.submittal_specs) -or ($Force) )
    {
        $Specs = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/specs?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $Specs.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Specs.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Specs = $Project.submittal_specs
    }

    if ($null -ne $Specs)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'submittal_specs' -NotePropertyValue $Specs -Force
        return $Specs
    }
    else
    {
        throw "Submittal spec sections not found."
    }
}


function SubmittalSpecCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Submittal spec sections, keyed on id with "identifier - title" as a comment.
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
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

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

        $Specs = Get-SubmittalSpecs -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $SpecDict = @{}
        $Specs | foreach { $null = $SpecDict["$($_.id)"] = "$($_.identifier) - $($_.title)" }

        $completer_args = @{
            CommentsDict = $SpecDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on "identifier - title", show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


function New-SubmittalSpec
{
    <#
    .SYNOPSIS
    Create a new spec section in a Project's submittals.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-specs-POST/
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

        [Parameter(Mandatory)]
        $Identifier,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{
        title = $Title
        identifier = $Identifier
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/specs"
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

    # Force update $Project.submittal_specs
    $null = Get-SubmittalSpecs -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


# ACC Submittals API - Item Types ________________________________________________________________________________

function Get-SubmittalItemTypes
{
    <#
    .SYNOPSIS
    Get the Submittal item types of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-item-types-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ( (-not $Project.submittal_item_types) -or ($Force) )
    {
        $ItemTypes = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/item-types?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $ItemTypes.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($ItemTypes.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $ItemTypes = $Project.submittal_item_types
    }

    if ($null -ne $ItemTypes)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'submittal_item_types' -NotePropertyValue $ItemTypes -Force
        return $ItemTypes
    }
    else
    {
        throw "Submittal item types not found."
    }
}


function SubmittalItemTypeCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Submittal item types, keyed on id with the name as a comment.
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
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

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

        $ItemTypes = Get-SubmittalItemTypes -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $ItemTypeDict = @{}
        $ItemTypes | foreach {
            if ($_.name) {$Label = $_.name} else {$Label = $_.title}
            $null = $ItemTypeDict["$($_.id)"] = "$Label"
        }

        $completer_args = @{
            CommentsDict = $ItemTypeDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on name, show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


function Get-SubmittalItemType
{
    <#
    .SYNOPSIS
    Get one Submittal item type by exact id.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-item-types-itemTypeId-GET/
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
        [ArgumentCompleter({ SubmittalItemTypeCompleter @args })]
        $ItemTypeId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/item-types/$ItemTypeId"
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


# ACC Submittals API - Packages __________________________________________________________________________________

function Get-SubmittalPackages
{
    <#
    .SYNOPSIS
    Get the Submittal packages of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-packages-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ( (-not $Project.submittal_packages) -or ($Force) )
    {
        $Packages = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/packages?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $Packages.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Packages.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Packages = $Project.submittal_packages
    }

    if ($null -ne $Packages)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'submittal_packages' -NotePropertyValue $Packages -Force
        return $Packages
    }
    else
    {
        throw "Submittal packages not found."
    }
}


function SubmittalPackageCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Submittal packages, keyed on id with the title as a comment.
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
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

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

        $Packages = Get-SubmittalPackages -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        $PackageDict = @{}
        $Packages | foreach { $null = $PackageDict["$($_.id)"] = "$($_.title)" }

        $completer_args = @{
            CommentsDict = $PackageDict
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        # match on title, show it as comment
        $Completions = CommentedCompleterFromValues @completer_args
    }

    $Completions | foreach {$_}
}


function Get-SubmittalPackage
{
    <#
    .SYNOPSIS
    Get one Submittal package by exact id.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-packages-packageId-GET/
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
        [ArgumentCompleter({ SubmittalPackageCompleter @args })]
        $PackageId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/packages/$PackageId"
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


# ACC Submittals API - Responses _________________________________________________________________________________

function Get-SubmittalResponses
{
    <#
    .SYNOPSIS
    Get the list of possible responses configured for a Project's submittals.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-responses-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/responses"
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


function Get-SubmittalResponse
{
    <#
    .SYNOPSIS
    Get one Submittal response by exact id.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-responses-responseId-GET/
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
        $ResponseId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/responses/$ResponseId"
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


# ACC Submittals API - Settings & Metadata _______________________________________________________________________

function Get-SubmittalMetadata
{
    <#
    .SYNOPSIS
    Get the Submittals metadata (statuses, states, etc.) of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-metadata-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/metadata"
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


function Get-SubmittalTemplates
{
    <#
    .SYNOPSIS
    Get the review templates configured for a Project's submittals (admin only).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-templates-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/templates"
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


function Get-SubmittalSettingsMappings
{
    <#
    .SYNOPSIS
    Get the Submittals manager/reviewer role mappings of a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-settings-mappings-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/settings/mappings"
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


function New-SubmittalSettingsMapping
{
    <#
    .SYNOPSIS
    Create a Submittals manager/reviewer role mapping in a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-settings-mappings-POST/
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

        # Autodesk id of the user/company/role being mapped
        [Parameter(Mandatory)]
        $AutodeskId,

        # user type code ('1' user, '2' company, '3' role)
        [Parameter(Mandatory)]
        $UserType,

        # submittals role code ('1' manager, ...)
        [Parameter(Mandatory)]
        $SubmittalsRole,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $Body = @{
        autodeskId = $AutodeskId
        userType = $UserType
        submittalsRole = $SubmittalsRole
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/settings/mappings"
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


function Remove-SubmittalSettingsMapping
{
    <#
    .SYNOPSIS
    Delete a Submittals manager/reviewer role mapping from a Project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-settings-mappings-mappingId-DELETE/
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
        $MappingId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "data:write" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/settings/mappings/$MappingId"
        Method = "DELETE"
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


# ACC Submittals API - User Permissions __________________________________________________________________________

function Get-MySubmittalPermissions
{
    <#
    .SYNOPSIS
    Get the calling user's Submittals permissions for a Project (GET .../submittals/v2/projects/:projectId/users/me).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/submittals-users-me-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectId = ConvertTo-B360Id $Project.id
    # users/me reports the *calling user's* permissions, so it needs a 3-legged (user) token.
    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/submittals/v2/projects/$ProjectId/users/me"
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
