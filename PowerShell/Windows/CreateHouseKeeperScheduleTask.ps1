Param(
  [string]$TaskName,
  [string]$ScriptLocation,
  [string]$ScriptName,
  [string]$AccountName
)


# Set Up Task details
Write-Host "Create Schedule Task Properties"

$action = New-ScheduledTaskAction -Execute "$ScriptName" -WorkingDirectory "$ScriptLocation"
$trigger = @(
    $(New-ScheduledTaskTrigger -Once -AT "08:30"),
    $(New-ScheduledTaskTrigger -Once -AT "15:00")
)
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit ([TimeSpan]::FromHours(1)) 
$principal = New-ScheduledTaskPrincipal -UserID "$AccountName" -LogonType ServiceAccount -RunLevel Highest
$inputObject = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal

# Check if exists
$Task = Get-ScheduledTask -TaskName "$TaskName" -ErrorAction SilentlyContinue
if ($Task.TaskName -contains $TaskName){
    # Update task
    Write-Host "Schedule Task $TaskName Exists"
    Write-Host "Updateing Schedule Task $TaskName"
    Set-ScheduledTask -TaskName "$TaskName" -Action $action -Trigger $trigger -Settings $settings -Principal $principal
} else {
    # Create Task
    Write-Host "Schedule Task $TaskName does NOT Exists"
    Write-Host "Creating Schedule Task $TaskName"
    Register-ScheduledTask -TaskName "$TaskName" -InputObject $inputObject 
}

# Enable Schedule task
Write-Host "Enable $TaskName"
Enable-ScheduledTask -TaskName "$TaskName"
Start-ScheduledTask -TaskName "$TaskName"

# Use account LOCALSERVICE
Write-Host "Exit Script"
exit
