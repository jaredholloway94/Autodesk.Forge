#   "Autodesk Forge PowerShell Cmdlets - Secrets"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Secrets ________________________________________________________________________________________________________

$Global:ForgeAppName = $null
$Global:CredDir = Join-Path $HOME ".credentials"
if (-not (Test-Path $Global:CredDir)) { mkdir $Global:CredDir }

function New-ForgeAppCredentials {

    param (
        [Parameter()]
        [String]
        $Local:ForgeAppName
    )

    if
    ( # ForgeAppName is not provided as a argument
        -not $Local:ForgeAppName
    )
    { # Get ForgeAppName from user
        $Local:ForgeAppName = Read-Host "AppName"
    }
    $ForgeAppCred = Get-Credential -Message "`nUser = Forge app Client Id`nPassword = Forge app Client Secret`n"
    $ForgeAppCredPath = Join-Path $Global:CredDir "ForgeAppCred-$Local:ForgeAppName.xml"
    $ForgeAppCred | Export-Clixml $ForgeAppCredPath
    

    return $ForgeAppCred
}

function ForgeAppNameCompleter {
    param (
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

    Get-ChildItem $Global:CredDir |
        foreach
        { 
            if
            (
                $_ -match "ForgeAppCred-(.*)\.xml"
            )
            {
                $matches[1]
            } 
        }
}


function Get-ForgeAppCredentials {

    param
    (
        [Parameter()]
        [String]
        [ArgumentCompleter({ ForgeAppNameCompleter @args })]
        $Local:ForgeAppName = $Global:ForgeAppName # allow user to provide ForgeAppName other than $Global:ForgeAppName
    )

    if
    ( # ForgeAppName is provided
        $Local:ForgeAppName
    )
    { # look for a matching ForgeAppCredFile
        $Local:ForgeAppCredPath = Join-Path $Global:CredDir "ForgeAppCred-$Local:ForgeAppName.xml"
        
        if 
        ( # the file exists
            Test-Path $ForgeAppCredPath
        )
        { # silently use it
            $ForgeAppCred = Import-Clixml $ForgeAppCredPath
        }
        else
        { # ask to create it
            $issue = "Could not find credential file for Forge app `'$Local:ForgeAppName`'."
            $prompt = "Would you like to create it now?"
            
            if
            ( # the user said 'yes'
                Get-UserInput -yn -Issue $issue -Prompt $prompt
            )
            { # create a new ForgeAppCredFile
                $ForgeAppCred = New-ForgeAppCredentials $Local:ForgeAppName
              # populate $Global:ForgeAppName, for use next time Get-ForgeAppCredentials is called
                $Global:ForgeAppName = $Local:ForgeAppName
            }
            else
            { # throw terminating error
                throw "No Forge app credentials found AND user chose not to create one."
            }
        }
    }
    else 
    { # look for any ForgeAppCredFile
        $ForgeAppCredFiles = Get-ChildItem $Global:CredDir | where { $_.BaseName.StartsWith('ForgeAppCred-') }

        switch ($ForgeAppCredFiles.Count)
        { # number of ForgeAppCredFiles found
            0
            { # ask to create a new one
                $issue = "No Forge app credentials found."
                $prompt = "Would you like to create one now?"
                
                if (Get-UserInput -yn -Issue $issue -Prompt $prompt)
                { # if the user said 'yes', create a new ForgeAppCredFile
                    $ForgeAppCred = New-ForgeAppCredentials
                }
                else
                { # if user said 'no', throw terminating error
                    throw "No Forge app credentials found AND user chose not to create one."
                }
            }
            1
            { # silently use it
                $ForgeAppCred = Import-Clixml $ForgeAppCredFiles[0].FullName
              # populate $Global:ForgeAppName, for use next time Get-ForgeAppCredentials is called
                $Global:ForgeAppName = $ForgeAppCredFiles[0].BaseName.Substring(13)
            }
            default
            { # ask which to use
                $issue = "Multiple Forge app credentials found:`n"
                $prompt = "Which one would you like to use?"
                $options = @( $ForgeAppCredFiles | foreach { $_.BaseName.Substring(13) } )
              # populate $Global:ForgeAppName, for use next time Get-ForgeAppCredentials is called
                $Global:ForgeAppName = Get-UserInput -mc -Issue $issue -Prompt $prompt -Options $options
                $ForgeAppCredFile = Get-Item (Join-Path $Global:CredDir "ForgeAppCred-$Global:ForgeAppName.xml")
                $ForgeAppCred = Import-Clixml $ForgeAppCredFile.FullName
            }
        }
    }

    return @{
        'id'= $ForgeAppCred.UserName
        'secret' = $ForgeAppCred.GetNetworkCredential().Password
    }
}

$null = Get-ForgeAppCredentials