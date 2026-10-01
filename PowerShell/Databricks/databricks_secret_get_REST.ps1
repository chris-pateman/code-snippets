# Define variables
$workspaceUrl = "https://999999999999999999.5.azuredatabricks.net"
$scopeName = "application-secret-scope"
$token = "**********"
$key = "artifactory_token"

# Construct the API URL
$apiUrl = "$workspaceUrl/api/2.0/secrets/get?scope=$scopeName&key=$key"

# Make the API call
$response = Invoke-RestMethod -Method Get -Uri $apiUrl -Headers @{
    Authorization = "Bearer $token"
}

# Output the secret value
$secretValue = $response.value
Write-Output "Secret Value: $secretValue"
