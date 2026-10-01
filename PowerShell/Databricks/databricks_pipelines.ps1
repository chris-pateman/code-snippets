param (
  [Parameter(Mandatory=$true)]
  [string]
  $pipelinesPath
)

$pipeline_files = @()
Get-ChildItem $pipelinesPath -Filter *.json -Recurse | ForEach-Object {
  $pipeline_files += $(Get-Content -Path $_.fullname -Raw | ConvertFrom-Json)
}

$existing_pipelines = @(@{
  name = "test_name_og"
  pipeline_id ="746f81b7-37ff-421e-a4bb-27e65f5267af"
}, @{
  name = "test_name_two"
  pipeline_id ="746f81b7-37ff-421e-a4bb-27e65f5267bc"
}) #$(databricks pipelines list-pipelines | ConvertFrom-Json)

Write-Host "Create/Update Pipelines"
foreach ($pipeline_file in $pipeline_files){
  if ($existing_pipelines.name -contains $pipeline_file.name){
    $existing_pipeline = $existing_pipelines | Where-Object {$_.name -eq $pipeline_file.name}
    Write-Host "Updating $($pipeline_file.name) - $($existing_pipeline.pipeline_id)"
    #databricks pipelines update $existing_pipeline.pipeline_id --json $(pipeline_file | ConvertTo-Json -Depth 100 -Compress)
  } else {
    Write-Host "Creating $($pipeline_file.name)"
    #databricks pipelines create --json $(pipeline_file | ConvertTo-Json -Depth 100 -Compress)
  }
  Write-Host ""
}

Write-Host "Delete Pipelines"
for ($i = 0; $i -lt $existing_pipelines.Count; $i++) {
  $existing_pipeline = $existing_pipelines[$i]
  if (!($pipeline_files.name -contains $existing_pipeline.name)){
    Write-Host "Delete $($existing_pipeline.name) - $($existing_pipeline.pipeline_id)"
    #databricks pipelines delete  $existing_pipeline.pipeline_id
    Write-Host ""
  }
}
