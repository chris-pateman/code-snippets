

kvName="cp-sbox-kv"
oid=$(oid)
env="sbox"
certName="STAR-sandbox-platform-cp-net"
kvNamePrefix="cpapps"
sourceKvName="$kvNamePrefix-$env"
echo "Logged in as oid $oid"

echo "Copy wildcard cert from cpapps"
az keyvault secret download --id https://$sourceKvName.vault.azure.net/secrets/$certName -f cert.pfx
base64 -d cert.pfx > cert-up.pfx

echo "Get Existing cert from cp"
az keyvault secret download --id https://$kvName.vault.azure.net/secrets/$certName -f cert.pfx
base64 -d cert.pfx > cert-existing.pfx

cpappsCert="../../../../../test-area/examplecert - Copy.cer"
cpCert="../../../../../test-area/examplecert.cer"

if cmp -s "$cpappsCert" "$cpCert"; then
    printf 'The file "%s" is the same as "%s"\n' "$cpappsCert" "$cpCert"
else
    printf 'The file "%s" is different from "%s"\n' "$cpappsCert" "$cpCert"
fi

kvName="$(kvName)"
oid=$(oid)
env="${{ parameters.env }}"
certName="${{ parameters.certName }}"
kvNamePrefix="$(kv_name_prefix)"
sourceKvName="$kvNamePrefix-$env"
echo "Logged in as oid $oid"

echo "Copy wildcard cert from cpapps"
az keyvault secret download --id https://$sourceKvName.vault.azure.net/secrets/$certName -f cert.pfx

base64 -d cert.pfx > cert-up.pfx

import(){
    echo "Import the cert to our new KV $kvName"
    az keyvault certificate import --file cert-up.pfx --vault-name $kvName --name $certName --verbose
}

echo "Check if cert exists"
kvSecret=$(az keyvault secret download --id https://$kvName.vault.azure.net/secrets/$certName --query "id")
if [ $kvSecret = "" ]; then
    echo "Cert doesn't exist"
    import() 
fi
if [ $kvSecret != "" ]; then
    echo "Cert exists"
    echo "Get Existing cert from cp"
    az keyvault secret download --id https://$kvName.vault.azure.net/secrets/$certName -f cert.pfx
    base64 -d cert.pfx > cert-existing.pfx

    if cmp -s "cert-up.pfx" "cert-existing.pfx"; then
        echo "No Change in Cert"
    else
        echo "Change Required in Cert"
        import()
    fi
fi

echo "Download the cert as a pem file"
az keyvault certificate download --id https://$kvName.vault.azure.net/certificates/$certName -f cert.pem
certPath=`pwd`/cert.pem

echo "Capture cert thumbprint and secret resource id"
cert=$(az keyvault certificate show --id https://$kvName.vault.azure.net/certificates/$certName)
thumbprint=$(echo $cert | jq .x509ThumbprintHex)
secretId=$(echo $cert | jq .sid)

echo "##vso[task.setvariable variable=certPath]$certPath"
echo "##vso[task.setvariable variable=secretId]$secretId"
echo "##vso[task.setvariable variable=thumbprint]$thumbprint"
