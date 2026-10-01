
testIp="127.0.0.1"
openssl s_client -connect "$testIp:443" 2>/dev/null | openssl x509 -noout -checkend 0

openssl s_client -connect "$testIp:443" -state -showcerts -debug

sslPath="${SSL_PATH:?Set SSL_PATH to the certificate directory}"
testSslPath="${TEST_SSL_PATH:?Set TEST_SSL_PATH to the trusted certificate directory}"
openssl verify -CAfile "$testSslPath/isrgrootx1.cer" "$testSslPath/lets-encrypt-r3.pem" "$sslPath/cert.cer" "$sslPath/cert.cer"

