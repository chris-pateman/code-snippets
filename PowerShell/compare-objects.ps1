$csvPath = ".\pateman.workspace\code-repos\personal\snippets\test-csv.csv"# "$path/$fileName"
$settings = Import-Csv $csvPath

$validSettings = @("SettingName","SettingValue")
$validSettingNames = @("ServerName","DatabaseName")

$resulthere = Compare-Object $validSettingNames $validSettings
$resulthere | ForEach-Object { 
  if ($_.SideIndicator -eq "=>"){
    Write-host "$($_.InputObject) is additional in the file"
  } else {
    Write-host "$($_.InputObject) is missing from the file"
  }
}
if ($resulthere -and $resulthere.lenght -gt 0){
  Write-Host "Does not match"
}

Write-host " "
Write-host " "