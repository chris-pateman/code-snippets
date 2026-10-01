

sslPath="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Azure/PowerShell/kv/certs/generated/LE_PROD/353081880/cp-recording.sandbox.platform.cp.net"
testSslPath="./\test-area\cert"


psGenPath="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Azure/PowerShell/kv/certs/generated"

output="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Bash/openssl/generated"
jksPass="phu3rtq5Ut_TbAm0LI1hyr5hs%hK3Jhu"

openssl pkcs12 -export -out "$psGenPath/fullchain-withkey.pfx" -in "$psGenPath/fullchain-withkey.pem" -passin pass: -passout pass:${jksPass}

sslPath="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Azure/PowerShell/kv/certs/generated/LE_PROD/353081880/cp-recording.sandbox.platform.cp.net"
certFile="${sslPath}/cert.cer"
intermediateFile="${sslPath}/chain1.cer"
privateKeyFile="${sslPath}/cert.key"
password="poshacme"

outputPfx="output.pfx"
outputPem="chainCert.pem"
echo "" > ${outputPem}
cat ${certFile} ${intermediateFile} ${privateKeyFile} > ${outputPem}

openssl pkcs12 -export -out ${outputPfx} -in ${outputPem} -passin pass:${password} -passout pass:${password}

echo "##vso[task.setvariable variable=pfxPath;isOutput=true]${outputPfx}"
echo "##vso[task.setvariable variable=pfxPass;isOutput=true;issecret=true]$password"