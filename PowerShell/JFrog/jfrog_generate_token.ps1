
$jfUser = "999999"
$jfPassword = "******"
$jfBearer = "***************.***********.*************"

$jfUrl = "binarycentral.jfrog.io"
$jfUri = "/access/api/v1/tokens"


$jfToken = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jfUser, $jfPassword)))

    
$fullUrl = "https://$jfUrl$jfUri"
Write-host "URL: $fullUrl"

$response = Invoke-WebRequest -Method Post -Body '{"description" : "api", "token_id" : "YOUR-TOKEN-ID", "scope" : "applied-permissions/admin", "token_type" : "access_token", "include_reference_token" : "true"}' -Uri $fullUrl -Headers @{ "Authorization" = "Bearer $jfPassword" }

if ($response.StatusCode -ne 200) {
    Write-Error "Failed to call API: $($response.StatusDescription)"
    exit 1
}

$response

#curl -H "Authorization: Bearer $token " -XPOST "http://artifactory-up:8082/access/api/v1/tokens" -d  '{"description" : "YOUR-DESCRIPTION", "token_id" : "YOUR-TOKEN-ID", "scope" : "applied-permissions/admin", "token_type" : "access_token", "include_reference_token" : "true"}' -H "Content-type: application/json" 

$response.Content
