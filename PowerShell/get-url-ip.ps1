
$url="www.ssllabs.com"

$ping = New-Object System.Net.NetworkInformation.Ping
$ip = $($ping.Send($url).Address).IPAddressToString

Write-Host $ip