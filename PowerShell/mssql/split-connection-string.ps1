

$connectionString = "Server=tcp:cp-core-infra-preview.database.windows.net,1433;Initial Catalog=cpbookings;Persist Security Info=False;User ID=hvhearingsapiadmin;Password=******;MultipleActiveResultSets=False;Encrypt=True;"
$connectionValues = $connectionString -replace ';',"`r`n" |ConvertFrom-StringData

$connString = $connectionValues["Server"]
$serverNameAndPort = $($connString -replace 'tcp:','').Split(",")
$port = $serverNameAndPort[1]
$serverName = $serverNameAndPort[0]
$initialCatalog = $connectionValues["Initial Catalog"]
$userId = $connectionValues["User ID"]
$password = $connectionValues["Password"]

Write-Host "connString: $connString"
Write-Host "Server Name: $serverName"
Write-Host "Port: $port"
Write-Host "Initial Catalog: $initialCatalog"
Write-Host "User Id: $userId"

Write-Host("##vso[task.setvariable variable=prop.serverName;isOutput=true]$serverName")
Write-Host("##vso[task.setvariable variable=prop.port;isOutput=true;issecret=true]$port")
Write-Host("##vso[task.setvariable variable=prop.database;isOutput=true]$initialCatalog")
Write-Host("##vso[task.setvariable variable=prop.userId;isOutput=true]$userId")
Write-Host("##vso[task.setvariable variable=prop.password;isOutput=true;issecret=true]$password")