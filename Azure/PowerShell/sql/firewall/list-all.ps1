$resource_group_name="cp-infra-core-dev"
$server="cp-infra-core-dev"

az sql server firewall-rule list -g $resource_group_name -s $server