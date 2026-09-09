#   "Autodesk Forge PowerShell Cmdlets - ACC Admin API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Bim360.ps1")


# ACC Admin API __________________________________________________________________________________________________
# Modern ACC Account/Project Admin endpoints (construction/admin/v1|v2). Complements the existing BIM 360
# hq/v1 account-admin cmdlets in Autodesk.Forge.Bim360.ps1 (Get-B360Projects, New-B360Project, Get-ProjectUsers,
# Add-ProjectUsers, etc.). Projects are addressed by their raw id (without the "b." prefix); accounts are the
# hub id without the "b." prefix. Use ConvertTo-B360Id. These endpoints use account:read / account:write scopes.


# ACC Admin API - Projects _______________________________________________________________________________________

function Get-ACCProjects
{
    <#
    .SYNOPSIS
    Get all ACC/BIM 360 projects in an account (construction/admin/v1). Supports template/status/classification
    that the hq/v1 projects endpoint (Get-B360Projects) does not surface.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-accounts-accountId-projects-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

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

    if ( (-not $Hub.acc_projects) -or ($Force) )
    {
        $Projects = [System.Collections.ArrayList]@()
        $AccountId = $Hub.id | ConvertTo-B360Id
        $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

        # ACC Admin API can only retrieve a limited number of projects at a time. Batch to get all at once.
        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/admin/v1/accounts/$AccountId/projects?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $Projects.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Projects.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Projects = $Hub.acc_projects
    }

    if ($null -ne $Projects)
    {
        $Projects | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'hub' -NotePropertyValue $Hub -Force
        }

        $null = Add-Member -InputObject $Hub -NotePropertyName 'acc_projects' -NotePropertyValue $Projects -Force

        return $Projects
    }
    else
    {
        throw "ACC projects not found."
    }
}


function Get-ACCProjectFromAPI
{
    <#
    .SYNOPSIS
    Get one ACC/BIM 360 project by exact id, from the modern Admin endpoint (construction/admin/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-GET/
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
    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId"
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


function New-ACCProject
{
    <#
    .SYNOPSIS
    Create a new ACC project (construction/admin/v1), optionally cloning a template project.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-accounts-accountId-projects-POST/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        $ProjectName,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectTypeCompleter @args })]
        [ValidateScript({ ProjectTypeValidator })]
        $ProjectType,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $StartDate,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $EndDate,

        [Parameter()]
        [ArgumentCompleter({ MoneyValueCompleter @args })]
        [ValidateScript({ MoneyValueValidator })]
        $MoneyValue,

        [Parameter()]
        [ArgumentCompleter({ CurrencyCompleter @args })]
        [ValidateScript({ CurrencyValidator })]
        $Currency,

        [Parameter()]
        $JobNumber,

        [Parameter()]
        $AddressLine1,

        [Parameter()]
        $AddressLine2,

        [Parameter()]
        $City,

        [Parameter()]
        [ArgumentCompleter({ StateCompleter @args })]
        $StateOrProvince,

        [Parameter()]
        $PostalCode,

        [Parameter()]
        [ArgumentCompleter({ CountryCompleter @args })]
        [ValidateScript({ CountryValidator })]
        $Country,

        [Parameter()]
        [ArgumentCompleter({ TimezoneCompleter @args })]
        [ValidateScript({ TimezoneValidator })]
        $Timezone,

        [Parameter()]
        [ArgumentCompleter({ ConstructionTypeCompleter @args })]
        [ValidateScript({ ConstructionTypeValidator })]
        $ConstructionType,

        [Parameter()]
        $DeliveryMethod,

        [Parameter()]
        $CurrentPhase,

        # id of a template project to clone from
        [Parameter()]
        $TemplateProjectId,

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
    $AccountId = $Hub.id | ConvertTo-B360Id
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged

    $Body = @{
        name = $ProjectName
        type = $ProjectType
    }

    # optional parameters (ACC Admin API uses camelCase)
    if ($StartDate)         {$Body['startDate']        = $StartDate}
    if ($EndDate)           {$Body['endDate']          = $EndDate}
    if ($MoneyValue -or $Currency)
    {
        $ProjectValue = @{}
        if ($MoneyValue) {$ProjectValue['value']    = $MoneyValue}
        if ($Currency)   {$ProjectValue['currency'] = $Currency}
        $Body['projectValue'] = $ProjectValue
    }
    if ($JobNumber)         {$Body['jobNumber']        = $JobNumber}
    if ($AddressLine1)      {$Body['addressLine1']     = $AddressLine1}
    if ($AddressLine2)      {$Body['addressLine2']     = $AddressLine2}
    if ($City)              {$Body['city']             = $City}
    if ($StateOrProvince)   {$Body['stateOrProvince']  = $StateOrProvince}
    if ($PostalCode)        {$Body['postalCode']       = $PostalCode}
    if ($Country)           {$Body['country']          = $Country}
    if ($Timezone)          {$Body['timezone']         = $Timezone}
    if ($ConstructionType)  {$Body['constructionType'] = $ConstructionType}
    if ($DeliveryMethod)    {$Body['deliveryMethod']   = $DeliveryMethod}
    if ($CurrentPhase)      {$Body['currentPhase']     = $CurrentPhase}
    if ($TemplateProjectId) {$Body['template']         = @{ projectId = $TemplateProjectId }}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/accounts/$AccountId/projects"
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


function Set-ACCProject
{
    <#
    .SYNOPSIS
    Update an ACC project (construction/admin/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-PATCH/
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

        [Parameter()]
        $Name,

        [Parameter()]
        [ArgumentCompleter({ ProjectTypeCompleter @args })]
        $ProjectType,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $StartDate,

        [Parameter()]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $EndDate,

        [Parameter()]
        $JobNumber,

        [Parameter()]
        [ArgumentCompleter({ ConstructionTypeCompleter @args })]
        $ConstructionType,

        [Parameter()]
        $CurrentPhase,

        [Parameter()]
        $Status,

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
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged

    # only send fields the caller provided
    $Body = @{}
    if ($PSBoundParameters.ContainsKey('Name'))             {$Body['name']             = $Name}
    if ($PSBoundParameters.ContainsKey('ProjectType'))      {$Body['type']             = $ProjectType}
    if ($PSBoundParameters.ContainsKey('StartDate'))        {$Body['startDate']        = $StartDate}
    if ($PSBoundParameters.ContainsKey('EndDate'))          {$Body['endDate']          = $EndDate}
    if ($PSBoundParameters.ContainsKey('JobNumber'))        {$Body['jobNumber']        = $JobNumber}
    if ($PSBoundParameters.ContainsKey('ConstructionType')) {$Body['constructionType'] = $ConstructionType}
    if ($PSBoundParameters.ContainsKey('CurrentPhase'))     {$Body['currentPhase']     = $CurrentPhase}
    if ($PSBoundParameters.ContainsKey('Status'))           {$Body['status']           = $Status}

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId"
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

    return $response
}


# ACC Admin API - Project Users (single, construction/admin/v1) __________________________________________________

function Add-ACCProjectUser
{
    <#
    .SYNOPSIS
    Add a single user to an ACC project with product access (construction/admin/v1).
    Use -Admin to grant projectAdministration + docs administrator access.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-users-POST/
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
        [ArgumentCompleter({ HubUserCompleter @args })]
        $User,

        # Grant projectAdministration + docs administrator access
        [Parameter()]
        [Alias('a')]
        [Switch]
        $Admin,

        # Full products array (overrides -Admin). Shape: @( @{ key='docs'; access='member' }, ... )
        [Parameter()]
        [Object[]]
        $Products,

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
    $User = ConvertTo-User -Hub $Hub -User $User -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged

    if (-not $Products)
    {
        if ($Admin)
        {
            $Products = @(
                @{ key = 'projectAdministration'; access = 'administrator' },
                @{ key = 'docs';                  access = 'administrator' }
            )
        }
        else
        {
            $Products = @( , @{ key = 'docs'; access = 'member' } )
        }
    }

    $Body = @{
        email = $User.email
        products = $Products
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId/users"
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


function Get-ACCProjectUser
{
    <#
    .SYNOPSIS
    Get a single ACC project member by exact user id (construction/admin/v1). Accepts a project-user id
    directly, or an email/User (resolved to its membership id via Get-ProjectUsers).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-users-userId-GET/
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
        [ArgumentCompleter({ ProjectUserCompleter @args })]
        $User,

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

    $UserId = Resolve-ACCProjectUserId -Hub $Hub -Project $Project -User $User -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId/users/$UserId"
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


function Set-ACCProjectUser
{
    <#
    .SYNOPSIS
    Update an ACC project member's product access (construction/admin/v1).
    Use -Admin to grant projectAdministration + docs administrator access.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-users-userId-PATCH/
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
        [ArgumentCompleter({ ProjectUserCompleter @args })]
        $User,

        # Grant projectAdministration + docs administrator access
        [Parameter()]
        [Alias('a')]
        [Switch]
        $Admin,

        # Full products array (overrides -Admin). Shape: @( @{ key='docs'; access='member' }, ... )
        [Parameter()]
        [Object[]]
        $Products,

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

    $UserId = Resolve-ACCProjectUserId -Hub $Hub -Project $Project -User $User -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged

    if (-not $Products)
    {
        if ($Admin)
        {
            $Products = @(
                @{ key = 'projectAdministration'; access = 'administrator' },
                @{ key = 'docs';                  access = 'administrator' }
            )
        }
        else
        {
            $Products = @( , @{ key = 'docs'; access = 'member' } )
        }
    }

    $Body = @{ products = $Products }

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId/users/$UserId"
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

    return $response
}


function Remove-ACCProjectUser
{
    <#
    .SYNOPSIS
    Remove a member from an ACC project (construction/admin/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-users-userId-DELETE/
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
        [ArgumentCompleter({ ProjectUserCompleter @args })]
        $User,

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

    $UserId = Resolve-ACCProjectUserId -Hub $Hub -Project $Project -User $User -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId/users/$UserId"
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

    # Force update $Project.users
    $null = Get-ProjectUsers -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged

    return $response
}


function Resolve-ACCProjectUserId
{
    <#
    .SYNOPSIS
    Resolve a project-user membership id from an id string, a User object, or an email address
    (looked up via Get-ProjectUsers).
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        $Hub,

        [Parameter(Mandatory)]
        $Project,

        [Parameter(Mandatory)]
        $User,

        [Alias('f')]
        [Switch]
        $Force,

        [Switch]
        $ThreeLegged
    )

    # already an object with an id
    if (($User -is [PSCustomObject]) -and ($User.id))
    {
        return $User.id
    }

    # a raw id string that matches an existing project-user id
    $ProjectUsers = Get-ProjectUsers -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

    $Match = $ProjectUsers | where { ($_.id -eq $User) -or ($_.email -eq $User) -or ($_.autodeskId -eq $User) } | select -First 1

    if ($Match)
    {
        return $Match.id
    }
    else
    {
        # assume the caller passed a raw membership id
        return $User
    }
}


# ACC Admin API - Companies ______________________________________________________________________________________

function Get-ACCCompanies
{
    <#
    .SYNOPSIS
    Get all companies in an account (construction/admin/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-accounts-accountId-companies-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

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

    if ( (-not $Hub.acc_companies) -or ($Force) )
    {
        $Companies = [System.Collections.ArrayList]@()
        $AccountId = $Hub.id | ConvertTo-B360Id
        $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

        function batch ($offset)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/construction/admin/v1/accounts/$AccountId/companies?limit=100&offset=$offset"
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

            $response.results | foreach { $null = $Companies.Add($_) }

            if ( ($response.results.Count -gt 0) -and ($Companies.Count -lt $response.pagination.totalResults) )
            {
                batch ($offset + 100)
            }
        }

        batch 0
    }
    else
    {
        $Companies = $Hub.acc_companies
    }

    if ($null -ne $Companies)
    {
        $null = Add-Member -InputObject $Hub -NotePropertyName 'acc_companies' -NotePropertyValue $Companies -Force
        return $Companies
    }
    else
    {
        throw "ACC companies not found."
    }
}


function ACCCompanyCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for ACC companies, keyed on name.
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

    if ($FakeBoundParameters.Hub) {$Hub = $FakeBoundParameters.Hub}
    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ContainsKey('ThreeLegged')) {$ThreeLegged = [Bool]$FakeBoundParameters.ThreeLegged} else {$ThreeLegged = $Global:ForgeThreeLeggedByDefault}
    if ($FakeBoundParameters.ContainsKey('TwoLegged')) {$TwoLegged = [Bool]$FakeBoundParameters.TwoLegged} else {$TwoLegged = $false}

    # Never start an interactive sign-in from tab-completion: New-AccessToken3Legged opens a
    # browser and then blocks on its callback listener, which would freeze the prompt.
    if (-not (Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -NonInteractive))
    {
        return '<#  Not signed in -- run Connect-Forge first  #>'
    }

    if (-not $FakeBoundParameters.Hub)
    {
        $Completions = @('<#  !!! Provide $Hub parameter value first !!!  #>')
    }
    else
    {
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Companies = Get-ACCCompanies -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged

        $CompanyNames = $Companies | foreach {$_.name}

        $completer_args = @{
            CompletionsList = $CompanyNames
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        $Completions = StandardCompleter @completer_args
    }

    $Completions | foreach {$_}
}


function Get-ACCCompany
{
    <#
    .SYNOPSIS
    Get one company in an account by exact id (construction/admin/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-accounts-accountId-companies-companyId-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        $CompanyId,

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
    $AccountId = $Hub.id | ConvertTo-B360Id
    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/construction/admin/v1/accounts/$AccountId/companies/$CompanyId"
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


function Get-ACCProjectCompanies
{
    <#
    .SYNOPSIS
    Get the companies assigned to an ACC project (construction/admin/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/admin-projects-projectId-companies-GET/
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

    $Companies = [System.Collections.ArrayList]@()
    $ProjectId = ConvertTo-B360Id $Project.id
    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

    function batch ($offset)
    {
        $request = @{
            Uri = "https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId/companies?limit=100&offset=$offset"
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

        $response.results | foreach { $null = $Companies.Add($_) }

        if ( ($response.results.Count -gt 0) -and ($Companies.Count -lt $response.pagination.totalResults) )
        {
            batch ($offset + 100)
        }
    }

    batch 0

    return $Companies
}


# ACC Admin API - Business Units & Account Users _________________________________________________________________

function Get-ACCBusinessUnits
{
    <#
    .SYNOPSIS
    Get the business units structure of an account (hq/v1).

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/business_units_structure-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

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
    $AccountId = $Hub.id | ConvertTo-B360Id
    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/business_units_structure"
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

    if ($null -ne $response.business_units) {return $response.business_units} else {return $response}
}


function Get-ACCAccountUserByEmail
{
    <#
    .SYNOPSIS
    Look up an account user by email (hq/v1 users/search). Useful to resolve a user's account id before
    assigning them to projects.

    .LINK
    https://aps.autodesk.com/en/docs/acc/v1/reference/http/users-search-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory,ValueFromPipeline)]
        $Email,

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
    $AccountId = $Hub.id | ConvertTo-B360Id
    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

    $EmailEncoded = [System.Net.WebUtility]::UrlEncode($Email)

    $request = @{
        Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/users/search?email=$EmailEncoded"
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
