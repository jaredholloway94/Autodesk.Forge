#   "Autodesk Forge PowerShell Cmdlets - BIM 360 API "
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")


# Deprecation notices ____________________________________________________________________________________________

$Global:ForgeDeprecationWarned = @{}

function Write-ForgeDeprecationWarning
{
    <#
        .SYNOPSIS
        Warn once per session that a cmdlet is deprecated and what supersedes it.
    #>

    param
    (
        [Parameter(Mandatory,Position=0)]
        [String]
        $Old,

        [Parameter(Mandatory,Position=1)]
        [String]
        $New
    )

    if (-not $Global:ForgeDeprecationWarned.ContainsKey($Old))
    {
        Write-Warning "$Old is deprecated and now forwards to $New. It used a BIM 360 hq/v1 endpoint, which only accepts 2-legged (app) tokens and so could not respect the signed-in user's access."
        $Global:ForgeDeprecationWarned[$Old] = $true
    }
}


# BIM 360 API - Companies ________________________________________________________________________________________




# BIM 360 API - Account Users ____________________________________________________________________________________

function Get-HubUsers
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/users-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        # Force update local cache from source
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

    if ((-not $Hub.users) -or ($Force))
    {
        $HubUsers = [System.Collections.ArrayList]@()
        $AccountId = $Hub.id | ConvertTo-B360Id
        $AccessToken = # NOTE: hq/v1|v2 account-admin endpoints only accept 2-legged tokens
        # (see Autodesk request HQ-5133), so -ThreeLegged is ignored here.
        Get-AccessToken -Scope "account:read" -TwoLegged

        # BIM 360 API can only retrieve 100 HubUsers at a time. Use this batch function to get all HubUsers at once.
        function Get-HubUsers_batch ($i)
        {
            $request = @{
                Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/users?limit=100&offset=$i"
                Method = "GET"
                Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
            }
            $response = Invoke-RestMethod @request
            $null = $Global:RequestResponseHistory.Add(@{
                function = $MyInvocation.MyCommand.Name
                request = $request
                response = $response
            })

            if ($response.count -ne 0)
            {
                $response | foreach { $null = $HubUsers.Add($_) }
                $i += 100
                Get-HubUsers_batch $i 
            }
        }
        
        Get-HubUsers_batch 0
    }
    else
    {
        $HubUsers = $Hub.users
    }

    if ($HubUsers)
    {
        $null = Add-Member -InputObject $Hub -NotePropertyName 'users' -NotePropertyValue $HubUsers -Force
        return $HubUsers
    }
    else
    {
        throw "HubUsers not found."
    }
}


function HubUserCompleter
{
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
    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ContainsKey('ThreeLegged')) {$ThreeLegged = [Bool]$FakeBoundParameters.ThreeLegged} else {$ThreeLegged = $Global:ForgeThreeLeggedByDefault}
    if ($FakeBoundParameters.ContainsKey('TwoLegged')) {$TwoLegged = [Bool]$FakeBoundParameters.TwoLegged} else {$TwoLegged = $false}

    # Never start an interactive sign-in from tab-completion (see HubNameCompleter).
    if (-not (Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -NonInteractive))
    {
        return '<#  Not signed in -- run Connect-Forge first  #>'
    }

    $HubUsers = Get-HubUsers `
    -Hub $FakeBoundParameters.Hub `
    -Force:$Force `
    -ThreeLegged:$ThreeLegged `

    $HubUserDict = @{}
    $HubUsers | foreach { $HubUserDict.Add("$($_.email)","$($_.name)") }

    $completer_args = @{
        CommentsDict = $HubUserDict
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    switch ($ParameterName)
    {
        'Name' {$Completions = CommentedCompleterFromValues @completer_args}
        'Email' {$Completions = CommentedCompleterFromKeys @completer_args}
        default {$Completions = CommentedCompleterFromValues @completer_args}
    }
    
    if ($Completions.Count -eq 0)
    {
        $Completions = @("<#  No matches found in hub directory. Check spelling or Add-HubUser first.  #>")
    }

    $Completions | foreach {$_}
}

<# WIP
function New-User
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        $Email,

        [Parameter(Mandatory)]
        $FirstName,

        [Parameter(Mandatory)]
        $LastName,

        # Force reload local cache from source
        [Parameter()]
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Parameter()]
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged
    $request = @{
        Uri = "https://developer.api.autodesk.com/hq/v1/accounts/:account_id/users"
        Method = "POST"
        Headers = @{
            Authorization = "$($AccessToken.token_type) $($AccessToken.access_token)"
        }
        Body = @{

        }

    }
    $respose = Invoke-RestMethod @request

    return $HubUser
}
#>


function Get-HubUser
{
    <#
        Get a single User from a Hub, by name or by email.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter()]
        [ArgumentCompleter({ HubUserCompleter @args })]
        $Name,

        [Parameter()]
        [ArgumentCompleter({ HubUserCompleter @args })]
        $Email,

        # Force reload local cache from source
        [Parameter()]
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Parameter()]
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged

    if ($Name) {$User = $Name} elseif ($Email) {$User = $Email}

    $HubUser = Get-HubUsers $Hub -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.email -eq $User}

    return $HubUser
}



# BIM 360 API - Projects _________________________________________________________________________________________
# API Object Reference: https://forge.autodesk.com/en/docs/bim360/v1/overview/field-guide/#project


function Get-B360Projects
{
    <#
    .SYNOPSIS
    DEPRECATED -- superseded by Get-ACCProjects.

    .DESCRIPTION
    The BIM 360 hq/v1 projects endpoint only accepts 2-legged (app) tokens, so it always returned
    every project in the account regardless of who was signed in. This now forwards to
    Get-ACCProjects (construction/admin/v1), which accepts 3-legged tokens and therefore respects
    the signed-in user's access.

    Note: the returned objects use the ACC Admin shape (camelCase) rather than the old hq/v1 shape.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        # Force update local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault,

        # Force the app-level (2-Legged) flow. ACC Admin endpoints reject a *pure* 2-legged
        # token, so -OnBehalfOf must be supplied alongside this.
        [Switch]
        $TwoLegged,

        # Autodesk id of the user to act on behalf of (sent as the x-user-id header).
        [Parameter()]
        $OnBehalfOf
    )

    Write-ForgeDeprecationWarning 'Get-B360Projects' 'Get-ACCProjects'

    return Get-ACCProjects -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -OnBehalfOf $OnBehalfOf
}


function Get-B360Project
{
    <#
    .SYNOPSIS
    Get one B360Project, either from Hub name and Project name, or from Project object.
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

        # Force update local cache from source
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
    $Private:Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

    $Private:ProjectName = $Private:Project.attributes.name
    
    $B360Project = Get-B360Projects -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged | where {$_.name -like "*$Private:ProjectName*"}

    return $B360Project
}


function Get-B360ProjectFromAPI
{
    <#
    .SYNOPSIS
    DEPRECATED -- superseded by Get-ACCProjectFromAPI.

    .DESCRIPTION
    Forwards to the construction/admin/v1 project endpoint, which (unlike hq/v1) accepts 3-legged
    tokens and so respects the signed-in user's access.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        $ProjectId,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault,

        # Force the app-level (2-Legged) flow. ACC Admin endpoints reject a *pure* 2-legged
        # token, so -OnBehalfOf must be supplied alongside this.
        [Switch]
        $TwoLegged,

        # Autodesk id of the user to act on behalf of (sent as the x-user-id header).
        [Parameter()]
        $OnBehalfOf
    )

    Write-ForgeDeprecationWarning 'Get-B360ProjectFromAPI' 'Get-ACCProjectFromAPI'

    return Get-ACCProjectFromAPI -Hub $Hub -ProjectId $ProjectId -Force:$Force `
        -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -OnBehalfOf $OnBehalfOf
}



function Add-ProjectAdmin
{
    <#
    .SYNOPSIS
    DEPRECATED -- superseded by Add-ACCProjectUser -Admin.

    .DESCRIPTION
    Forwards to the construction/admin/v1 project-users endpoint. The hq/v1 -ServiceType concept
    (doc_manager, collab, ...) does not exist in ACC Admin, which grants access per product
    instead; -ServiceType is accepted for compatibility but ignored. Use Add-ACCProjectUser
    -Products for fine-grained product access.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ HubUserCompleter @args })]
        $User,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        # Ignored. Retained so existing scripts keep parsing; ACC grants access per product.
        [Parameter()]
        [ArgumentCompleter({ AdminServiceTypeCompleter @args })]
        $ServiceType,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault,

        # Force the app-level (2-Legged) flow. ACC Admin endpoints reject a *pure* 2-legged
        # token, so -OnBehalfOf must be supplied alongside this.
        [Switch]
        $TwoLegged,

        # Autodesk id of the user to act on behalf of (sent as the x-user-id header).
        [Parameter()]
        $OnBehalfOf
    )

    Write-ForgeDeprecationWarning 'Add-ProjectAdmin' 'Add-ACCProjectUser -Admin'

    if ($ServiceType)
    {
        Write-Warning "Add-ProjectAdmin: -ServiceType ('$ServiceType') is ignored; ACC Admin grants access per product. Use Add-ACCProjectUser -Products for fine-grained control."
    }

    return Add-ACCProjectUser -Hub $Hub -Project $Project -User $User -Admin -Force:$Force `
        -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -OnBehalfOf $OnBehalfOf
}


function New-B360Project
{
    <#
    .SYNOPSIS
    DEPRECATED -- superseded by New-ACCProject.

    .DESCRIPTION
    Forwards to the construction/admin/v1 project-creation endpoint, which (unlike hq/v1) accepts
    3-legged tokens. After the project is created, the -Admin user is granted project
    administration via Add-ACCProjectUser -Admin.

    Several hq/v1-only parameters have no ACC Admin equivalent and are ignored with a warning:
    -ServiceTypes, -AdminServiceTypes, -ContractType, -Language, -BusinessUnitId,
    -IncludeLocations, -IncludeCompanies. ACC's nearest analogue to -ContractType is exposed
    directly by New-ACCProject as -DeliveryMethod.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ HubUserCompleter @args })]
        $Admin,

        [Parameter(Mandatory)]
        $ProjectName,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $StartDate,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ DateCompleter @args })]
        [ValidateScript({ DateValidator })]
        $EndDate,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectTypeCompleter @args })]
        [ValidateScript({ ProjectTypeValidator })]
        $ProjectType,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ MoneyValueCompleter @args })]
        [ValidateScript({ MoneyValueValidator })]
        $MoneyValue,

        [Parameter(Mandatory)]
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
        [ValidatePattern("^\d\d\d\d\d$")]
        $PostalCode,

        [Parameter()]
        [ArgumentCompleter({ CountryCompleter @args })]
        [ValidateScript({ CountryValidator })]
        $Country,

        [Parameter()]
        [ArgumentCompleter({ StateCompleter @args })]
        $StateOrProvince,

        [Parameter()]
        [ArgumentCompleter({ TimezoneCompleter @args })]
        [ValidateScript({ TimezoneValidator })]
        $Timezone,

        [Parameter()]
        [ArgumentCompleter({ ConstructionTypeCompleter @args })]
        [ValidateScript({ ConstructionTypeValidator })]
        $ConstructionType,

        [Parameter()]
        $TemplateProjectId,

        # --- accepted for compatibility, ignored (no ACC Admin equivalent) ---
        [Parameter()]
        $ServiceTypes,

        [Parameter()]
        $AdminServiceTypes,

        [Parameter()]
        $ContractType,

        [Parameter()]
        $Language,

        [Parameter()]
        $BusinessUnitId,

        [Switch]
        $IncludeLocations,

        [Switch]
        $IncludeCompanies,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault,

        # Force the app-level (2-Legged) flow. ACC Admin endpoints reject a *pure* 2-legged
        # token, so -OnBehalfOf must be supplied alongside this.
        [Switch]
        $TwoLegged,

        # Autodesk id of the user to act on behalf of (sent as the x-user-id header).
        [Parameter()]
        $OnBehalfOf
    )

    Write-ForgeDeprecationWarning 'New-B360Project' 'New-ACCProject'

    # tell the caller plainly about anything the ACC Admin API cannot express
    $Ignored = @()
    foreach ($n in 'ServiceTypes','AdminServiceTypes','ContractType','Language','BusinessUnitId','IncludeLocations','IncludeCompanies')
    {
        if ($PSBoundParameters.ContainsKey($n)) {$Ignored += "-$n"}
    }
    if ($Ignored.Count -gt 0)
    {
        Write-Warning "New-B360Project: $($Ignored -join ', ') have no ACC Admin equivalent and were ignored. (ACC's nearest analogue to -ContractType is New-ACCProject -DeliveryMethod.)"
    }

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged

    $acc_args = @{
        Hub = $Hub
        ProjectName = $ProjectName
        ProjectType = $ProjectType
        StartDate = $StartDate
        EndDate = $EndDate
        MoneyValue = $MoneyValue
        Currency = $Currency
        Force = $Force
        ThreeLegged = $ThreeLegged
        TwoLegged = $TwoLegged
    }

    # optional parameters
    if ($JobNumber)         {$acc_args['JobNumber']         = $JobNumber}
    if ($AddressLine1)      {$acc_args['AddressLine1']      = $AddressLine1}
    if ($AddressLine2)      {$acc_args['AddressLine2']      = $AddressLine2}
    if ($City)              {$acc_args['City']              = $City}
    if ($StateOrProvince)   {$acc_args['StateOrProvince']   = $StateOrProvince}
    if ($PostalCode)        {$acc_args['PostalCode']        = $PostalCode}
    if ($Country)           {$acc_args['Country']           = $Country}
    if ($Timezone)          {$acc_args['Timezone']          = $Timezone}
    if ($ConstructionType)  {$acc_args['ConstructionType']  = $ConstructionType}
    if ($TemplateProjectId) {$acc_args['TemplateProjectId'] = $TemplateProjectId}
    if ($OnBehalfOf)        {$acc_args['OnBehalfOf']        = $OnBehalfOf}

    $B360Project = New-ACCProject @acc_args

    if ($B360Project)
    {
        # the freshly-created project is not in the Data Management project list yet, so carry the
        # Hub on the object for the ConvertTo-* coercions inside Add-ACCProjectUser
        $null = Add-Member -InputObject $B360Project -NotePropertyName 'hub' -NotePropertyValue $Hub -Force

        $null = Add-ACCProjectUser -Hub $Hub -Project $B360Project -User $Admin -Admin `
            -Force:$Force -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -OnBehalfOf $OnBehalfOf
    }

    return $B360Project
}


# BIM 360 API - Project Roles ____________________________________________________________________________________

function Get-ProjectRoles
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/admin-v1-projects-projectId-users-GET/
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

    # get $ProjectRoles from cloud source or local cache
    if ((-not $Project.roles) -or ($Force))
    {
        $AccountId = ConvertTo-B360Id $Hub.id
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = # NOTE: hq/v1|v2 account-admin endpoints only accept 2-legged tokens
        # (see Autodesk request HQ-5133), so -ThreeLegged is ignored here.
        Get-AccessToken -Scope "account:read" -TwoLegged
        $request = @{
            Uri = "https://developer.api.autodesk.com/hq/v2/accounts/$AccountId/projects/$ProjectId/industry_roles"
            Method = "GET"
            Headers = @{ Authorization = "$($AccessToken.token_type) $($AccessToken.access_token)" }
        }
        $response = Invoke-RestMethod @request
        # cache request,response pair for debugging
        $null = $Global:RequestResponseHistory.Add(@{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        })

        $ProjectRoles = $response
    }
    else
    {
        $ProjectRoles = $Project.roles
    }

    # cache $ProjectRoles in $Project object
    if ($ProjectRoles)
    {
        $null = Add-Member -InputObject $Project -NotePropertyName 'roles' -NotePropertyValue $ProjectRoles -Force
        return $ProjectRoles
    }
    else
    {
        throw "ProjectRoles not found."
    }
}


function ProjectRoleCompleter
{
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

    # Never start an interactive sign-in from tab-completion (see HubNameCompleter).
    if (-not (Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -NonInteractive))
    {
        return '<#  Not signed in -- run Connect-Forge first  #>'
    }

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $ProjectRoles = Get-ProjectRoles $Hub $Project -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectRoleList =  $ProjectRoles | foreach {$_.name}

    $completer_args = @{
        CompletionsList = $ProjectRoleList
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    # match on name
   StandardCompleter @completer_args
}


function Get-ProjectRole
{
    <#
    
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
        [ArgumentCompleter({ ProjectRoleCompleter @args })]
        $RoleName,

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

    $ProjectRole = Get-ProjectRoles $Hub $Project | where {$_.name -eq $RoleName}

    return $ProjectRole
}



# BIM 360 API - Project Permissions ______________________________________________________________________________





# BIM 360 API - Project Users ____________________________________________________________________________________

function Get-ProjectUsers
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/admin-v1-projects-projectId-users-GET/
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

    if ( (-not $Project.users) -or ($Force) )
    {
        $ProjectUsers = [System.Collections.ArrayList]@()
        $ProjectId = ConvertTo-B360Id $Project.id
        $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

        function batch ($uri="https://developer.api.autodesk.com/construction/admin/v1/projects/$ProjectId/users?limit=200")
        {
            $request = @{
                Uri = $uri
                Method = "GET"
                Headers = @{
                    "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"
                }
            }

            $response = Invoke-RestMethod @request

            # cache request,response pair for debugging
            $null = $Global:RequestResponseHistory.Add(
                @{
                    function = $MyInvocation.MyCommand.Name
                    request = $request
                    response = $response
                }
            )

            $response.results | foreach {$null = $ProjectUsers.Add($_)}

            # pagination docs: https://forge.autodesk.com/en/docs/data/v2/developers_guide/filtering/#pagination
            if ($response.pagination.nextUrl)
            {
                batch $response.pagination.nextUrl
            }
        }

        batch
    }
    else
    {
        $ProjectUsers = $Project.users
    }

    if ($ProjectUsers)
    {   
        $Project | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'users' -NotePropertyValue $ProjectUsers -Force
        }

        $ProjectUsers | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'project' -NotePropertyValue $Project -Force
        }

        return $ProjectUsers
    }
    else
    {
        throw "ProjectUsers not found."
    }
}


function ProjectUserCompleter
{
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
    
    # pull params out of $FakeBoudParameters for shorter reference
    if ($FakeBoundParameters.Hub) {$Hub = $FakeBoundParameters.Hub}
    if ($FakeBoundParameters.Project) {$Project = $FakeBoundParameters.Project}
    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ContainsKey('ThreeLegged')) {$ThreeLegged = [Bool]$FakeBoundParameters.ThreeLegged} else {$ThreeLegged = $Global:ForgeThreeLeggedByDefault}
    if ($FakeBoundParameters.ContainsKey('TwoLegged')) {$TwoLegged = [Bool]$FakeBoundParameters.TwoLegged} else {$TwoLegged = $false}

    # Never start an interactive sign-in from tab-completion (see HubNameCompleter).
    if (-not (Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged -TwoLegged:$TwoLegged -NonInteractive))
    {
        return '<#  Not signed in -- run Connect-Forge first  #>'
    }

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $ProjectUsers = Get-ProjectUsers -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectUserDict = @{}
    $ProjectUsers | foreach { $null = $ProjectUserDict.Add($_.email,$_.name) }

    $completer_args = @{
        CommentsDict = $ProjectUserDict
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    switch ($ParameterName)
    {
        'Email' {$Completions = CommentedCompleterFromKeys @completer_args}
        'Name' {$Completions = CommentedCompleterFromValues @completer_args}
        'User' {$Completions = CommentedCompleterFromKeys @completer_args}
    }

    $Completions | foreach {$_}
}


function Get-ProjectUser
{
    <#
        .SYNOPSIS
        Get a single User from a Project, by name or by email.
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
        [ArgumentCompleter({ ProjectUserCompleter @args })]
        $Name,

        [Parameter()]
        [ArgumentCompleter({ ProjectUserCompleter @args })]
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
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    if ($Name) {$User = $Name} elseif ($Email) {$User = $Email}

    $ProjectUser = Get-ProjectUsers -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.email -eq $User}

    return $ProjectUser
}


function UserCompleter
{
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

    $completer_args = @{
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    switch ($null -ne $FakeBoundParameters.Project)
    {
        $true {$Completions = ProjectUserCompleter @completer_args}
        $false {$Completions = HubUserCompleter @completer_args}
    }

    $Completions | foreach {$_}
}


function ConvertTo-User
{
    <#
    .SYNOPSIS
    Coerce $User to [User] from (tab-completed) [String].
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
        [ArgumentCompleter({ UserCompleter @args })]
        [AllowNull()]
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
    
    if ($null -eq $User)
    {
        return $null
    }
    elseif (($User -is [PSCustomObject]) -and ($null -ne $User.id))
    {
        return $User
    }
    elseif ($User -is [String])
    {
        $Hub = ConvertTo-Hub -Hub:$Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged

        if ($null -ne $Project)
        {
            $Hub = $Project.hub
        }
        if ($null -eq $Hub)
        {
            throw "Can't convert User:  No valid Hub provided."
        }
        elseif ($null -eq $Project)
        {
            $User = Get-HubUser -Hub $Hub -Email $User -Force:$Force -ThreeLegged:$ThreeLegged
            return $User
        }
        else
        {
            $User = Get-ProjectUser -Hub $Hub -Project $Project -Email $User -Force:$Force -ThreeLegged:$ThreeLegged
            return $User
        }
    }
    else
    {
        throw "Can't convert User:  User is unexpected type."
    }
}


function Format-UserForProjectImport
{
    <#
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter()]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $Project,

        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ UserCompleter @args })]
        $User,

        # Make user a project admin
        [Parameter()]
        [Alias('a')]
        [Switch]
        $Admin,

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
    $User = ConvertTo-User -Hub $Hub -Project $Project -User $User -Force:$Force -ThreeLegged:$ThreeLegged

    # email
    $UserDict = @{}

    if ($User.email)
    {
        $UserDict.email = $User.email
    }
    else
    {
        throw "Couldn't find User email."
    }

    # company_id
    if ($User.company_id)
    {
        $UserDict.companyId = $User.company_id
    }
    elseif ($User.companyId)
    {
        $UserDict.companyId = $User.companyId
    }
    elseif ($User.Project)
    {
        $HubUser = Get-HubUser -Hub $User.project.hub -Email $User.Email

        if ($HubUser.company_id)
        {
            $UserDict.companyId = [System.Collections.ArrayList]@($HubUser.default_role_id)
        }
    }
    else
    {
        $UserDict.companyId = '' # BAD! AVOID THIS!
    }

    # # admin/User
    # if (
    #     ($User.access_level -in ('project_admin','account_admin')) `
    #     -or ($User.accessLevels.projectAdmin -eq $true) `
    #     -or ($User.accessLevels.accountAdmin -eq $true) `
    #     -or ($Admin)
    # )
    # {
    #     $UserDict.services = @{
    #         project_administration = @{
    #             access_level = 'admin'
    #         }
    #         document_management = @{
    #             access_level = 'admin'
    #         }
    #     }
    # }
    # else
    # {
    #     $UserDict.services = @{
    #         document_management = @{
    #             access_level = 'user'
    #         }
    #     }
    # }

    # admin/User
    if (
        ($User.access_level -in ('project_admin','account_admin')) `
        -or ($User.accessLevels.projectAdmin -eq $true) `
        -or ($User.accessLevels.accountAdmin -eq $true) `
        -or ($Admin)
    )
    {
        $UserDict.products = @(
            @{
                key = 'projectAdministration'
                access = 'administrator'
            },
            @{
                key = 'docs'
                access = 'administrator'
            }
        )
    }
    else
    {
        $UserDict.products = @(
            ,
            @{
                key = 'docs'
                access = 'member'
            }
        )
    }

    # role(s)
    if ($User.roleIds)
    {
        $UserDict.roleIds = [System.Collections.ArrayList]$User.roleIds
    }
    elseif ($User.default_role_id)
    {
        $UserDict.roleIds = [System.Collections.ArrayList]@($User.default_role_id)
    }
    elseif ($User.project)
    {
        $HubUser = Get-HubUser -Hub $User.project.hub -Email $User.Email

        if ($HubUser.default_role_id)
        {
            $UserDict.roleIds = [System.Collections.ArrayList]@($HubUser.default_role_id)
        }
    }
    else
    {
        $UserDict['roleIds'] = [System.Collections.ArrayList]@()
    }

    return $UserDict
}


function Add-ProjectUsers
{
    <#
        .SYNOPSIS
        Add a single User to a Project, by name or by email.

        .LINK
        https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-project_id-users-import-POST/
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
        $Users,

        # Make users project admins
        [Parameter()]
        [Alias('a')]
        [Switch]
        $Admin,

        # Force reload local cache from source
        [Parameter()]
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Parameter()]
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    # gather other info for REST API call
    $AccountId = $Hub.id | ConvertTo-B360Id
    $ProjectId = $Project.id | ConvertTo-B360Id
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged

    # format UsersList for REST API call
    $ExistingUserIds = Get-ProjectUsers -Hub $Hub -Project $Project | foreach {$_.id}
    $UsersList = [System.Collections.ArrayList]@()

    foreach ($User in $Users)
    {
        if ($User.id -in $ExistingUserIds)
        {
            Write-Host "User already in Project: $($User.name) ($($User.email))"
        }
        else
        {   Write-Verbose "Formatting $($User.name) ($($User.email)) for project import..."
            $UserDict = Format-UserForProjectImport -User $User -Admin:$Admin -Force:$Force -ThreeLegged:$ThreeLegged
            Write-Verbose "DONE Formatting $($User.name) ($($User.email)) for project import."
            Write-Verbose "Adding $($User.name) ($($User.email)) to UsersList..."
            $null = $UsersList.Add($UserDict)
            Write-Verbose "DONE Adding $($User.name) ($($User.email)) to UsersList."
        }
    }
    $UsersList = @{'users' = $UsersList}

    function batch ($ulist)
    {
        Write-Verbose "Running Add-ProjectUsers batch with $($ulist.count) users..."

        $request = @{
            Uri = "https://developer.api.autodesk.com/construction/admin/v2/projects/$ProjectId/users:import"
            Method = "POST"
            Headers = @{
                "Content-Type" = "application/json"
                "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"
            }
            Body = ConvertTo-Json $ulist -Depth 8
        }

        $response = Invoke-RestMethod @request

        $request.Body = $ulist

        $null = $Global:RequestResponseHistory.Add(@{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        })

        Write-Verbose "DONE Running Add-ProjectUsers batch with $($ulist.count) users."
        return $response
    }


    $responses = [System.Collections.ArrayList]@()

    if ($UsersList.Count -eq 0)
    {
        Write-Host "No users to add."
    }
    elseif ($UsersList.Count -le 50)
    {
        $responses.Add((batch $UsersList))
    }
    else
    {
        Write-Verbose "Splitting UsersList into batches of 50 users..."
        $batches = Split-Every $UsersList 50
        Write-Verbose "DONE Splitting UsersList into batches of 50 users."
        Write-Verbose "Batches: $($batches.count)"
        foreach ($b in $batches) {$responses.Add((batch $b))}
        
    }

    # Force update $Project.users
    $null = Get-ProjectUsers -Hub $Hub -Project $Project -Force -ThreeLegged:$ThreeLegged
    
    return $responses
}

function Add-ProjectUser
{
    <#
        .SYNOPSIS
        Add a single User to a Project, by name or by email.

        .LINK
        https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-project_id-users-import-POST/
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

        # Make users project admins
        [Parameter()]
        [Alias('a')]
        [Switch]
        $Admin,

        # Force reload local cache from source
        [Parameter()]
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Parameter()]
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )
    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub:$Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub
    $User = ConvertTo-User -Hub $Hub -User $User -Force:$Force -ThreeLegged:$ThreeLegged

    $response = Add-ProjectUsers -Hub $Hub -Project $Project -Users @(,$User) -Admin:$Admin -Force:$Force -ThreeLegged:$ThreeLegged

    return $response
}

function Add-UserToAllProjects
{
    <#
        .SYNOPSIS

        .LINK

    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ HubUserCompleter @args })]
        $User,

        # Make users project admins
        [Parameter()]
        [Alias('a')]
        [Switch]
        $Admin,

        # Force reload local cache from source
        [Parameter()]
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged (user) OAuth flow, so results are scoped to what the signed-in Autodesk
        # user can see. Defaults to $Global:ForgeThreeLeggedByDefault; pass -ThreeLegged:$false
        # for the app-level 2-Legged flow.
        [Parameter()]
        [Switch]
        $ThreeLegged = $Global:ForgeThreeLeggedByDefault
    )
    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $User = ConvertTo-User -Hub $Hub -User $User -Force:$Force -ThreeLegged:$ThreeLegged
    
    Get-Projects -Hub:$Hub | foreach {
        Add-ProjectUser -Hub:$Hub -Project:$_ -User:$User -Admin:$Admin -Force:$Force -ThreeLegged:$ThreeLegged
    }
}
