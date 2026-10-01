Param(
    [String]$ComputerName,
    [String]$AppPool,
    [int]$Action
)

if ($Action -eq "start"){

    Invoke-Command -ComputerName "$ComputerName" -ScriptBlock { Start-WebAppPool -Name "$AppPool" }

} elseif($Action -eq "stop"){
    
    Invoke-Command -ComputerName "$ComputerName" -ScriptBlock { Stop-WebAppPool -Name "$AppPool" }

} elseif ($Action -eq "restart"){
    
    Invoke-Command -ComputerName "$ComputerName" -ScriptBlock { Restart-WebAppPool -Name "$AppPool" }

}