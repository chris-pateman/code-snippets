$workspace_ids = @{
  dev = "9999999999"
}
$profiles = @{
  default = "DEFAULT"
}

$workspace_id = $workspace_ids.edp_dev
$profile = $profiles.edp_uat
$type = "external_location"
#catalog
#storage_credential
#external_location

$names = @(
  "raw_lseg_edp_uat_externallocation"
)
$principal_name = "edp_dev_edp_acc_devops_engineer"
$grant = "BROWSE"

foreach ($name in $names) {
  Write-Host "name is $name"
  Write-Host "type is $type"
  $json = '{  \"changes\": [    {      \"principal\": \"' + $principal_name + '\",      \"add\": [        \"' + $grant + '\"      ],      \"remove\": [  ]    }  ]}'
  databricks grants update $type $name --json $json -p $profile
}

