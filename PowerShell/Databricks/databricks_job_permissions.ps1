
$adb_jobs = databricks jobs list -o json | ConvertFrom-Json
$assignable_groups = @("data_engineer_dev", "admins")
$new_permissions = "CAN_MANAGE"

foreach ($adb_job in $adb_jobs){
    Write-Host "Checking permissions for $($adb_job.settings.name)"
    $current_permissions = databricks jobs get-permissions $adb_job.job_id -o json | ConvertFrom-Json

    $permissions_request = @{
        access_control_list = @()
    }
    foreach ($permission in $current_permissions.access_control_list){
        $permissions_request.access_control_list += @{
            group_name = $permission.group_name
            permission_level = $permission.all_permissions.permission_level
        }
    }

    foreach ($group in $assignable_groups){
        if ($current_permissions.access_control_list.group_name -contains $group){
            Write-Host "$group is currently assigned $($($current_permissions.access_control_list | Where-Object {$_.group_name -eq $group}).all_permissions.permission_level)"
        } else {
            Write-Host "$group is not assigned access"
        }
    }
}

#databricks jobs get-permission-levels

<#


get-permission-levels Get job permission levels.
  get-permissions       Get job permissions.
  set-permissions       Set job permissions.
  update-permissions    Update job permissions.
#>

<#

   {
      "description":"Is Owner grants all permissions of Can Manage. Additionally, the credentials of the job owner will be used to run the job. Only a workspace admin can change the job owner.",
      "permission_level":"IS_OWNER"
    },
    {
      "description":"Can Manage Run permission to view, trigger or cancel job runs.",
      "permission_level":"CAN_MANAGE_RUN"
    },
    {
      "description":"Can View permission to view job run results.",
      "permission_level":"CAN_VIEW"
    },
    {
      "description":"Can Manage grants permission to view, trigger and cancel job runs as well as edit the job.",
      "permission_level":"CAN_MANAGE"
    }
#>