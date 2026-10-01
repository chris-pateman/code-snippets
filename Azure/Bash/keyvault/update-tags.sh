

rgName="cp-sharedinfra-sbox"
kvName="cp-sbox-kv"
env="sbox"
businessArea="Cross-Cutting"
application="CP-Platform"
builtFrom="cp/cp-audio-ingress"
location="uksouth"
subscriptionName="SBOX"
envName=""
if [[ $env == "sbox" ]]; then
  envName="sandbox"
elif [[ $env == "stg" ]]; then
  envName="staging"
elif [[ $env == "prod" ]]; then
  envName="production"
fi

echo "Env: $envName"
tags="businessArea=$businessArea application=$application builtFrom=$builtFrom environment=$envName"
echo "tags: $tags"

echo "Updating $kvName"
kvId=$(az keyvault show --name $kvName --resource-group $rgName --query "id" -o tsv)

echo "Tagging $kvId"
az tag update --resource-id ${kvId//[$'\t\r\n']/} --operation replace --tags $tags --debug