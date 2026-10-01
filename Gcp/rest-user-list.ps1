. 'PowerShell\api.ps1'

##gcloud login
$token = (gcloud auth print-access-token)

$requestUrl = "https://www.googleapis.com/admin/directory/v1/users?"
$requestUrl += AddQueryString -name "domain" -value "gdcs-gcp.com" ## primary domain name
$requestUrl += AddQueryString -name "pageToken" -value "" ## token for next results page
$requestUrl += AddQueryString -name "maxResults" -value "100" ## max number of results per page
$requestUrl += AddQueryString -name "orderBy" -value "email" ## email, givenName, or familyName
$requestUrl += AddQueryString -name "sortOrder" -value "ascending" ## ascending or descending
$requestUrl += AddQueryString -name "query" -value "" ## email, givenName, or familyName:the query's value*

$response = GetRequest -requestUrl $requestUrl -tokenType 'Bearer' -token $token

Write-Host("Results:")
Write-Host($response)
Write-Host("Users:")
Write-Host( $response.users | ConvertTo-Json)
