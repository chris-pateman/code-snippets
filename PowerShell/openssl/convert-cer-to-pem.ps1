$sslPath = $env:SSL_PATH
$testSslPath = $env:TEST_SSL_PATH

if ([string]::IsNullOrWhiteSpace($sslPath) -or [string]::IsNullOrWhiteSpace($testSslPath)) {
	throw "Set SSL_PATH and TEST_SSL_PATH before running this script."
}
openssl x509 -inform der -in "$testSslPath/cp-net_1aaf9372593c4ed1a94a6bdddfe2f8aa.cer" -out "$testSslPath/cp-aat-platform-cp-net.pem" 
