$env="prod"
$database_name="cpvideo"
$resource_group_name="cp-infra-core-$env"
$server="cp-infra-core-$env"
$operationId="0de54442-6000-43e1-be0b-63470dc4bcf6"

az sql db op cancel -g $resource_group_name -s $server -d $database_name -n $operationId