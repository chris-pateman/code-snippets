$resource_group_name="cp-infra-core-dev"
$server="cp-infra-core-dev"


az sql server firewall-rule create -g $resource_group_name -s $server -n "allow-azure-services" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0