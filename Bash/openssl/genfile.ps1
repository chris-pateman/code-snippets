
$pfxPassword="poshacme"
$certPath="./\CodeSnippets\snippets\Azure\PowerShell\kv\certs\generated\LE_PROD\353081880\cp-recording.sandbox.platform.cp.net"

openssl pkcs12 -export -out "$certPath/fullPfx.pfx" -in "$certPath/fullchain.pem" -passin pass: -passout pass: $pfxPassword