

$sqlRg = "cp-core-infra-test1"
$sqlServerName = "cp-core-infra-test1"
$rulePrefix = "notification-api"
$existingRules = az sql server firewall-rule list -g $sqlRg -s $sqlServerName --query "[?contains(name, '$rulePrefix')].{Name:name}" -o json | ConvertFrom-Json

Write-Host "Delete All Existing Rules starting with $rulePrefix"
foreach ($rule in $existingRules) {
  $ruleName = $rule.Name
  Write-Host "Delete Rule $ruleName"
  #az sql server firewall-rule delete --name $ruleName -g $sqlRg -s $sqlServerName
}
Write-Host ""

function AddIps {
  param (
    $outboundIps
  )
  
  Write-Host "Adding new Rules for $appName"
  for ($i = 0; $i -le $outboundIps.length; $i++) {
    $ruleIp = $outboundIps[$i]
    $ruleName = "$rulePrefix$i"
    Write-Host "Add Rule $ruleName with value $ruleIp"
    #az sql server firewall-rule create -g $sqlRg -s $sqlServerName -n $ruleName --start-ip-address $ruleIp --end-ip-address $ruleIp
  }
}

$appRg = "cp-notification-api-test1"
$appName = "cp-notification-api-test1"

$outboundIps = az webapp show --name $appName --resource-group $appRg --query "outboundIpAddresses" -o tsv
$outboundIps = $outboundIps.Split(",")
AddIps -outboundIps $outboundIps

$addOptional = $true
if ($addOptional -eq $true) {
  $additionalIps = az webapp show --name $appName --resource-group $appRg --query "possibleOutboundIpAddresses" -o tsv
  $additionalIps = $additionalIps.Split(",")
  AddIps -outboundIps $additionalIps
}


