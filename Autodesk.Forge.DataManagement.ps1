#   "Autodesk Forge PowerShell Cmdlets - Data Management API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


. (Join-Path $PSScriptRoot "Autodesk.Forge.Enums.ps1")
. (Join-Path $PSScriptRoot "Autodesk.Forge.Utils.ps1")




# DM-Hubs ________________________________________________________________________________________________________

function Get-Hubs
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/data/v2/reference/http/hubs-GET/
    #>

    [CmdletBinding()]

    param
    (   
        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    
    if ( (-not $Global:Hubs) -or ($Force) )
    {
        $AccessToken = Get-AccessToken -Scope "data:read" -Force:$Force -ThreeLegged:$ThreeLegged

        $request = @{
            Uri = "https://developer.api.autodesk.com/project/v1/hubs/"
            Method = "GET"
            Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
        }
        $response = Invoke-RestMethod @request
        $null = $Global:RequestResponseHistory.Add(@{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        })

        $Global:Hubs = $response.data
    }

    if ( ($null -ne $Global:Hubs) )
    {
        return $Global:Hubs
    }
    else
    {
        throw "Hubs not found."
    }
}

<# useless API function

function Get-Hub
{
    <
    .LINK
    https://forge.autodesk.com/en/docs/data/v2/reference/http/hubs-hub_id-GET/
    >

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory)]
        $Hub
    )

    $HubId = $Hub.id
    $AccessToken = Get-AccessToken -Scope "data:read"
    $response = Invoke-RestMethod `
        -Uri "https://developer.api.autodesk.com/project/v1/hubs/$HubId" `
        -Method "GET" `
        -Headers @{
            "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"
        }
    $Hub = $response.data

    return $Hub
}

#>

function HubNameCompleter
{

    <#
    .SYNOPSIS
    Provide tab-completion for Hub names.
    #>

    [CmdletBinding()]

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

    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

    $HubNames = Get-Hubs -Force:$Force -ThreeLegged:$ThreeLegged | foreach {$_.attributes.name}

    $completer_args = @{
        CompletionsList = $HubNames
        CommandName = $CommandName
        ParameterName = $ParameterName
        WordToComplete = $WordToComplete
        CommandAst = $CommandAst
        FakeBoundParameters = $FakeBoundParameters
    }

    StandardCompleter @completer_args
}

function Get-Hub
{
    <#
    .SYNOPSIS
    Get one Hub by fuzzy name match.
    #>
    
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $HubName,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    $Hub = Get-Hubs -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.attributes.name -like "*$HubName*"}

    return $Hub
}


function ConvertTo-Hub
{
    <#
    .SYNOPSIS
    Coerce $Hub to [Hub] from (tab-completed) [String].
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        [AllowNull()]
        $Hub,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    
    if ($null -eq $Hub)
    {
        return $null
    }
    elseif (($Hub -is [PSCustomObject]) -and ($Hub.type) -and ($Hub.type -eq 'hubs'))
    {
        return $Hub
    }
    elseif ($Hub -is [String])
    {
        $Hub = Get-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        return $Hub
    }
    else
    {
        throw "`$Hub is unexpected type."
    }
}


# DM-Projects ____________________________________________________________________________________________________


function Get-Projects
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/data/v2/reference/http/hubs-hub_id-projects-GET/
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

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # coerce $Hub to [Hub] from (tab-completed) [string]
    $Hub = ConvertTo-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    
    if ((-not $Hub.projects) -or ($Force))
    {
        # get $Projects from API call
        $HubId = $Hub.id
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged
        $request = @{
            Uri = "https://developer.api.autodesk.com/project/v1/hubs/$HubId/projects"
            Method = "GET"
            Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
        }
        $response = Invoke-RestMethod @request
        $null = $Global:RequestResponseHistory.Add(@{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        })
        $Projects = $response.data
    }
    else
    {
        # get $Projects from $Hub.projects cache
        $Projects = $Hub.projects
    }
    
    if ($null -ne $Projects)
    {
        # cache $Hub in each $Project; cache $Projects in $Hub; return $Projects
        $Projects | foreach {
            Add-Member -InputObject $_ -NotePropertyName 'hub' -NotePropertyValue $Hub -Force
        }

        $Hub | foreach {
            Add-Member -InputObject $_ -NotePropertyName 'projects' -NotePropertyValue $Projects -Force
        }

        return $Projects
    }
    else
    {
        # don't know what to do, so throw terminating error
        throw "Projects not found."
    }
}


function ProjectNameCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for Project names.
    #>

    [CmdletBinding()]

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

    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}
    
    if ($FakeBoundParameters.Hub)
    {
        $Hub = ConvertTo-Hub $FakeBoundParameters.Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $ProjectNames = Get-Projects $Hub -Force:$Force -ThreeLegged:$ThreeLegged |
        foreach {$_.attributes.name}

        $completer_args = @{
            CompletionsList = $ProjectNames
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }
    
        $Completions = StandardCompleter @completer_args
    }
    else
    {
        $Completions = @('<#  !!! Provide $Hub parameter value first !!!  #>')
    }

    $Completions | foreach {$_}
}


function Get-Project
{
    <#
    .SYNOPSIS
    Get one Project by fuzzy name match.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        $ProjectName,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    # coerce $Hub to [Hub] from (tab-completed) [String]
    $Hub = ConvertTo-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged

    $Project = Get-Projects $Hub -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.attributes.name -like "*$ProjectName*"}
    
    return $Project
}


function Get-ProjectFromAPI
{
    <#
        .SYNOPSIS
        Get one Project by exact Id.

        .LINK
        https://forge.autodesk.com/en/docs/data/v2/reference/http/hubs-hub_id-projects-project_id-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        $Hub,

        [Parameter(Mandatory)]
        $Project,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    # coerce $Hub to [Hub] from (tab-completed) [String]
    $Hub = ConvertTo-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $HubId = $Hub.id | ConvertFrom-B360Id
    $Project = ConvertTo-
    $ProjectId = $ProjectId | ConvertFrom-B360Id

    $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged
    $request = @{
        Uri = "https://developer.api.autodesk.com/project/v1/hubs/$HubId/projects/$ProjectId"
        Method = "GET"
        Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
        ContentType = 'application/json'
    }
    $response = Invoke-RestMethod @request
    $null = $Global:RequestResponseHistory.Add(@{
        function = $MyInvocation.MyCommand.Name
        request = $request
        response = $response
    })

    $Project = $response.data
    
    return $Project
}


function ConvertTo-Project
{
    <#
    .SYNOPSIS
    Coerce $Project to [Project] from (tab-completed) [String].
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory)]
        [ArgumentCompleter({ HubNameCompleter @args })]
        [AllowNull()]
        $Hub,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ ProjectNameCompleter @args })]
        [AllowNull()]
        $Project,
        
        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    
    if ($null -eq $Project)
    {
        return $null
    }
    elseif (($Project -is [PSCustomObject]) -and ($Project.type) -and ($Project.type -eq 'projects'))
    {
        return $Project
    }
    elseif ($Project -is [String])
    {
        $Hub = ConvertTo-Hub -Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = Get-Project -Hub $Hub -ProjectName $Project -Force:$Force -ThreeLegged:$ThreeLegged
        return $Project
    }
    else
    {
        throw "`$Project is unknown type."
    }
}


function Get-RootFolders
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/data/v2/reference/http/hubs-hub_id-projects-project_id-topFolders-GET/
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

    $Hub = ConvertTo-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project $Hub $Project -Force:$Force -ThreeLegged:$ThreeLegged
    
    if ((-not $Project.root_folders) -or ($Force))
    { 
        $HubId = $Hub.id
        $ProjectId = $Project.id
        $AccessToken = Get-AccessToken -Scope "data:read"

        $request = @{
            Uri = "https://developer.api.autodesk.com/project/v1/hubs/$HubId/projects/$ProjectId/topFolders?projectFilesOnly=true"
            Method = "GET"
            Headers = @{"Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"}
        }
        $response = Invoke-RestMethod @request
        $null = $Global:RequestResponseHistory.Add(@{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        })

        $RootFolders = $response.data
    }
    else
    {
        $RootFolders = $Project.root_folders
    }

    if ($RootFolders)
    {
        $RootFolders | foreach {
            Add-Member -InputObject $_ -NotePropertyName project -NotePropertyValue $Project -Force
        }

        $Project | foreach {
            Add-Member -InputObject $_ -NotePropertyName root_folders -NotePropertyValue $RootFolders -Force
        }
        return $RootFolders
    }
    else
    {
        throw "Root Folders not found."
    }
}

function Get-ProjectFiles
{
    <#
    .SYNOPSIS
    Get the "Project Files" folder of a Project (common use case warranting its own function).
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

    $Hub = ConvertTo-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
    $Project = ConvertTo-Project $Hub $Project -Force:$Force -ThreeLegged:$ThreeLegged

    $ProjectFilesFolder = Get-RootFolders $Hub $Project -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.attributes.name -like "Project Files"}

    return $ProjectFilesFolder
}


# DM-Folders _____________________________________________________________________________________________________

<# useless API function

function Get-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder
    )
    
    # https://forge.autodesk.com/en/docs/data/v2/reference/http/projects-project_id-folders-folder_id-GET/
    
    $AccessToken = Get-AccessToken -Scope "data:read"
    $ProjectId = $Folder.project.id
    $FolderId = $Folder.id
    $response = Invoke-RestMethod `
        -Uri "https://developer.api.autodesk.com/data/v1/projects/$ProjectId/folders/$FolderId" `
        -Method "GET" `
        -Headers @{
            "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"
        }
    $Folder = $response.data
    return $Folder
}

#>

function Get-Contents
{
    <#
    .LINK
    https://forge.autodesk.com/en/docs/data/v2/reference/http/projects-project_id-folders-folder_id-contents-GET/
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,

        # Include deleted (aka 'hidden') items in results
        [Alias('h')]
        [Switch]
        $IncludeHidden,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    
    if ((-not $Folder.contents) -or ($Force))
    {
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged:$ThreeLegged
        $ProjectId = $Folder.project.id
        $FolderId = $Folder.id

        $request = @{
            Uri = "https://developer.api.autodesk.com/data/v1/projects/$ProjectId/folders/$FolderId/contents?includeHidden=$IncludeHidden"
            Method = "GET"
            Headers = @{Authorization = "$($AccessToken.token_type) $($AccessToken.access_token)"}
        }
        $response = Invoke-RestMethod $request
        $null = $Global:RequestResponseHistory.Add(@{
            function = $MyInvocation.MyCommand.Name
            request = $request
            response = $response
        })

        $Contents = $response.data
    }
    else
    {
        $Contents = $Folder.contents
    }

    if ($Contents)
    {
        $Contents | foreach {
            Add-Member -InputObject $_ -NotePropertyName 'parent' -NotePropertyValue $Folder -Force
            Add-Member -InputObject $_ -NotePropertyName 'project' -NotePropertyValue $Folder.project -Force
        }

        $Folder | foreach {
            Add-Member -InputObject $_ -NotePropertyName 'contents' -NotePropertyValue $Contents -Force
        }

        return $Contents
    }
    else
    {
        throw "Contents not found."
    }
}

function Get-Files
{
    <#
    .SYNOPSIS
    Get child Files from a Folder.
    #>
    
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,

        # Include deleted (aka 'hidden') items in results
        [Alias('h')]
        [Switch]
        $IncludeHidden,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )
    
    $Files = Get-Contents $Folder -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.type -ne "folders"}

    return $Files
}

function FileNameCompleter
{
    <#
    .SYNOPSIS
    Provide tab-completion for File names.
    #>
    
    [CmdletBinding()]
    
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
    
    if ($FakeBoundParameters.Force) {$Force = $true} else {$Force = $false}
    if ($FakeBoundParameters.ThreeLegged) {$ThreeLegged = $true} else {$ThreeLegged = $false}

    if (-not $args.Folder)
    {
        '<#  !!! Provide $Folder parameter value first !!!  #>'
    }
    else
    {
        $FileNames = Get-Files $Folder -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged |
        foreach {$_.attributes.displayName}

        $completer_args = @{
            CompletionsList = $FileNames
            CommandName = $CommandName
            ParameterName = $ParameterName
            WordToComplete = $WordToComplete
            CommandAst = $CommandAst
            FakeBoundParameters = $FakeBoundParameters
        }

        StandardCompleter @completer_args
    }
}

function Get-File
{
    <#
    .SYNOPSIS
    Pick one file from folder (with tab-completion).
    #>

    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ FileNameCompleter @args })]
        $File,

        # Include deleted (aka 'hidden') items in results
        [Alias('h')]
        [Switch]
        $IncludeHidden,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged


    )
    
    $File = Get-Files $Folder -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.attributes.displayName -eq "$File"}

    return $File
}

function Get-Folders
{
    <#
    .SYNOPSIS
    Get child Folders from a Folder.
    #>

    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,

        # Include deleted (aka 'hidden') items in results
        [Alias('h')]
        [Switch]
        $IncludeHidden,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    $Folders = Get-Contents $Folder -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged |
    where {$_.type -eq "folders"}
    
    return $Folders
}

function Search-Folder
{
    <#
    .SYNOPSIS
    Recursively search all files in $Folder for...
    #>
    
    [CmdletBinding()]
    
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,
    
        # $Results | where {$_.attributes.displayName -like "*$FileName*"}
        [Parameter()]
        $FileName,

        # $Results | where {$_.attributes.displayName -like "*$FileType"}
        [Parameter()]
        $FileType,

        # $Results | where {$_.parent.attributes.name -like "*$ParentName*"}
        [Parameter()]
        $ParentName,

        # Include deleted (aka 'hidden') items in results
        [Alias('h')]
        [Switch]
        $IncludeHidden,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged
    )

    # init collector array
    $Private:Results = [System.Collections.ArrayList]@()

    # add file-items to collector array
    $Private:FileItems = Get-Files $Folder -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged
    foreach ($FileItem in $FileItems) {$null = $Results.Add($FileItem)}

    # recurse on folder-items
    $Private:FolderItems = Get-Folders $Folder -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged
    foreach ($FolderItem in $FolderItems) {
        $Private:SubResults = Search-Folder $FolderItem -IncludeHidden:$IncludeHidden -Force:$Force -ThreeLegged:$ThreeLegged
        foreach ($SubResult in $SubResults) {$null = $Results.Add($SubResult)}
    }

    # filter collector array
    if ($FileName) { $Results = $Results | where {$_.attributes.displayName -like "*$FileName*"} }
    if ($FileType) { $Results = $Results | where {$_.attributes.displayName -like "*$FileType"} }
    if ($ParentName) { $Results = $Results | where {$_.parent.attributes.name -like "*$ParentName*"} }

    # return collector array
    return $Results
}

function Search-ProjectFiles
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
    
        # $Results | where {$_.attributes.displayName -like "*$FileName*"}
        [Parameter()]
        $FileName,

        # $Results | where {$_.attributes.displayName -like "*$FileType"}
        [Parameter()]
        $FileType,

        # $Results | where {$_.parent.attributes.name -like "*$FolderName*"}
        [Parameter()]
        $FolderName,

        # Include deleted (aka 'hidden') items in results
        [Alias('h')]
        [Switch]
        $IncludeHidden,

        # Force reload local cache from source
        [Alias('f')]
        [Switch]
        $Force,

        # Use 3-Legged OAuth flow, instead of default 2-Legged flow
        [Switch]
        $ThreeLegged,

        [Parameter(ValueFromPipeline)]
        $ProjectFiles
    )

    if (-not $ProjectFiles) {
        $Hub = ConvertTo-Hub $Hub -Force:$Force -ThreeLegged:$ThreeLegged
        $Project = ConvertTo-Project $Hub $Project -Force:$Force -ThreeLegged:$ThreeLegged
        $ProjectFiles = Get-ProjectFiles $Hub $Project -Force:$Force -ThreeLegged:$ThreeLegged
    }

    $search_args = @{
        Folder = $ProjectFiles 
        FileName = $FileName 
        FileType = $FileType 
        ParentName = $ParentName 
        IncludeHidden = $IncludeHidden 
        Force = $Force
        ThreeLegged = $ThreeLegged
    }

    $Results = Search-Folder @search_args

    return $Results
}


<# this garbage API function doesn't work ('known issue'):
   https://stackoverflow.com/questions/69809837/autodesk-forge-data-management-api-too-many-requests-on-search

function Search-FolderContents {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        $Folder,

        [Parameter()]
        [String]
        $FilterString
    )

    # https://forge.autodesk.com/en/docs/data/v2/reference/http/projects-project_id-folders-folder_id-search-GET/

    $AccessToken = Get-AccessToken -Scope "data:search data:read" -ThreeLegged
    $ProjectId = $Folder.project.id
    $FolderId = $Folder.id
    $response = Invoke-RestMethod `
        -Uri "https://developer.api.autodesk.com/data/v1/projects/$ProjectId/folders/$FolderId/search$FilterString" `
        -Method "GET" `
        -Headers @{
            "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"
        }
    $SearchResults = $response.data
    return $SearchResults
}

#>