param (
    $subnets,
    $vnet,
    $rg
)

$missingNsg = @()

foreach ( $subnet in $subnets.split(',')) {
    $data = az network vnet subnet show --name $subnet --vnet-name $vnet -g $rg | ConvertFrom-Json
    if (!($($data.name) -eq "AzureFirewallSubnet")) {
        if (!($data.networkSecurityGroup)) {
            $missingNsg += $($data.name)
        }
    }
}

if ($missingNsg) {
    $string = $missingNsg -join ", "
    write-host "{""check"": ""FAIL"", ""missingNSG"":""$string""}"
}
else {
    write-host "{""check"": ""OK"", ""missingNSG"":""""}"
}