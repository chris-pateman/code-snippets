env="sbox"
kvName="cp-shared-kv-${env}"
certName="star-sandbox"

certId=$(az keyvault certificate show-deleted --vault-name $kvName --name $certName --query "id" -o tsv)

if [[ $certId != "" ]]; then
  az keyvault certificate purge --vault-name $kvName --name $certName
fi