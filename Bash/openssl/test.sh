
testIp="127.0.0.1"
openssl s_client -connect "$testIp:443" 2>/dev/null | openssl x509 -noout -checkend 0

openssl s_client -connect "$testIp:443" -state -showcerts -debug

sslPath="/mnt/c/Users/patemanc/pateman.workspace/CodeSnippets/snippets/Azure/PowerShell/kv/certs/generated/LE_STAGE/39660938/cp-recording.sandbox.platform.cp.net"
testSslPath="/mnt/c/Users/patemanc/pateman.workspace/test-area/cert"
openssl verify -CAfile "$testSslPath/isrgrootx1.cer" "$testSslPath/lets-encrypt-r3.pem" "$sslPath/cert.cer" "$sslPath/cert.cer"

