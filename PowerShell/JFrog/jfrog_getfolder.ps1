
$jfUser = "99999"
$jfPassword = "********"

$jfUrl = "binarycentral.jfrog.io"
$jfUri = "/artifactory/api/storage"
$paths = @("docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019/0.1.80")

foreach ($path in $paths ){
    

$jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))

$fullUrl = "https://$jfUrl$jfUri/$path"
Write-host "URL: $fullUrl"

$response = Invoke-WebRequest -Method GET -Uri $fullUrl -Headers @{"Content-Type" = "application/json"; "Authorization" = "Basic $jfToken" }

if ($response.StatusCode -ne 200) {
    Write-Error "Failed to call API: $($response.StatusDescription)"
    exit 1
}

$responseContent = $response
$responseContent

}