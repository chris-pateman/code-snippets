

sslPath="${SSL_PATH:?Set SSL_PATH to the certificate directory}"
testSslPath="${TEST_SSL_PATH:-./test-area/cert}"


psGenPath="${CERT_OUTPUT_PATH:-./generated}"

output="${OUTPUT_PATH:-./generated}"
jksPass="${PFX_PASSWORD:?Set PFX_PASSWORD before running this script}"

openssl pkcs12 -export -out "$psGenPath/fullchain-withkey.pfx" -in "$psGenPath/fullchain-withkey.pem" -passin pass: -passout pass:${jksPass}

sslPath="${SSL_PATH:?Set SSL_PATH to the certificate directory}"
certFile="${sslPath}/cert.cer"
intermediateFile="${sslPath}/chain1.cer"
privateKeyFile="${sslPath}/cert.key"
password="${PFX_PASSWORD:?Set PFX_PASSWORD before running this script}"

outputPfx="output.pfx"
outputPem="chainCert.pem"
echo "" > ${outputPem}
cat ${certFile} ${intermediateFile} ${privateKeyFile} > ${outputPem}

openssl pkcs12 -export -out ${outputPfx} -in ${outputPem} -passin pass:${password} -passout pass:${password}

echo "##vso[task.setvariable variable=pfxPath;isOutput=true]${outputPfx}"
echo "##vso[task.setvariable variable=pfxPass;isOutput=true;issecret=true]$password"