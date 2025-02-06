#   "Autodesk Forge PowerShell Cmdlets - Authentication API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# OAuth __________________________________________________________________________________________________________

# Reuse Access Tokens when possible to avoid API rate limit.
$Global:AccessTokens = [System.Collections.ArrayList]@()

function New-AccessToken2Legged {
    <#
    Create a new 2-legged access token and add it to the token pool, labeled with its scopes and expire time.
    https://forge.autodesk.com/en/docs/oauth/v1/reference/http/authenticate-POST/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $Scope,

        [Parameter()]
        [String]
        $ClientId = (Get-ForgeAppCredentials)['id'],

        [Parameter()]
        [String]
        $ClientSecret = (Get-ForgeAppCredentials)['secret'],

        [Parameter()]
        [String]
        $GrantType = "client_credentials"
    )


    # DEPRECATED: https://aps.autodesk.com/blog/migration-guide-oauth2-v1-v2
    #
    # $AccessToken2Legged = Invoke-RestMethod `
    #     -Uri "https://developer.api.autodesk.com/authentication/v1/authenticate" `
    #     -Method "POST" `
    #     -Headers @{
    #         "Content-Type" = "application/x-www-form-urlencoded"
    #     } `
    #     -Body @{
    #         "client_id" = $ClientId
    #         "client_secret" = $ClientSecret
    #         "grant_type" = $GrantType
    #         "scope" = $Scope
    #     }

    $ClientStringEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientId`:$ClientSecret"))
    
    $request = @{
        Uri = "https://developer.api.autodesk.com/authentication/v2/token"
        Method = "POST"
        Headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Authorization" = "Basic $ClientStringEncoded"

        }
        Body = @{
            "grant_type" = $GrantType
            "scope" = $Scope
        }
    }

    $AccessToken2Legged = Invoke-RestMethod @request

    if ($AccessToken2Legged) {
        $null = $Global:AccessTokens.Add(
            @{
                "legs" = 2
                "scopes" = $Scope.Split(' ')
                "expiry" = [DateTime]::now + [TimeSpan]::FromSeconds($AccessToken2Legged.expires_in - 59)
                "token" = $AccessToken2Legged
            }
        )
    }

    return $AccessToken2Legged
}


function New-AuthCode3Legged {

    <#
        .SYNOPSIS

        .LINK
        https://aps.autodesk.com/en/docs/oauth/v2/tutorials/get-3-legged-token/
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory)]
        [String]
        $Scope,

        [Parameter()]
        [String]
        $ClientId = (Get-ForgeAppCredentials)['id'],

        [Parameter()]
        [String]
        $ClientSecret = (Get-ForgeAppCredentials)['secret'],

        [Parameter()]
        [String]
        $RedirectUri = "http://localhost:8360/callback",
        
        [Parameter()]
        [ValidateSet("code","token")]
        [String]
        $ResponseType = "code"
    )

    # Spin up minimal web server on localhost to serve callback url for Code Grant 3-Legged OAth flow
    $RedirectUriEncoded = [System.Net.WebUtility]::UrlEncode($RedirectUri)
    $AuthUrl = "https://developer.api.autodesk.com/authentication/v2/authorize"
    $AuthUrl += "?response_type=$ResponseType&client_id=$ClientId&redirect_uri=$RedirectUriEncoded&scope=$Scope"

    Start-Process $AuthUrl

    $Listener = [System.Net.HttpListener]::new()
    $Listener.Prefixes.Add("$RedirectUri/")
    $Listener.Start()
    $context = $Listener.GetContext()

    $code = $context.Request.Url.Query.Substring(6)

    $buffer = [System.Text.Encoding]::UTF8.GetBytes(
        "<html><body><p style=`"text-align:center`">Permissions granted.  You may now close this window.</p></body></html>"
    )
    $context.Response.ContentLength64 = $buffer.Length
    $context.Response.OutputStream.Write($buffer,0,$buffer.Length)
    $context.Response.OutputStream.Close()

    $Listener.Stop()

    return $code
}


function New-AccessToken3Legged {

    <#
        .SYNOPSIS

        .LINK
        https://aps.autodesk.com/en/docs/oauth/v2/reference/http/gettoken-POST/#section-1-authorization-code-grant-type

    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory)]
        [String]
        $Scope,

        [Parameter()]
        [String]
        $ClientId = (Get-ForgeAppCredentials)['id'],

        [Parameter()]
        [String]
        $ClientSecret = (Get-ForgeAppCredentials)['secret'],

        [Parameter()]
        [String]
        $RedirectUri = "http://localhost:8360/callback",
        
        [Parameter()]
        [ValidateSet("code","token")]
        [String]
        $ResponseType = "code"
    )

    if ($ResponseType -eq "code")
    {
        $Code = New-AuthCode3Legged -Scope $Scope -ClientId $ClientId -ClientSecret $ClientSecret -RedirectUri $RedirectUri

        # https://aps.autodesk.com/blog/migration-guide-oauth2-v1-v2
        $ClientStringEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientId`:$ClientSecret"))

        $request = @{
            Uri = "https://developer.api.autodesk.com/authentication/v2/token"
            Method = "POST"
            Headers = @{
                "Content-Type" = "application/x-www-form-urlencoded"
                "Authorization" = "Basic $ClientStringEncoded"
            }
            Body = @{
                "grant_type" = "authorization_code"
                "code" = $Code
                "redirect_uri" = $RedirectUri
            }
        }

        $AccessToken3Legged = Invoke-RestMethod @request
    }
    else
    {
    Write-Error "Invalid ResponseType."    
    }

    if ($AccessToken3Legged)
    {
        $null = $Global:AccessTokens.Add(
            @{
                "legs" = 3
                "scopes" = $Scope.Split(' ')
                "expiry" = [DateTime]::now + [TimeSpan]::FromSeconds($AccessToken3Legged.expires_in - 59)
                "token" = $AccessToken3Legged
            }
        )
    }

    return $AccessToken3Legged
}

function Get-AccessToken
{
    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory)]
        [String]
        $Scope,

        [Switch]
        $Force,

        [Switch]
        $ThreeLegged
    )

    # Try to find an existing access token that will work for the current request.
    # If there isn't one, create a new access token and add it to the token pool.
    
    if
    ( # 3-legged flow requested
        $ThreeLegged
    )
    { # try get existing 3-legged token
        $ExistingTokens =
            @(
                $Global:AccessTokens |
                where { $_.legs -eq 3 } |
                where { [DateTime]::now -lt $_.expiry } |
                where { Test-AIsSupersetOfB $_.scopes $Scope.Split(' ') }
            )

        if
        ( # (no existing 3-legged tokens) or (new 3-legged token requested)
            ($ExistingTokens.Count -eq 0) -or ($Force)
        )
        { # get new 3-legged token
            $AccessToken = New-AccessToken3Legged -Scope $Scope
        }
        else
        { # get existing 3-legged token
            $AccessToken = $ExistingTokens[0].token
        }
    }
    else
    { # try get existing 2-legged token
        $ExistingTokens =
        @(
            $Global:AccessTokens |
            where { $_.legs -eq 2 } |
            where { [DateTime]::now -lt $_.expiry} |
            where { Test-AIsSupersetOfB $_.scopes $Scope.Split(' ') }
        )

        if
        ( # (no existing 2-legged tokens) or (new 2-legged token requested)
            ($ExistingTokens.Count -eq 0) -or ($Force)
        )
        { # get new 2-legged token
            $AccessToken = New-AccessToken2Legged -Scope $Scope
        }
        else
        { # get existing 2-legged token
            $AccessToken = $ExistingTokens[0].token
        }
    }

    return $AccessToken
}

function Get-MyUserInfo
{
    [CmdletBinding()]

    param
    (
        [Switch]
        $Force
    )

    # https://forge.autodesk.com/en/docs/oauth/v2/reference/http/users-@me-GET/
    
    if ((-not $Global:Me) -or ($Force))
    {
        $AccessToken = Get-AccessToken -Scope "data:read" -ThreeLegged

        $request =@{
            Uri = "https://developer.api.autodesk.com/userprofile/v1/users/@me"
            Method = "GET"
            Headers = @{
                "Authorization" = "$($AccessToken.token_type) $($AccessToken.access_token)"
            }
        }

        $Global:Me = Invoke-RestMethod @request
           
    }

    return $Global:Me
}
