$resource_group_name="cp-infra-core-dev"
$server="cp-infra-core-dev"


az sql server firewall-rule delete -g $resource_group_name -s $server -n "allow-azure-services"