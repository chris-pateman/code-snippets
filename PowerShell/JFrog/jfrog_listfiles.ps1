
$jfUser = "9999999"
$jfPassword = "************"

$jfUrl = "binarycentral.jfrog.io"
$jfUri = "/artifactory/api/storage"
$paths = @("docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019")
$includeFolders = 1
$depth = 1

$jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))

foreach ($path in $paths ) {
    
    $fullUrl = "https://$jfUrl$jfUri/$path`?list&depth=$depth&listFolders=$includeFolders&mdTimestamps=1&includeRootPath=0"
    Write-host "URL: $fullUrl"

    $response = Invoke-WebRequest -Method Get -Uri $fullUrl -Headers @{ "Authorization" = "Basic $jfToken" }

    if ($response.StatusCode -ne 200) {
        Write-Error "Failed to call API: $($response.StatusDescription)"
        exit 1
    }

    $responseContent = $response.RawContent -replace $($response.RawContent.split([Environment]::NewLine)[0]),""
    $response.headers.keys | ForEach-Object {
        $responseContent = $responseContent.replace("$($_): $($headers[$_])","")
    }
    $responseObj = $($responseContent | ConvertFrom-Json)

    $outputJson = $responseObj | ConvertTo-Json -Compress -Depth 100


}