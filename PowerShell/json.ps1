function TestJson(){
    param(
        $text
    )
    try {
        ConvertFrom-Json $text -ErrorAction Stop;
        return $true;
    } catch {
        return $false
    }
}
function PrettyPrintJson {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $json
    )
    $json | ConvertFrom-Json | ConvertTo-Json -Depth 100
}

function Validate-Json {
    $entitiesDirectory = "$PSScriptRoot/../entities"
    $schemaDirectory = "$PSScriptRoot/resources"
    
    Write-host "Entities Path: $entitiesDirectory"
    Write-host "Schema Path: $schemaDirectory"
    
    $entites = @(
      @{
        directory = "$entitiesDirectory/flow/applications"
        schema    = "$schemaDirectory/applications-schema.json"
      },
      @{
        directory = "$entitiesDirectory/flow/application-association"
        schema    = "$schemaDirectory/application-association-schema.json"
      },
      @{
        directory = "$entitiesDirectory/ModelBuilder/dashboards"
        schema    = "$schemaDirectory/dashboards-schema.json"
      }
    )
    
    $allValid = $true
    foreach ($entity in $entites) {
      $jsonDirectory = $entity.directory
      $schemaDirectory = $entity.schema
    
      if (Test-Path -Path $jsonDirectory) {
        $directoryName = Split-Path $jsonDirectory -Leaf
        Write-Host "[group]Checking $directoryName ($jsonDirectory)"
    
        $jsonFiles = Get-ChildItem -Path $jsonDirectory -Filter "*.json"
    
        foreach ($jsonFile in $jsonFiles) {
          Write-Host "[section]Validate $($jsonFile.Name)"
          $jsonContent = Get-Content -Path $jsonFile.FullName -Raw
          $schemaContent = Get-Content -Path $schemaDirectory -Raw
          if ($jsonContent | Test-Json -Schema $schemaContent -ErrorAction SilentlyContinue -ErrorVariable err) {
            Write-Host "$($jsonFile.Name) is valid JSON"
          }
          else {
            Write-Host "$($jsonFile.Name) is invalid JSON: "
            Write-Host $err
            Write-Host "##[error]FAILED: $($jsonFile.Name) is invalid JSON"
            $allValid = $false
          }
        }
        Write-Host "[endgroup]Checking $directoryName"
        Write-Host ""
      }
    }
    
    if ($allValid){
      exit 0
    } else {
      exit 1
    }
    
}