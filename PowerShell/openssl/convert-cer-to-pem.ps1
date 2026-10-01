$sslPath="/mnt/c/Users/patemanc/CodeSnippets/snippets/Azure/PowerShell/kv/certs/generated/LE_STAGE/39660938/cp.sandbox.platform.cp.net"
$testSslPath=".\pateman.workspace\test-area\cert"
openssl x509 -inform der -in "$testSslPath/cp-net_1aaf9372593c4ed1a94a6bdddfe2f8aa.cer" -out "$testSslPath/cp-aat-platform-cp-net.pem" 
