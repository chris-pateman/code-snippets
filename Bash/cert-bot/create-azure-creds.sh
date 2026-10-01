
clientId="14a90b69-46b2-4094-a3d2-fc40c66fbcd1"
tenantId="531ff96d-0ae9-462a-8d2d-bec7c0b42082"
dnsZoneResourceGroup="/subscriptions/ed302caf-ec27-4c64-a05e-85731c3ce90e/resourceGroups/reformmgmtrg"
dnsZoneName="sandbox.platform.cp.net"

#~/.secrets/certbot/azure.ini
filePath=".secrets/certbot/azure.ini"

mkdir ".secrets"
mkdir ".secrets/certbot"
touch $filePath

sudo chmod 777 $filePath

echo "" > $filePath
echo "dns_azure_msi_client_id = $clientId" >> $filePath
echo "dns_azure_tenant_id = $tenantId" >> $filePath
echo "" >> $filePath
echo "dns_azure_zone1 = $dnsZoneName:$dnsZoneResourceGroup" >> $filePath

sudo chmod 400 $filePath