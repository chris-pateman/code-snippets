$databricksHost = "https://99999999999.8.azuredatabricks.net"

$databricksToken = "**********"

#"$databricksHost/api/2.0/preview/scim/v2/Groups/"
$account_id= "06f3208f-2c88-4913-ac29-122c601fee4d"
$group_id= "994631581784425"
$get_group_set = "/api/2.0/accounts/$account_id/scim/v2/Groups/$group_id"

$response = Invoke-RestMethod -Uri "https://accounts.azuredatabricks.net$get_group_set" `
                              -Method Get `
                              -Headers @{
                                  #"Content-Type" = "application/json"
                                  "Authorization" = "Bearer $databricksToken"
                              } 
                              #-Body $($jsonData | ConvertTo-Json -Compress -Depth 100)

$response

