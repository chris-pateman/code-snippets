$databricksHost = "https://adb-99999999999.8.azuredatabricks.net"
$databricksToken = "**********"
$application_id = "ea6bdd71-6014-4154-be17-72a539e92190"
$jsonData = @{
    "application_id"= $application_id
    "lifetime_seconds"= 3600
    "comment"= "This is for the ABC department automation scripts."
  }

$response = Invoke-RestMethod -Uri "$databricksHost/api/2.0/token-management/on-behalf-of/tokens" `
                              -Method Post `
                              -Headers @{
                                  "Content-Type" = "application/json"
                                  "Authorization" = "Bearer $databricksToken"
                              } `
                              -Body $($jsonData | ConvertTo-Json -Compress -Depth 100)

$response