
$jfUser = $env:JFROG_USERNAME
$jfPassword = $env:JFROG_PASSWORD
$jfUrl = $env:JFROG_URL
$jfUri = "/artifactory/api/storage"
$paths = @("docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019")

if ([string]::IsNullOrWhiteSpace($jfUser) -or [string]::IsNullOrWhiteSpace($jfPassword) -or [string]::IsNullOrWhiteSpace($jfUrl)) {
    throw "Set JFROG_USERNAME, JFROG_PASSWORD, and JFROG_URL before running this script."
}

foreach ($path in $paths) {
    Write-Host "Path: $path"
    $jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))
    $fullUrl = "https://$jfUrl$jfUri/$path`?list&depth=1&listFolders=1&mdTimestamps=1&includeRootPath=0"
    Write-Host "URL: $fullUrl"

    $response = Invoke-WebRequest -Method Get -Uri $fullUrl -Headers @{ Authorization = "Basic $jfToken" }

    if ($response.StatusCode -ne 200) {
        throw "Failed to call API: $($response.StatusDescription)"
    }

    $responseObj = $response.Content | ConvertFrom-Json
    $responseObj | ConvertTo-Json -Compress -Depth 100
}
