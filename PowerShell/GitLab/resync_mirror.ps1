
<#
.SYNOPSIS
  Scan all projects in a GitLab group; for failed remote mirrors, capture details and recreate them
  (optionally replacing the password/PAT embedded in the mirror URL).

.PARAMETER GitLabHost
  Base host of your GitLab instance, e.g. https://gitlab.version1.com

.PARAMETER GroupIdOrPath
  Numeric group ID or full path, e.g. 1234 or "platform/azure"

.PARAMETER AdminToken
  A PRIVATE-TOKEN with scopes sufficient to read and manage projects & remote mirrors.

.PARAMETER NewSecret
  (Optional) The new password/PAT to embed in HTTPS mirror URLs during recreation.
  If omitted, the existing URL is reused.

.PARAMETER NewUsername
  (Optional) Username to use with the NewSecret for HTTPS URLs. Defaults to "oauth2".
  Many remotes (GitHub/Azure DevOps) accept "oauth2" or "git" as the username when using a PAT.

.PARAMETER IncludeSubgroups
  Scan subgroups' projects as well. Default: $true.

.PARAMETER DryRun
  If set, only report what would be changed; do not delete/recreate mirrors.

.EXAMPLE
  .\Rotate-GitLabMirrors.ps1 `
    -GitLabHost https://gitlab.version1.com `
    -GroupIdOrPath "delivery/azure" `
    -AdminToken (Get-Content "$env:USERPROFILE\.gitlab-token" -Raw) `
    -NewSecret (Read-Host "New PAT" -AsSecureString | ConvertFrom-SecureString) `
    -DryRun

.NOTES
  Requires PowerShell 7+ for best TLS/ciphers. Tested against GitLab 16.x.
#>

param(
  [Parameter(Mandatory=$true)]
  [string]$GitLabHost,

  [Parameter(Mandatory=$true)]
  [string]$GroupIdOrPath,

  [Parameter(Mandatory=$true)]
  [string]$AdminToken,

  [Parameter(Mandatory=$false)]
  [string]$NewSecret,

  [Parameter(Mandatory=$false)]
  [string]$NewUsername = "oauth2",

  [Parameter(Mandatory=$false)]
  [bool]$IncludeSubgroups = $true,

  [switch]$DryRun
) 


# --------------------------
# Utilities
# --------------------------
function Invoke-GitLabApi {
    param(
        [Parameter(Mandatory = $true)][ValidateSet('GET', 'POST', 'PUT', 'DELETE')] [string]$Method,
        [Parameter(Mandatory = $true)] [string]$Path,
        [Parameter(Mandatory = $false)] [hashtable]$Body
    )
    $uri = "$GitLabHost/api/v4$Path"
    $headers = @{ "PRIVATE-TOKEN" = $AdminToken }

    try {
        if ($Body) {
            $response = Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $($Body | ConvertTo-Json -Compress -Depth 100) -ContentType "application/json"
        }
        else {
            $response = Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
        }
        return $response
    }
    catch {
        if ($Method -eq "GET" -and $uri -like "*mirror/pull*") {
            return @()
        }
        Write-Warning "API $Method $uri failed: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            try {
                $err = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream()).ReadToEnd()
                Write-Verbose "Response: $err"
            }
            catch {}
        }
        return $null
    }
}

function Get-GitLabGroupProjects {
    param([string]$GroupIdOrPath, [bool]$IncludeSubgroups)
    $projects = @()
    $page = 1
    do {
        $path = "/groups/$([uri]::EscapeDataString($GroupIdOrPath))/projects?per_page=100&page=$page&include_subgroups=$IncludeSubgroups"
        $batch = Invoke-GitLabApi -Method GET -Path $path
        if ($batch) { $projects += $batch }
        $page++
    } while ($batch -and $batch.Count -eq 100)
    return $projects
}

function Get-RemoteMirrors {
    param([int]$ProjectId)
    # Use the project mirror pull endpoint which returns mirror status/details
    Invoke-GitLabApi -Method GET -Path "/projects/$ProjectId/mirror/pull"
}

function Update-RemoveMirror {
    param([int]$ProjectId)
    
# Body for disabling the pull mirror
$Body = @{
    enabled = $false
    url     = ""   # Optional: clears the URL if supported
}
Invoke-GitLabApi -Method PUT -Path "/projects/$ProjectId/mirror/pull" -Body $Body

return $true
}

function Delete-RemoteMirror {
    param([int]$ProjectId, [int]$MirrorId)
    if ($DryRun) {
        Write-Host "DRY-RUN: Would DELETE mirror $MirrorId on project $ProjectId" -ForegroundColor Yellow
        return $true
    }
    $res = Invoke-GitLabApi -Method DELETE -Path "/projects/$ProjectId/remote_mirrors/$MirrorId"
    if ($res -eq $null) {
        # GitLab returns 204 No Content; Invoke-RestMethod yields $null on success
        Write-Host "Deleted mirror $MirrorId on project $ProjectId" -ForegroundColor Green
        return $true
    }
    return $false
}

function New-RemoteMirror {
    param(
        [int]$ProjectId,
        [string]$Url,
        [bool]$Enabled = $true,
        [bool]$OnlyProtectedBranches = $false,
        [bool]$KeepDivergentBranches = $false,
        [string]$MirrorBranchRegex = $null,
        [ValidateSet('push', 'pull')] [string]$MirrorDirection = 'pull'
    )
    $payload = @{
        url                     = $Url -replace " ", '%20'
        enabled                 = $Enabled
        only_protected_branches = $OnlyProtectedBranches
        keep_divergent_branches = $KeepDivergentBranches
        mirror_branch_regex     = $MirrorBranchRegex
        mirror_direction        = $MirrorDirection
    } #| ConvertTo-Json -Depth 5

    if ($DryRun) {
        Write-Host "DRY-RUN: Would CREATE mirror on project $ProjectId with URL (redacted)" -ForegroundColor Yellow
        return $true
    }

    $res = Invoke-GitLabApi -Method POST -Path "/projects/$ProjectId/remote_mirrors" -Body $payload
    if ($res) {
        Write-Host "Created new remote mirror on project $ProjectId" -ForegroundColor Green
        return $true
    }
    return $false
}
function New-GitLabProjectMirror {
   param(
        [int]$ProjectId,
        [string]$MirrorUrl
    )

    #$mirrorUrl = "https://$AdoAccessToken@dev.azure.com/$AdoOrg/$AdoProject/_git/$AdoRepo"

    $payload = @{
        url                     = $MirrorUrl
        enabled                 = $true
        only_protected_branches = $true
        keep_divergent_refs     = $true
    }

    $res = Invoke-GitLabApi -Method PUT -Path "/projects/$ProjectId/mirror/pull" -Body $payload
     if ($res) {
        Write-Host "Created new remote mirror on project $ProjectId" -ForegroundColor Green
        Write-Host "Mirrored to $MirrorUrl" -ForegroundColor Green
        return $true
    }
    return $false
}

function Mask-UrlSecret {
    param([string]$Url)
    if (-not $Url) { return $Url }
    try {
        $u = [uri]$Url
        $hostPort = $u.IsDefaultPort ? $u.Host : "$($u.Host):$($u.Port)"
        $pathQ = [System.Uri]::EscapeUriString($u.AbsolutePath + $u.Query)
        # Mask userinfo if present
        if ($u.UserInfo) {
            $userinfo = $u.UserInfo -replace ':(.*)$', ':****'
            return ("{0}://{1}@{2}{3}" -f $u.Scheme, $userinfo, $hostPort, $pathQ)
        } else {
            return ("{0}://{1}{2}" -f $u.Scheme, $hostPort, $pathQ)
        }
    } catch {
        # Fallback simple mask when URL is malformed
        if ($Url -match '^(https?:\/\/)([^@\/]+)@') {
            $prefix = $matches[1]
            $userinfo = $matches[2]
            $maskedUserInfo = ($userinfo -replace ':(.*)$', ':****')
            return ($Url -replace '^(https?:\/\/)([^@\/]+)@', "${prefix}${maskedUserInfo}@")
        }
        return $Url
    }
}

function Replace-UrlSecret {
    param(
        [string]$Url,
        [string]$NewUsername,
        [string]$NewSecret
    )
    if (-not $Url) { throw "URL is empty" }

    if ($Url -notmatch '^https?://') {
        Write-Warning "Mirror uses SSH or non-HTTP URL. No password to rotate in URL: $Url"
        return $Url
    }

    try {
        Write-Host "Replacing credentials in URL (redacted)..." -ForegroundColor DarkGray
        $uri = [uri]$Url
        $hostPort = $uri.IsDefaultPort ? $uri.Host : "$($uri.Host):$($uri.Port)"
        $pathQ = $uri.AbsolutePath + $uri.Query

        $encodedUser = $NewUsername
        $encodedSecret = $NewSecret

        $newUrl = "{0}://{2}@{3}{4}" -f $uri.Scheme, $encodedSecret, $hostPort, $pathQ
        Write-Host "  New URL (redacted): $($newUrl)" -ForegroundColor DarkGray
        return $newUrl
    } catch {
        # Best-effort fallback: replace userinfo segment and percent-encode spaces
        $safe = $Url -replace ' ', '%20'
        if ($safe -match '^(https?:\/\/)([^@\/]+)@(.+)$') {
            $prefix = $matches[1]; $rest = $matches[3]
            $encodedUser = $NewUsername
            $encodedSecret = $NewSecret
            return ("{0}{1}:{2}@{3}" -f $prefix, $encodedUser, $encodedSecret, $rest)
        }
        return $safe
    }
}

# --------------------------
# Main
# --------------------------
Write-Host "Scanning GitLab group '$GroupIdOrPath' on $GitLabHost ..." -ForegroundColor Cyan
$projects = Get-GitLabGroupProjects -GroupIdOrPath $GroupIdOrPath -IncludeSubgroups $IncludeSubgroups
if (-not $projects -or $projects.Count -eq 0) {
    Write-Warning "No projects found under group '$GroupIdOrPath'."
    exit 1
}

$summary = @()
foreach ($p in $projects) {
    $projId = [int]$p.id
    $projName = $p.path_with_namespace
    Write-Host "Project: $projName (ID: $projId)" -ForegroundColor Cyan

    $mirrors = Get-RemoteMirrors -ProjectId $projId
    if (-not $mirrors -or $mirrors.Count -eq 0) {
        Write-Host "  No remote mirrors." -ForegroundColor DarkGray
        continue
    }

    foreach ($m in $mirrors) {
        # Common fields observed: id, url, enabled, last_successful_update_at, last_update_at, last_error, only_protected_branches, keep_divergent_branches, mirror_branch_regex, mirror_direction
        $mirrorId = [int]$m.id
        $status = if ($m.last_error) { "failed" } else { "ok" }
        $masked = $m.url # Mask-UrlSecret -Url $m.url
        Write-Host ("  Mirror #{0} [{1}] URL: {2}" -f $mirrorId, $m.mirror_direction, $masked)

        if ($status -eq "ok") {
            Write-Host "    Status: OK (last_success: $($m.last_successful_update_at))" -ForegroundColor DarkGreen
            continue
        }

        Write-Host "    Previous Status: FAILED" -ForegroundColor Red
        Write-Host "    Last error: $($m.last_error)" -ForegroundColor Red

        # Prepare recreation parameters
        $recreateUrl = $m.url
        $usedNewSecret = $false
        if ($NewSecret) {
            $recreateUrl = Replace-UrlSecret -Url $m.url -NewUsername $NewUsername -NewSecret $NewSecret
            $usedNewSecret = $true
        }

        $summary += [pscustomobject]@{
            Project               = $projName
            ProjectId             = $projId
            MirrorId              = $mirrorId
            Direction             = $m.mirror_direction
            UrlMasked             = (Mask-UrlSecret -Url $recreateUrl)
            LastError             = $m.last_error
            UsedNewSecret         = $usedNewSecret
            OnlyProtectedBranches = [bool]$m.only_protected_branches
            KeepDivergentBranches = [bool]$m.keep_divergent_branches
            MirrorBranchRegex     = $m.mirror_branch_regex
        }

        # Delete + Recreate
        #$deleted =  Delete-RemoteMirror -ProjectId $projId -MirrorId $mirrorId
        $updated = Update-RemoveMirror -ProjectId $projId 
        if ($updated) {
            # Normalize mirror direction; default to 'push' when empty/invalid
            $direction = 'push'
            if ($m.mirror_direction -and $m.mirror_direction -match '^(push|pull)$') { $direction = $m.mirror_direction }

           <#  $created = New-RemoteMirror -ProjectId $projId `
                -Url $recreateUrl `
                -Enabled $true `
                -OnlyProtectedBranches ([bool]$m.only_protected_branches) `
                -KeepDivergentBranches ([bool]$m.keep_divergent_branches) `
                -MirrorBranchRegex $m.mirror_branch_regex `
                -MirrorDirection $direction #>
            $created = New-GitLabProjectMirror -ProjectId $projId -MirrorUrl $recreateUrl

            if ($created) {
                Write-Host "    Recreated mirror successfully." -ForegroundColor Green
            }
            else {
                Write-Error "    FAILED to recreate mirror."
            }
        }
    }
}

# Output a concise report
Write-Host "`n=== Mirrors Recreated (or planned in DRY-RUN) ==="

exit 0
if (-not $summary -or $summary.Count -eq 0) {
    Write-Host "No mirrors required recreation." -ForegroundColor Green
} else {
    # Print a compact table of affected mirrors
    $summary |
      Select-Object Project, ProjectId, MirrorId, Direction, UrlMasked, LastError, UsedNewSecret |
      Format-Table -AutoSize

    # Summary counts by project
    Write-Host "`nSummary by project:"
    $summary | Group-Object -Property Project | ForEach-Object {
        Write-Host ("- {0}: {1} mirror(s) affected" -f $_.Name, $_.Count)
    }

    # Totals
    $total = $summary.Count
    $withNewSecret = ($summary | Where-Object { $_.UsedNewSecret }).Count
    Write-Host "`nTotals: $total mirror(s) processed, $withNewSecret with new secret."

    # Export report files (CSV + JSON) to script folder
    $ts = (Get-Date).ToString("yyyyMMdd-HHmmss")
    $csvFile = Join-Path -Path $PSScriptRoot -ChildPath "mirror-report-$ts.csv"
    $jsonFile = Join-Path -Path $PSScriptRoot -ChildPath "mirror-report-$ts.json"

    try {
        $summary | Export-Csv -Path $csvFile -NoTypeInformation -Force
        $summary | ConvertTo-Json -Depth 6 | Out-File -FilePath $jsonFile -Encoding utf8 -Force
        Write-Host "`nReport files written:"
        Write-Host "  $csvFile" -ForegroundColor Cyan
        Write-Host "  $jsonFile" -ForegroundColor Cyan
    } catch {
        Write-Warning "Failed to write report files: $($_.Exception.Message)"
    }
}
