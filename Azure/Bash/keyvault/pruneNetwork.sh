
kvName="cp-sbox-kv"
rgName="cp-sharedinfra-sbox"

rules=$(az keyvault network-rule list --name $kvName --resource-group $rgName --query "ipRules[*].value" -o tsv)

for rule in $rules
{
    echo "Removing $rule"
    az keyvault network-rule remove --name $kvName --resource-group $rgName --ip-address $rule --no-wait
}