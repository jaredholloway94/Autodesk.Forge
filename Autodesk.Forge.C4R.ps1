#   "Autodesk Forge PowerShell Cmdlets - Data Management API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Collaboration for Revit (C4R) - Local Revit Files ______________________________________________________________

function Get-C4RProjectId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $CloudFile
    )
    return $CloudFile.attributes.extension.data.projectGuid
}

function Get-C4RModelId {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $CloudFile
    )
    return $CloudFile.attributes.extension.data.modelGuid
}


function Open-LocalRevitFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        $CloudFile
    )

    $pGuid = Get-C4RProjectId $CloudFile
    $mGuid = Get-C4RModelId $CloudFile
    $fileName = $CloudFile.attributes.name

    $LocalFile = Get-ChildItem "$env:LOCALAPPDATA\Autodesk\Revit" -Recurse |
        where {$_.FullName -like "*$pGuid\$mGuid.rvt"}
    Write-Host " "
    if (!$LocalFile){
        Write-Host "Can't find local copy of $fileName."
        Write-Host "You must open the file manually (thru Revit interface) at least once before this cmdlet will work."
    } else {
        $RevitVersion = $LocalFile.FullName.ToString().Split('\') |
            where {$_.StartsWith("Autodesk Revit ")} |
            foreach {$_.Substring(15)}
        $RevitBin = "$env:ProgramFiles\Autodesk\Revit $RevitVersion\Revit.exe"
        if (Get-UserInputYesNo "Found local copy of $fileName." "Would you like to open it?") {
            Write-Host "Opening $fileName in Revit $RevitVersion."
            & $RevitBin $LocalFile.FullName
        }
    }
    Write-Host " "
}