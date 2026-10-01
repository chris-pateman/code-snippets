# Global Vars
$database_name="cpbookings"
$temp_container_name="db-backup"
$date=$(Get-Date -Format dd-mm-yyyy)
$bacpac_name="$($database_name)_$date.bacpac"

#assign vars for source
$source_env="dev"
$source_resource_group="cp-core-infra-$source_env"
$source_server="cp-core-infra-$source_env"
$source_storage="cpcoreinfra$source_env"
$source_secret_name="cpBookingsDatabaseConnectionString"
$source_vault_name="cpcoreinfraht$source_env"
$source_subscription="cp-Dev"
#assign vars for target
$env="dev"
$resource_group_name="cp-infra-core-$env"
$server="cp-infra-core-$env"
$storage="cpinfracore$env"
$secret_name_username="db-admin-username"
$secret_name_password="db-admin-password"
$vault_name="cp-infra-core-$env"
$subscription="$($env)"

Write-Host "Set Sub $source_subscription"
az account set -s $source_subscription

Write-Host "Add Key Vault Access"
$myIp=(Invoke-WebRequest -uri "http://ifconfig.me/ip" -UseBasicParsing).Content
$myIpRule = az keyvault network-rule list --name $source_vault_name --resource-group $source_resource_group --query "ipRules[? contains(value,'$myIp')]" -o json | ConvertFrom-Json 
if ($null -eq $myIpRule -or !$myIpRule -or $myIpRule.length -lt 1){
  Write-Host "Adding IP $myIp"
  az keyvault network-rule add --name $source_vault_name --resource-group $source_resource_group --ip-address $myIp
} else {
  Write-Host "IP $myIp already added"
}

Write-Host "Get Connection Settings"
$connectionString = az keyvault secret show --name $source_secret_name --vault-name $source_vault_name -o tsv --query "value"
$connectionValues = $connectionString -replace ';',"`r`n" |ConvertFrom-StringData
$source_login = $connectionValues["User ID"]
$source_password = $connectionValues["Password"]


Write-Host "Getting storage key"
$source_key=$(az storage account keys list -n $source_storage --resource-group $source_resource_group  -o tsv --query "[0].value")
 
# create source container
Write-Host "Creating $temp_container_name on $source_storage..."
$exist=az storage container exists --account-name $source_storage --account-key $source_key --name $temp_container_name --query "exists" -o tsv

if ($exist -eq $false){
  Write-Host "Container $temp_container_name does not exist"
  az storage container create -n $temp_container_name --account-key $source_key --account-name $source_storage
}
 
#backup source
Write-Host "Backing up $database_name from $source_server"
az sql db export -p $source_password --admin-user $source_login --storage-key $source_key --storage-key-type StorageAccessKey --storage-uri "https://$source_storage.blob.core.windows.net/$temp_container_name/$bacpac_name" --name $database_name -g $source_resource_group --server $source_server

Write-Host "Switch subscription to $subscription"
az account set -s $subscription; # Choose required subscription
 
Write-Host "Get Connection Settings"
$login = az keyvault secret show --name $secret_name_username --vault-name $vault_name -o tsv --query "value"
$password = az keyvault secret show --name $secret_name_password --vault-name $vault_name -o tsv --query "value"

# Get storage account key
Write-Host "Getting key.."
$key=$(az storage account keys list -n $storage --resource-group $resource_group_name  -o tsv --query "[0].value")
 
Write-Host "Creating $temp_container_name on $storage..."
$exist=az storage container exists --account-name $storage --account-key $key --name $temp_container_name --query "exists" -o tsv

if ($exist -eq $false){
  Write-Host "Container $temp_container_name does not exist"
  az storage container create -n $temp_container_name --account-key $key --account-name $storage
}
 
#copy from source sub to target sub
Write-Host "Copying to new storage..."
az storage blob copy start --account-name $storage --auth-mode key --account-key $key --destination-container $temp_container_name --destination-blob $bacpac_name --source-account-name $source_storage --source-account-key $source_key --source-container $temp_container_name --source-blob $bacpac_name
 
 
Write-Host "Importing database from $container to $database..."
Write-Host "Whitelist Azure Services"
az sql server firewall-rule create -g $resource_group_name -s $server -n "allow-azure-services" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
Write-Host "Change Admin to Current User"
$currentAdmin = az sql server ad-admin list -g $resource_group_name --server $server --query "[0]" -o json | ConvertFrom-Json
$currentUser = az ad signed-in-user show -o json | ConvertFrom-Json
az sql server ad-admin create --display-name $currentUser.displayName --object-id $currentUser.objectId -g $resource_group_name -s $server

Write-Host "Clear Database"
$token = $(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv)
$sql_fqdn = "$server.database.windows.net"
$query = "while(exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_TYPE='FOREIGN KEY'))
begin
 declare @sql nvarchar(2000)
 SELECT TOP 1 @sql=('ALTER TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME
 + '] DROP CONSTRAINT [' + CONSTRAINT_NAME + ']')
 FROM information_schema.table_constraints
 WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
 exec (@sql)
 PRINT @sql
end

while(exists(select 1 from INFORMATION_SCHEMA.TABLES 
             where TABLE_NAME != '__EFMigrationsHistory' 
             AND TABLE_TYPE = 'BASE TABLE'))
begin
 --declare @sql nvarchar(2000)
 SELECT TOP 1 @sql=('DROP TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME
 + ']')
 FROM INFORMATION_SCHEMA.TABLES
 WHERE TABLE_NAME != '__EFMigrationsHistory' AND TABLE_TYPE = 'BASE TABLE'
exec (@sql)
 /* you dont need this line, it just shows what was executed */
 PRINT @sql
end

exec ('DROP TABLE dbo.__EFMigrationsHistory')
"
Invoke-SqlCmd -ServerInstance $sql_fqdn -Database $database_name -Query $query -AccessToken $token 

Write-Host "Import Database"
az sql db import -p $password --admin-user $login --storage-key $key --storage-key-type StorageAccessKey --storage-uri "https://$storage.blob.core.windows.net/$temp_container_name/$bacpac_name" --name $database_name -g $resource_group_name --server $server
az sql server firewall-rule delete -g $resource_group_name -s $server -n "allow-azure-services"

Write-Host "Change Admin to Current User $($currentAdmin.login)"
az sql server ad-admin create --display-name $currentAdmin.login --object-id $currentAdmin.sid -g $resource_group_name -s $server
