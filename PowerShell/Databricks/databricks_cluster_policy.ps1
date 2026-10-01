$policy_id = "00172BD798952987"
$policy_name = "Personal Compute"
$policy_family = "personal-vm"

$policy_override = @{
    max_clusters_per_user = @{
      type= "integer"
      value= 5
      hidden= $false
      defaultValue= 5
    }
  }

databricks cluster-policies edit $policy_id "$policy_name" --policy-family-id $policy_family --policy-family-definition-overrides "$($policy_override | ConvertTo-Json -Compress -Depth 100).replace("`"", "\`"")" --debug