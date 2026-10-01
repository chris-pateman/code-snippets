

objectId=$(az ad signed-in-user show --query "objectId" -o tsv)

env="sbox"
kv_name="cp-$env-kv"
sp_id="$objectId"

kvId=$(az keyvault show --name $kv_name --query "id" -o tsv)

if [[ $kvId != "" ]]; then
  echo "Updating KeyVault Permissions"
  az keyvault set-policy --name $kv_name --object-id $sp_id --secret-permissions backup delete get list purge recover restore set --certificate-permissions purge backup create delete deleteissuers get getissuers import list listissuers managecontacts manageissuers setissuers update
else 
  echo "Key Vault doesn't exist"
fi
