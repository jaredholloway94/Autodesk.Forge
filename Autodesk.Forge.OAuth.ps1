#   "Autodesk Forge PowerShell Cmdlets - Authentication API"
#   Copyright © 2021 Jared M. Holloway
#   License: MIT
#   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# OAuth __________________________________________________________________________________________________________

# Reuse Access Tokens when possible to avoid API rate limit.
$Global:AccessTokens = [System.Collections.ArrayList]@()

# Prefer 3-legged (user) tokens, so results are scoped to what the signed-in Autodesk user can
# actually see. Set to $false to restore the old app-level (2-legged) behavior module-wide.
# Individual cmdlets can still override per call with -ThreeLegged / -TwoLegged.
$Global:ForgeThreeLeggedByDefault = $true

# The union of every scope this module needs. Connect-Forge mints ONE 3-legged token with this
# set, so Get-AccessToken finds a superset in the pool for every later call and the user is only
# prompted to consent once per session. 'offline_access' is what yields a refresh_token.
$Global:ForgeDefaultScopes = "data:read data:write data:create data:search account:read account:write openid profile offline_access"

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
    # scopes are space-separated, so they must be url-encoded too
    $ScopeEncoded = [System.Net.WebUtility]::UrlEncode($Scope)
    $AuthUrl = "https://developer.api.autodesk.com/authentication/v2/authorize"
    $AuthUrl += "?response_type=$ResponseType&client_id=$ClientId&redirect_uri=$RedirectUriEncoded&scope=$ScopeEncoded"

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
                # present when the 'offline_access' scope was granted; lets us renew without
                # sending the user back through the browser.
                "refresh_token" = $AccessToken3Legged.refresh_token
            }
        )
    }

    return $AccessToken3Legged
}


function Update-AccessToken3Legged
{
    <#
        .SYNOPSIS
        Silently renew a pooled 3-legged token using its refresh_token, updating the pool entry
        in place. Returns the new token, or $null if it could not be refreshed.

        .LINK
        https://aps.autodesk.com/en/docs/oauth/v2/reference/http/gettoken-POST/#section-3-refresh-token-grant-type
    #>

    [CmdletBinding()]

    param
    (
        [Parameter(Mandatory)]
        $TokenEntry,

        [Parameter()]
        [String]
        $ClientId = (Get-ForgeAppCredentials)['id'],

        [Parameter()]
        [String]
        $ClientSecret = (Get-ForgeAppCredentials)['secret']
    )

    if (-not $TokenEntry.refresh_token)
    {
        return $null
    }

    $ClientStringEncoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$ClientId`:$ClientSecret"))

    $request = @{
        Uri = "https://developer.api.autodesk.com/authentication/v2/token"
        Method = "POST"
        Headers = @{
            "Content-Type" = "application/x-www-form-urlencoded"
            "Authorization" = "Basic $ClientStringEncoded"
        }
        Body = @{
            "grant_type" = "refresh_token"
            "refresh_token" = $TokenEntry.refresh_token
        }
    }

    try
    {
        $Refreshed = Invoke-RestMethod @request
    }
    catch
    {
        # refresh token expired or revoked; caller falls back to a fresh interactive sign-in
        Write-Verbose "Could not refresh 3-legged token: $($_.Exception.Message)"
        return $null
    }

    if ($Refreshed)
    {
        # update the pooled entry in place so every later lookup sees the renewed token
        $TokenEntry.token = $Refreshed
        $TokenEntry.expiry = [DateTime]::now + [TimeSpan]::FromSeconds($Refreshed.expires_in - 59)
        if ($Refreshed.refresh_token) {$TokenEntry.refresh_token = $Refreshed.refresh_token}
        if ($Refreshed.scope) {$TokenEntry.scopes = $Refreshed.scope.Split(' ')}

        return $Refreshed
    }

    return $null
}


function Resolve-TokenLegs
{
    <#
        .SYNOPSIS
        Decide whether a call should use a 3-legged (user) or 2-legged (app) token.
        -TwoLegged always wins; then an explicitly-provided -ThreeLegged value; otherwise the
        module default ($Global:ForgeThreeLeggedByDefault).
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [Bool]
        $ThreeLegged,

        [Parameter()]
        [Bool]
        $TwoLegged,

        # whether the caller actually passed -ThreeLegged (vs. leaving it to the default)
        [Parameter()]
        [Bool]
        $ThreeLeggedSpecified
    )

    if ($TwoLegged)
    {
        return 2
    }
    elseif ($ThreeLeggedSpecified)
    {
        if ($ThreeLegged) {return 3} else {return 2}
    }
    elseif ($Global:ForgeThreeLeggedByDefault)
    {
        return 3
    }
    else
    {
        return 2
    }
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
        $ThreeLegged,

        # Force the app-level (2-legged) flow, overriding $Global:ForgeThreeLeggedByDefault
        [Switch]
        $TwoLegged,

        # Never start an interactive browser sign-in; return $null instead. Used by
        # ArgumentCompleters so pressing Tab can't pop a browser and block the prompt.
        [Switch]
        $NonInteractive
    )

    # Try to find an existing access token that will work for the current request.
    # If there isn't one, create a new access token and add it to the token pool.

    $Legs = Resolve-TokenLegs `
        -ThreeLegged:$ThreeLegged `
        -TwoLegged:$TwoLegged `
        -ThreeLeggedSpecified:($PSBoundParameters.ContainsKey('ThreeLegged'))

    if
    ( # 3-legged flow requested
        $Legs -eq 3
    )
    { # try get existing 3-legged token
        $ExistingTokens =
            @(
                $Global:AccessTokens |
                where { $_.legs -eq 3 } |
                where { [DateTime]::now -lt $_.expiry } |
                where { Test-AIsSupersetOfB $_.scopes $Scope.Split(' ') }
            )

        if ( ($ExistingTokens.Count -gt 0) -and (-not $Force) )
        { # get existing 3-legged token
            $AccessToken = $ExistingTokens[0].token
        }
        else
        {
            # Before sending the user back through the browser, try to silently renew an
            # expired token that still has a refresh_token covering the requested scopes.
            $AccessToken = $null

            if (-not $Force)
            {
                $RefreshableTokens =
                    @(
                        $Global:AccessTokens |
                        where { $_.legs -eq 3 } |
                        where { $_.refresh_token } |
                        where { Test-AIsSupersetOfB $_.scopes $Scope.Split(' ') }
                    )

                foreach ($TokenEntry in $RefreshableTokens)
                {
                    $AccessToken = Update-AccessToken3Legged -TokenEntry $TokenEntry
                    if ($AccessToken) {break}
                }
            }

            if (-not $AccessToken)
            {
                if ($NonInteractive)
                { # caller (e.g. a completer) cannot afford a blocking browser sign-in
                    return $null
                }

                $AccessToken = New-AccessToken3Legged -Scope $Scope
            }
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


function Connect-Forge
{
    <#
        .SYNOPSIS
        Sign in to Autodesk with a 3-legged (user) token, so every subsequent cmdlet only sees
        the hubs, projects and files this user actually has access to.

        .DESCRIPTION
        Mints ONE 3-legged token covering $Global:ForgeDefaultScopes and puts it in the token
        pool. Because Get-AccessToken reuses any pooled token whose scopes are a superset of the
        requested scopes, this means the browser consent happens exactly once per session
        instead of once per distinct scope set.

        Run this after Import-Module. Tab-completion will not sign you in on its own -- it uses
        whatever token is already cached and otherwise tells you to run this cmdlet.
    #>

    [CmdletBinding()]

    param
    (
        [Parameter()]
        [String]
        $Scope = $Global:ForgeDefaultScopes,

        # Discard any cached 3-legged token and sign in again
        [Switch]
        $Force
    )

    if ($Force)
    {
        Disconnect-Forge
    }

    $AccessToken = Get-AccessToken -Scope $Scope -ThreeLegged -Force:$Force

    if ($AccessToken)
    {
        $Global:ForgeConnected = $true

        $TokenEntry =
            @(
                $Global:AccessTokens |
                where { $_.legs -eq 3 } |
                where { [DateTime]::now -lt $_.expiry }
            )[0]

        Write-Host "Signed in to Autodesk (3-legged)."
        Write-Host "  scopes:  $($Scope)"
        Write-Host "  expires: $($TokenEntry.expiry)"
        if ($TokenEntry.refresh_token)
        {
            Write-Host "  refresh: enabled (you won't be prompted again this session)"
        }
        else
        {
            Write-Host "  refresh: unavailable (add 'offline_access' to the scopes to enable)"
        }
    }
    else
    {
        throw "Could not sign in to Autodesk."
    }

    return
}


function Disconnect-Forge
{
    <#
        .SYNOPSIS
        Discard cached 3-legged tokens and any user-scoped data cached from them.
    #>

    [CmdletBinding()]

    param
    (
        # Also discard cached 2-legged (app) tokens
        [Switch]
        $All
    )

    if ($All)
    {
        $Global:AccessTokens = [System.Collections.ArrayList]@()
    }
    else
    {
        $Remaining = @($Global:AccessTokens | where { $_.legs -ne 3 })
        $Global:AccessTokens = [System.Collections.ArrayList]@($Remaining)
    }

    # these caches were populated under the old user's permissions
    $Global:Me = $null
    $Global:Hubs = $null
    $Global:ForgeConnected = $false

    return
}
