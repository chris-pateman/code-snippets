sslPath="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Azure/PowerShell/kv/certs/generated/LE_STAGE/39660938/cp-recording.sandbox.platform.cp.net"

openssl x509 -inform der -in "$sslPath/fullchain.cer" -out "$sslPath/cert.pem" 