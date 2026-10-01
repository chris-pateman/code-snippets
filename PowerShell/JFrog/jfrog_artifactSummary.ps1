
$jfUser = "999999"
$jfPassword = "******************"

$thresholdCritial = 1
$thresholdHigh = 4
$thresholdMedium = 10
$thresholdLow = 15

$jfUrl = "binarycentral.jfrog.io"
$jfUri = "/xray/api/v1/summary/artifact"

$paths = "General/docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019/0.1.102/manifest.json"#,General/docker-sitecore-local/sitecore-xp1-cm-10.1.2-ltsc2019/0.1.102/manifest.json,General/docker-sitecore-local/sitecore-id6-10.1.2-ltsc2019/0.1.102/manifest.json"


$jsonStr = @{
    paths = $paths.split(",")
} | ConvertTo-Json -Compress -Depth 100
Write-Host "$jsonStr"

$jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))

$fullUrl = "https://$jfUrl$jfUri"
Write-host "URL: $fullUrl"

$response = Invoke-WebRequest -Method Post -Uri $fullUrl -Body $jsonStr -Headers @{"Content-Type" = "application/json"; "Authorization" = "Basic $jfToken" }

if ($response.StatusCode -ne 200) {
    Write-Error "Failed to call API: $($response.StatusDescription)"
    exit 1
}
$response
Write-Host " Thresholds set at..."
Write-Host "Critial: $thresholdCritial"
Write-Host "High: $thresholdHigh"
Write-Host "Medium: $thresholdMedium"
Write-Host "Low: $thresholdLow"

$artifactSummary = $response.Content | ConvertFrom-Json
$artifacts = $artifactSummary.artifacts
$thresholdReached = $false
foreach ($artifact in $artifacts) {
    $artifactIssues = $artifact.issues

    Write-Host ""
    Write-Output "::group::Checking $($artifact.general.name)"
    if ($artifactIssues.length -lt 1) {
        Write-host "No Issues Found."
        continue
    }

    function Show-Issues($issuesCollection, $issueLevel, [int]$threshold) {
        $issues = $issuesCollection | Where-Object { $_.severity -eq $issueLevel }
        Write-Host ""
        if ([int]$issues.count -gt 0) {
            Write-Warning "$($issues.count) $issueLevel issues found. (max $threshold)"
            if ([int]$issues.count -gt [int]$threshold) {
                Write-Output "::error title=$issueLevel threshold met::$issueLevel threshold $threshold reached" 
                Write-Host "$issueLevel threshold $threshold reached" -ForegroundColor Red
            }
            foreach ($issue in $issues) {
                Write-Host "$($issue.issue_id): $($issue.description)"
            }
        }
        else {
            Write-Host "No $issueLevel issues found."
        }
        Write-Host ""
    
        if ([int]$issue.length -gt [int]$threshold) {
            return $true
        }
    }


    if ($(Show-Issues -issuesCollection $artifactIssues -issueLevel "Critical" -threshold $thresholdCritial)){
        $thresholdReached = $true
    }
    if ($(Show-Issues -issuesCollection $artifactIssues -issueLevel "High" -threshold $thresholdHigh)){
        $thresholdReached = $true
    }
    if ($(Show-Issues -issuesCollection $artifactIssues -issueLevel "Medium" -threshold $thresholdMedium)){
        $thresholdReached = $true
    }
    if ($(Show-Issues -issuesCollection $artifactIssues -issueLevel "Low" -threshold $thresholdLow)){
        $thresholdReached = $true
    }

    Write-Output "::endgroup::"
}

if ($thresholdReached) {
    Write-Host "Threshold for errors reached."
    exit 1
}
else {
    Write-Host "Threshold for errors not reached."
    exit 0
}