#   "Autodesk Forge PowerShell Cmdlets - User Input"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# User Input _____________________________________________________________________________________________________

function Get-UserInputString {
    param($Issue,$Prompt)
    
    Write-Host "`n`n$Issue"
    $UserString = Read-Host "`n$Prompt"
    Write-Host "`n`n"
    return $UserString
}

function Get-UserInputMultipleChoice {
    param ($Issue,$Options,$Prompt)
    # tell the user why they are being asked a question
    Write-Host `n`n$Issue
    # tell the user what their options (valid responses) are
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $o = $Options[$i]
        Write-Host "$i)`t$o"
    }
    # ask the user the question, and capture the answer
    $UserInput = Read-Host "`n$Prompt"
    # while their answer is not an option (valid response), repeatedly...
    while ($UserInput -notin (0..($Options.Count-1))) {
        $OptionsEnum = [String]::Join( " | ", (0..($Options.Count-1)) )
        # ...remind them of the options and ask them to enter one of those
        $UserInput = Read-Host "`nPlease enter one of [ $OptionsEnum ]"
    }
    Write-Host "`n`n"
    # once we have a valid response, return it
    return $Options[$UserInput]
}

function Get-UserInputYesNo {
    param ($Issue,$Prompt)
    # tell the user why they are being asked a question
    Write-Host "`n`n$Issue"
    # ask the user the question, and capture the answer
    $UserInput = Read-Host "`n$Prompt"
    # while their answer is not an option (valid response), repeatedly...
    while ($UserInput -inotin @('y','n')) {
        # ...remind them of the options and ask them to enter one of those
        $UserInput = Read-Host "`nPlease enter 'y' or 'n'"
    }
    Write-Host "`n`n"
    switch ($UserInput) {
        'y' { return $true }
        'n' { return $false }
    }
}

function Get-UserInput {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory)]
        [String]
        $Issue,

        [Parameter(Mandatory)]
        [String]
        $Prompt,

        [Parameter()]
        [String[]]
        $Options,

        # Get-UserInputYesNo
        [Parameter()]
        [Switch]
        $yn,

        # Get-UserInputString
        [Parameter()]
        [Switch]
        $st,

        # Get-UserInputMultipleChoice
        [Parameter()]
        [Switch]
        $mc
    )

    <##>if ($yn) { return Get-UserInputYesNo $Issue $Prompt }
    elseif ($st) { return Get-UserInputString $Issue $Prompt }
    elseif ($mc) { return Get-UserInputMultipleChoice $Issue $Options $Prompt }
}