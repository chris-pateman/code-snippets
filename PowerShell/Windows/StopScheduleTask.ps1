Param(
  [string]$TaskNames,
  [int]$SleepSeconds
)

# Loop each task
Foreach ($taskName in $TaskNames.split(',')){

    # Check task exists
    $Task = Get-ScheduledTask -TaskName "$taskName" -ErrorAction SilentlyContinue
    if ($Task.TaskName -contains $taskName){
        Stop-ScheduledTask -TaskName "$taskName"
        Disable-ScheduledTask -TaskName "$taskName"    
    } else {
        Write-Host($taskName + " doesn't exist");
    }

     if((get-process "$taskName" -ea SilentlyContinue) -ne $Null)
        { 
             Stop-Process -processname $taskName -Force
             Write-Host($taskName + " Console app process is terminated");
        }

    # Use account LOCALSERVICE
}


# Sleep Process
Start-Sleep -s $SleepSeconds
