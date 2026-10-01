$domain = "ml-mlw.uksouth.notebooks.azure.net"

Write-Host " "
Write-Host "Test-NetConnection -ComputerName $domain -Port 443"
Test-NetConnection -ComputerName $domain -Port 443

Write-Host " "
Write-Host "nslookup $domain"
nslookup $domain

