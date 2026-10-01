$InformationPreference = "Continue"
$folderPath = ".\pateman.workspace\code-repos\Internal\SqlExecution"

$scripts = Get-ChildItem -Path $folderPath -Filter "*.ps1" -Recurse

foreach ($script in $scripts) {

  $scriptPath = $script.FullName
  Write-Information "--------------------------------------"
  Write-Information "Run  $scriptPath"
  Write-Information "--------------------------------------"

  $script = Get-Content -Path  $scriptPath -Raw

  $formattedScript = Invoke-Formatter -ScriptDefinition $script

  if ($script -ne $formattedScript) {
    Write-Information "Updating format"
    #$formattedScript
    Set-Content -Path $scriptPath -Value $formattedScript
  }

  Invoke-ScriptAnalyzer -Path $scriptPath

  Write-Information "--------------------------------------"
  Write-Information " "
}
