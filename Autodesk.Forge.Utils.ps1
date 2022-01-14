#   "Autodesk Forge PowerShell Cmdlets - Utils"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# Utils __________________________________________________________________________________________________________

function Format-Date
{
    <#
    Coerce input to [DateTime], then apply formatting required by Forge APIs.
    #>

    param
    (
        [Parameter(ValueFromPipeline)]
        $Date
    )
    
    return [DateTime]::Parse($Date).ToString("yyyy-MM-dd")
}

function Test-AIsSupersetOfB
{
    <#
    Return $true if all items in B are in A.  Used in token mgmt to compare scopes of tokens/token requests.
    #>

    param
    (
        [Object[]] $A,
        [Object[]] $B
    )

    return (-not @( $B | where {$A -notcontains $_} ))
}

function ConvertTo-B360Id
{
    <#
    Remove "b." from beginning of Id, to use object from Data Management API in BIM 360 API.
    #>

    param
    (
        [Parameter(ValueFromPipeline)]
        $Id
    )

    if ($Id.StartsWith('b.'))
    {
        return $Id.Substring(2)
    }
    else
    {
        return $Id
    }
}

function ConvertFrom-B360Id
{
    <#
    Add "b." to beginnin of Id, to use object from BIM 360 API in Data Management API.
    #>

    param
    (
        [Parameter(ValueFromPipeline)]
        $Id
    )
    
    if (-not $Id.StartsWith('b.'))
    {
        return "b.$Id"
    }
    else
    {
        return $Id
    }
}

function Assert-RegexMatch
{
    param
    (
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $String,

        [Parameter(Mandatory)]
        [Regex]
        $Regex
    )
    if ($String -notmatch $Regex)
    {
        throw "(Assert-MatchRegex) Assertion Failed : `"$String`" -match `"$Regex`""
    }
}

function Convert-MoneyAbrev
{
    param
    (
        [Parameter(ValueFromPipeline)]
        [ValidatePattern("^(\d*,)*\d*\.*\d*[kmbt]?$")]
        [String]
        $MoneyString,
        
        $ThousandsSeparator = ',',
        
        $DecimalSeparator = '.'
    )

    # if either separator char is '.', make sure it is properly escaped for regex use
    if ($ThousandsSeparator -eq '.') {$ThousandsSeparator = '\.'}
    if ($DecimalSeparator -eq '.') {$DecimalSeparator = '\.'}

    # remove any $ThousandsSeparators from the $MoneyString
    $MoneyString = $MoneyString.Replace($ThousandsSeparator,'')

    # make sure we are ready for more fragile operations
    Assert-RegexMatch $MoneyString "^*\d*\.*\d*[kmbt]?$"

    switch ($MoneyString[-1])
    {
        'k' {$MoneyString = [Int]( [Decimal]$MoneyString.Trim('k') * 1000 )}
        'm' {$MoneyString = [Int]( [Decimal]$MoneyString.Trim('m') * 1000000 )}
        'b' {$MoneyString = [Int]( [Decimal]$MoneyString.Trim('b') * 1000000000 )}
        't' {$MoneyString = [Int]( [Decimal]$MoneyString.Trim('t') * 1000000000000 )}
        default
        {
            if ($MoneyString[-1] -match "\d")
            {
                $MoneyString = [Int]( [Decimal]$MoneyString.Trim('k') * 1 )
            }
            else
            {
                throw "Don't know what to do with this `$MoneyString: $MoneyString"
            }
        }
    }

    return $MoneyString
}


function Split-Every
{
    param
    (
        [Object[]]
        $List,

        [Int]
        $ChunkSize
    )

    $chunks = [System.Collections.ArrayList]@()

    while ($i -lt $List.Count)
    {
        $null = $chunks.Add(@($List[$i..($i+$ChunkSize-1)]))
        $i += $ChunkSize
    }

    return $chunks
}

$Global:RequestResponseHistory = [System.Collections.ArrayList]@()