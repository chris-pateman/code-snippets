keyVaultName="cp-sbox-kv"
certName="cp-sbox-le-cert"

certId=$(az keyvault certificate show --vault-name $keyVaultName --name $certName --query "id" -o tsv)

expired='false'
if [[ $certId != "" ]]; then
  echo "Certificate Found"
  expiryDate=$(az keyvault certificate show --vault-name $keyVaultName --name $certName --query "attributes.expires" -o tsv)

  echo "Certificate Expires $expiryDate"
  expiryDate="$(date -d "$expiryDate - 14 days" +%Y%m%d)"
  echo "Certificate Forced Expiry is $expiryDate"
  today=$(date +%Y%m%d)

  if [[ $expiryDate -lt $today ]]; then
    echo "Certificate has expired"
    $expired='true'
  else
    echo "Certificate has NOT expired"
  fi

else
  echo "Certificate NOT Found"
  $expired='true'
fi
