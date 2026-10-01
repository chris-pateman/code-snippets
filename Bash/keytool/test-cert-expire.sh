keyVaultName="cp-sbox-kv"
certName="cp-sbox-le-cert"
domain="cp-recording.sandbox.platform.cp.net"

jksPath="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Bash/keytool/generated/exported.jks"
jksPass="poshacme"
pfxPath="generated/cert.pfx"

expiryDate=$(keytool -list -v -keystore $jksPath -storepass $jksPass | grep until | sed 's/.*until: //')

echo "Certificate Expires $expiryDate"
expiryDate="$(date -d "$expiryDate - 14 days" +%Y%m%d)"
echo "Certificate Forced Expiry is $expiryDate"
today=$(date +%Y%m%d)

if [[ $expiryDate -lt $today ]]; then
  echo "Certificate has expired"
  
  rm -rf $pfxPath || true
  az keyvault secret download --file $pfxPath --vault-name $keyVaultName --encoding base64 --name $certName

  keytool -delete -alias $domain -keystore $jksPath -storepass $jksPass
  keytool -importkeystore -srckeystore $pfxPath -srcstoretype pkcs12 -destkeystore $jksPath -deststoretype JKS -deststorepass $jksPass -srcstorepass ''

else
  echo "Certificate has NOT expired"
fi

