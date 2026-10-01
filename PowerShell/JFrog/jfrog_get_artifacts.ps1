$jfUser = "999999"
$jfPassword = "**********"

$jfUrl = "binarycentral.jfrog.io"
$jfUri = "/artifactory/api/storage"
$paths = @("nuget-powershellgallery-remote")  # You can add more repositories here
$includeFolders = 1
$depth = 2  # Increase depth to search deeper

$jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))

foreach ($path in $paths) {
    $fullUrl = "https://$jfUrl$jfUri/$path`?list&depth=$depth&listFolders=$includeFolders&mdTimestamps=1&includeRootPath=0"
    Write-Host "Querying: $fullUrl"

    $response = Invoke-WebRequest -Method Get -Uri $fullUrl -Headers @{ "Authorization" = "Basic $jfToken" }

    if ($response.StatusCode -ne 200) {
        Write-Error "Failed to call API: $($response.StatusDescription)"
        exit 1
    }

    $responseObj = ($response.Content | ConvertFrom-Json)

    $sqlItems = $responseObj.files | Where-Object { $_.uri -match "sql" }

    foreach ($file in $responseObj.files) {
        $file
    }
}
