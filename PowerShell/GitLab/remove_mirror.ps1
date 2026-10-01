<#
.SYNOPSIS
  Remove all remote mirrors from projects under a group/path (e.g. shared/azure/terraform-modules-legacy)

.PARAMETER GitLabHost
  Base host of your GitLab instance, e.g. https://gitlab.version1.com

.PARAMETER GroupPath
  Group path whose projects will be scanned, e.g. shared/azure/terraform-modules-legacy

.PARAMETER AdminToken
  PRIVATE-TOKEN with permissions to manage project remote mirrors.

.PARAMETER IncludeSubgroups
  Include subgroups' projects (default: $false).

.PARAMETER DryRun
  If set, only report what would be deleted.

.EXAMPLE
  .\remove_terraform_mirrors.ps1 -GitLabHost https://gitlab.version1.com -GroupPath shared/azure/terraform-modules-legacy -AdminToken $token -DryRun
#>

$GitLabHost = "https://gitlab.example.com"
$GroupPath = "shared/azure/terraform-modules-legacy"
$AdminToken = "******"
$IncludeSubgroups = $true
$DryRun = $false

function Invoke-GitLabApi {
    param(
        [ValidateSet('GET','POST','PUT','DELETE')][string]$Method,
        [string]$Path,
        [object]$Body = $null
    )
    $uri = "$GitLabHost/api/v4$Path"
    $headers = @{ "PRIVATE-TOKEN" = $AdminToken }
    try {
        if ($Body) { return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 6) -ContentType "application/json" }
        else { return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers }
    } catch {
        Write-Warning "API $Method $uri failed: $($_.Exception.Message)"
        return $null
    }
}

function Get-GitLabGroupProjects {
    param([string]$GroupPath, [bool]$IncludeSubgroups)
    $projects = @()
    $page = 1
    do {
        $enc = [uri]::EscapeDataString($GroupPath)
        $path = "/groups/$enc/projects?per_page=100&page=$page&include_subgroups=$IncludeSubgroups"
        $batch = Invoke-GitLabApi -Method GET -Path $path
        if ($batch) { $projects += $batch }
        $page++
    } while ($batch -and $batch.Count -eq 100)
    return $projects
}

function Get-RemoteMirrors {
    param([int]$ProjectId)
    return Invoke-GitLabApi -Method GET -Path "/projects/$ProjectId/mirror/pull"
}

function Delete-RemoteMirror {
    param([int]$ProjectId, [int]$MirrorId)
    if ($DryRun) {
        Write-Host "DRY-RUN: Would DELETE mirror $MirrorId on project $ProjectId" -ForegroundColor Yellow
        return $true
    }
    $res = Invoke-GitLabApi -Method DELETE -Path "/projects/$ProjectId/remote_mirrors/$MirrorId"
    if ($res -eq $null) {
        Write-Host "Deleted mirror $MirrorId on project $ProjectId" -ForegroundColor Green
        return $true
    }
    Write-Warning "Failed to delete mirror $MirrorId on project $ProjectId"
    return $false
}

function Update-RemoveMirror {
    param([int]$ProjectId)
    
# Body for disabling the pull mirror
$Body = @{
    enabled = $false
    url     = ""   # Optional: clears the URL if supported
}
Invoke-GitLabApi -Method PUT -Path "/projects/$ProjectId/mirror/pull" -Body $Body

}

function Mask-UrlSecret {
    param([string]$Url)
    if (-not $Url) { return $Url }
    try {
        $u = [uri]$Url
        if ($u.UserInfo) {
            $userinfo = $u.UserInfo -replace ':(.*)$', ':****'
            return ("{0}://{1}@{2}{3}" -f $u.Scheme, $userinfo, $u.Authority, $u.PathAndQuery)
        }
        return ("{0}://{1}{2}" -f $u.Scheme, $u.Authority, $u.PathAndQuery)
    } catch {
        return ($Url -replace '^(https?:\/\/)([^@\/]+)@', '${1}****@')
    }
}

# --- Main
Write-Host "Removing mirrors from projects in group '$GroupPath' on $GitLabHost" -ForegroundColor Cyan

$projects = Get-GitLabGroupProjects -GroupPath $GroupPath -IncludeSubgroups $IncludeSubgroups
if (-not $projects -or $projects.Count -eq 0) {
    Write-Warning "No projects found under group '$GroupPath'."
    exit 1
}

$report = @()
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
        $mirrorId = [int]$m.id
        $maskedUrl = Mask-UrlSecret -Url $m.url
        Write-Host ("  Mirror #{0} [{1}] URL: {2}" -f $mirrorId, ($m.mirror_direction -or "<unknown>"), $maskedUrl)

        #$ok = Delete-RemoteMirror -ProjectId $projId -MirrorId $mirrorId
        Update-RemoveMirror -ProjectId $projId

        $report += [pscustomobject]@{
            Project   = $projName
            ProjectId = $projId
            MirrorId  = $mirrorId
            Direction = ($m.mirror_direction -or "")
            UrlMasked = $maskedUrl
            LastError = ($m.last_error -or "")
            Deleted   = $ok
        }
    }
}

# Output concise report
Write-Host "`n=== Mirror removal report ==="
if ($report.Count -eq 0) {
    Write-Host "No mirrors found to remove." -ForegroundColor Green
    exit 0
}

$report | Select-Object Project,ProjectId,MirrorId,Direction,Deleted,LastError | Format-Table -AutoSize

# export CSV/JSON
$ts = (Get-Date).ToString("yyyyMMdd-HHmmss")
$csv = Join-Path $PSScriptRoot "removed-mirrors-$ts.csv"
$json = Join-Path $PSScriptRoot "removed-mirrors-$ts.json"
#$report | Export-Csv -Path $csv -NoTypeInformation -Force
#$report | ConvertTo-Json -Depth 6 | Out-File -FilePath $json -Encoding utf8 -Force

Write-Host "`nReport written to:`n  $csv`n  $json" -ForegroundColor Cyan