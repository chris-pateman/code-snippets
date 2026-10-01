
$jfUser = $env:JFROG_USERNAME
$jfPassword = $env:JFROG_PASSWORD

$jfUrl = $env:JFROG_URL
$jfUri = "/artifactory"
$paths = @("docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019/CI-1.4.60")

$jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))

foreach ($path in $paths ) {
    
    $fullUrl = "https://$jfUrl$jfUri/$path"
    Write-host "URL: $fullUrl"

    $response = Invoke-WebRequest -Method DELETE -Uri $fullUrl -Headers @{ "Authorization" = "Basic $jfToken" }

    if ($response.StatusCode -ne 200) {
        Write-Error "Failed to call API: $($response.StatusDescription)"
        exit 1
    }

    $responseContent = $response
    $responseContent

}