$jsonPath = ".\CodeSnippets\snippets\AzureDevOps\Bash\APIM-BUILD-SBOX.json"

$variablesJson = Get-Content $jsonPath | Out-String | ConvertFrom-Json

$names = ""
$variablesJson.variables.PSObject.Properties | ForEach-Object {
  $name = $_.Name
  if ($name -like "tf_secret_*") {
    Write-Host "Found: $name"
    $names += ",$name"
  }
}
"##vso[task.setvariable variable=names;isOutput=true]$names"