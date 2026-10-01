Param(
  [string]$TaskName,
  [string]$TaskLocation,
  [string]$AccountName,
  [string]$Arguments,
  [string]$DelayTimeMinutes,
  [string]$InfrastuctureAsCodeLocation
)
if (!$DelayTimeMinutes){
    $DelayTimeMinutes = 0;
}
$DealyTime = New-TimeSpan -Minutes $DelayTimeMinutes
$ScriptName = "RunMessageManagementExe.bat"
$TaskPath = Split-Path "$TaskLocation" -Parent
$TaskExe = Split-Path "$TaskLocation" -Leaf

# Set Up Task details
Write-Host "Create Schedule Task Properties"

$action = New-ScheduledTaskAction -Execute "$ScriptName" -Argument "$TaskExe $TaskPath" -WorkingDirectory "$InfrastuctureAsCodeLocation"
$trigger = New-ScheduledTaskTrigger -Once -AT "01:00"
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
