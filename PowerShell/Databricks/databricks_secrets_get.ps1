# Define variables
$workspaceUrl = "https://9999999999999999.5.azuredatabricks.net"
$scopeName = "application-secret-scope"
$token = "**********"

# Set headers
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}

# Construct API URL
$apiUrl = "$workspaceUrl/api/2.0/secrets/list?scope=$scopeName"

# Make the request
$response = Invoke-RestMethod -Method Get -Uri $apiUrl -Headers $headers

# Output the secret keys
$response.secrets | ForEach-Object {
    Write-Output "Key: $($_.key)"
}
