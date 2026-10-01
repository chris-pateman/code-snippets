Param(
    $userKey
)

. 'PowerShell\api.ps1'

##gcloud login
$token = (gcloud auth print-access-token)

Write-Host("userKey = $userKey")
$requestUrl = "https://www.googleapis.com/admin/directory/v1/users/$userKey"

$response = DeleteRequest -requestUrl $requestUrl -tokenType 'Bearer' -token $token

Write-Host("Results:")
Write-Host($response)

