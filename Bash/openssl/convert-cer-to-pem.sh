sslPath="${SSL_PATH:?Set SSL_PATH to the certificate directory}"

openssl x509 -inform der -in "$sslPath/fullchain.cer" -out "$sslPath/cert.pem" 