# Define variables
$workspaceUrl = "https://99999999999.5.azuredatabricks.net"
$scopeName = "application-secret-scope"
$token = "**********"

# Set headers
$headers = @{
    Authorization = "Bearer $token"
    "Content-Type" = "application/json"
}
$secretsUrl = "$workspaceUrl/api/2.0/secrets/list?scope=$scopeName"
$response = Invoke-RestMethod -Method Get -Uri $secretsUrl -Headers $headers
$secretKeys = $response.secrets | Select-Object -ExpandProperty key

foreach ($key in $secretKeys) {
    $deleteSecretUrl = "$workspaceUrl/api/2.0/secrets/delete"
    $body = @{
        scope = $scopeName
        key = $key
    } | ConvertTo-Json
    Invoke-RestMethod -Method POST -Uri $deleteSecretUrl -Headers $headers -Body $body
    Write-Output "Deleted secret: $key"
}

$deleteScopeUrl = "$workspaceUrl/api/2.0/secrets/scopes/delete"
$body = @{
    scope = $scopeName
} | ConvertTo-Json
Invoke-RestMethod -Method POST -Uri $deleteScopeUrl -Headers $headers -Body $body
Write-Output "Deleted scope: $scopeName"
