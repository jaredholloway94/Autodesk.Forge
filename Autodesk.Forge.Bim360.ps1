#   "Autodesk Forge PowerShell Cmdlets - BIM 360 API "
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.DataManagement.ps1")


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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged

    if ((-not $Hub.users) -or ($Force))
    {
        $HubUsers = [System.Collections.ArrayList]@()
        $AccountId = $Hub.id | ConvertTo-B360Id
        $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged

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

    $HubUsers = Get-HubUsers `
    -Hub $FakeBoundParameters.Hub `
    -Force:$FakeBoundParameters.Force `
    -ThreeLegged:$FakeBoundParameters.ThreeLegged `

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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Parameter()]
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Parameter()]
        [Switch]
        $ThreeLegged
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
    .LINK
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged

    if ((-not $Hub.b360projects) -or ($Force))
    {
        $B360Projects = [System.Collections.ArrayList]@()
        $AccountId = $Hub.id | ConvertTo-B360Id
        $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged
        
        function batch ($i)
        {
            # BIM 360 API can only retrieve 100 Projects at a time. Use this to get all Projects in a Hub.
            $request = @{
                Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/projects?limit=100&offset=$i"
                Method = "GET"
                Headers = @{ Authorization = "$($AccessToken.token_type) $($AccessToken.access_token)" }
            }
            $response = Invoke-RestMethod @request
            $null = $Global:RequestResponseHistory.Add(@{
                function = $MyInvocation.MyCommand.Name
                request = $request
                response = $response
            })

            if ($response.data.Count -ne 0)
            {
                $response | foreach {$null = $B360Projects.Add($_)}
                $i += 100
                batch $i
            }
        }
        batch 0
    }
    else
    {
        $B360Projects = $Hub.b360projects
    }

    if ($B360Projects)
    {
        $B360Projects | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'hub' -NotePropertyValue $Hub -Force
        }

        $Hub | foreach {
            $null = Add-Member -InputObject $_ -NotePropertyName 'b360projects' -NotePropertyValue $B360Projects -Force
        }

        return $B360Projects
    }
    else
    {
        throw "B360Projects not found."
    }
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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
        Get one B360Project by exact id.

        .LINK
        https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-:project_id-GET/  
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        $ProjectId,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    # coerce $Hub to [Hub] from (tab-completed) [String]
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $AccountId = $Hub.id | ConvertTo-B360Id

    $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged
    $request = @{
        Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/projects/$ProjectId"
        Method = "GET"
        Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
    }
    $response = Invoke-RestMethod @request
    # cache request,response pair for debugging
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    $B360Project = $response

    return $B360Project
}



function Add-ProjectAdmin
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-project_id-users-POST/
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

        [Parameter(Mandatory)]
        [ArgumentCompleter({ AdminServiceTypeCompleter @args })]
        $ServiceType,

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
    $User = ConvertTo-User -Hub $Hub -User $User -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project -Hub $Hub -Project $Project -Force:$Force -ThreeLegged:$ThreeLegged
    $Hub = $Project.hub

    $AccountId = $Hub.id | ConvertTo-B360Id
    $ProjectId = $Project.id | ConvertTo-B360Id
    $AccessToken = Get-AccessToken -Scope "account:write" -ThreeLegged:$ThreeLegged
    $Body = @{
        role = 'project_admin'
        service_type = $ServiceType
        company_id = $User.company_id
        company_name = $User.company_name
        email = $User.email
        name = $User.name
        nickname = $User.nickname
        first_name = $User.first_name
        last_name = $User.lastName
        uid = $User.uid
        image_url = $User.image_url
        address_line_1 = $User.address_line_1
        address_line_2 = $User.address_line_2
        city = $User.city
        state_or_province = $User.state_or_province
        postal_code = $User.postal_code
        country = $User.country
        phone = $User.phone
        company = $User.company
        job_title = $User.job_title
        industry = $User.industry
        about_me = $User.about_me
    }

    $request = @{
        Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/projects/$ProjectId/users"
        Method = "POST"
        Headers = @{Authorization = "$($AccessToken.token_type) $($AccessToken.access_token)"}
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

    $ProjectAdmin = $response

    return $ProjectAdmin
}


function New-B360Project
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/bim360/v1/reference/http/projects-POST/
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
        [ArgumentCompleter({ ServiceTypeCompleter @args })]
        [ValidateScript({ ServiceTypeValidator })]
        $ServiceTypes = 'doc_manager',

        # services to init (using ProjectAdmin) after project is init'd
        [Parameter()]
        [ArgumentCompleter({ AdminServiceTypeCompleter @args })]
        [ValidateScript({ AdminServiceTypeValidator })]
        $AdminServiceTypes = 'doc_manager,collab',

        [Parameter()]
        [ArgumentCompleter({ ContractTypeCompleter @args })]
        [ValidateScript({ ContractTypeValidator })]
        $ContractType,

        [Parameter()]
        [ArgumentCompleter({ ConstructionTypeCompleter @args })]
        [ValidateScript({ ConstructionTypeValidator })]
        $ConstructionType,

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
        [ValidateScript({ StateValidator })]
        $StateOrProvince,

        [Parameter()]
        [ArgumentCompleter({ TimezoneCompleter @args })]
        [ValidateScript({ TimezoneValidator })]
        $Timezone,

        [Parameter()]
        [ArgumentCompleter({ LanguageCompleter @args })]
        [ValidateScript({ LanguageValidator })]
        $Language,
        
        [Parameter()]
        $BusinessUnitId,

        [Parameter()]
        $TemplateProjectId,

        [Switch]
        $IncludeLocations,

        [Switch]
        $IncludeCompanies,

        # Force update local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $AccountId = $Hub.id | ConvertTo-B360Id

    $Body = @{
        name = $ProjectName
        start_date = $StartDate
        end_date = $EndDate
        project_type = $ProjectType
        value = $MoneyValue
        currency = $Currency
    }

    # optional parameters
    if ($ServiceTypes)      {$Body["service_types"]         = $ServiceTypes}
    if ($JobNumber)         {$Body["job_number"]            = $JobNumber}
    if ($AddressLine1)      {$Body["address_line_1"]        = $AddressLine1}
    if ($AddressLine2)      {$Body["address_line_2"]        = $AddressLine2}
    if ($City)              {$Body['city']                  = $City}
    if ($StateOrProvince)   {$Body['state_or_province']     = $StateOrProvince}
    if ($PostalCode)        {$Body['postal_code']           = $PostalCode}
    if ($Country)           {$Body['country']               = $Country}
    if ($BusinessUnitId)    {$Body['business_unit_id']      = $BusinessUnitId}
    if ($TimeZone)          {$Body['timezone']              = $TimeZone}
    if ($Language)          {$Body['language']              = $Language}
    if ($ConstructionType)  {$Body['construction_type']     = $ConstructionType}
    if ($ContractType)      {$Body['contract_type']         = $ContractType}
    if ($TemplateProjectId) {$Body['template_project_id']   = $TemplateProjectId}
    if ($IncludeLocations)  {$Body['include_locations']     = 'true'}
    if ($IncludeCompanies)  {$Body['include_companies']     = 'true'}

    $AccessToken = Get-AccessToken -Scope "account:read account:write" -ThreeLegged:$ThreeLegged

    $request = @{
        Uri = "https://developer.api.autodesk.com/hq/v1/accounts/$AccountId/projects"
        Method = "POST"
        Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
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

    $B360Project = $response

    if ($B360Project)
    {
        $null = Add-ProjectAdmin -Hub $Hub -User $Admin -ProjectId $B360Project.id -ServiceType 'doc_manager' `
            -Force:$Force -ThreeLegged:$ThreeLegged
        $null = Add-ProjectAdmin -Hub $Hub -User $Admin -ProjectId $B360Project.id -ServiceType 'collab' `
            -Force:$Force -ThreeLegged:$ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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
        $AccessToken = Get-AccessToken -Scope "account:read" -ThreeLegged:$ThreeLegged
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
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Parameter()]
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Parameter()]
        [Switch]
        $ThreeLegged
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Parameter()]
        [Switch]
        $ThreeLegged
    )
    # coerce tab-completed args from strings to objects
    $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $User = ConvertTo-User -Hub $Hub -User $User -Force:$Force -ThreeLegged:$ThreeLegged
    
    Get-Projects -Hub:$Hub | foreach {
        Add-ProjectUser -Hub:$Hub -Project:$_ -User:$User -Admin:$Admin -Force:$Force -ThreeLegged:$ThreeLegged
    }
}
