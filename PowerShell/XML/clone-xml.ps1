$additionalNuspecName = @('test')
$baseNuspecName = "Automation.nuspec"
$nuspecRootPath = "automation\package"

### Get Base Package
$baseNuspecPath = "$nuspecRootPath/$baseNuspecName"
Write-Host "Base Nuspec File: $baseNuspecPath"
[xml]$baseNuspec = Get-Content -Path $baseNuspecPath
Write-Host $baseNuspec.package.metadata.version

### Loop Additional Packages
foreach ($nuspecName in $additionalNuspecName){
  
  ### Get Additional Nuspec  
  if (!($nuspecName -like "*.nuspec")){
    $nuspecName += ".nuspec"
  }
  Write-Host "Additional Nuspec File: $nuspecName"
  [xml]$nuspec = Get-Content -Path "$nuspecRootPath/$nuspecName"

  ### Merge Base Nuspec Files to Additional Nuspec Files
  Write-Host "Update Files (before: $($nuspec.package.files.file.count))"
  $nuspec.package.files.InnerXml += $baseNuspec.package.files.InnerXml
  Write-Host "Updated Files (after: $($nuspec.package.files.file.count))"

  ### Merge Base Nuspec Metadata to Additional Nuspec Metadata
  foreach ($node in $baseNuspec.package.metadata.ChildNodes){
    if (!($nuspec.package.metadata.ChildNodes.name -contains $node.name)){
      Write-host "Does not contain XML Node: $($node.name)"
      Write-Host "Add new Node"
      $metadataNode = $nuspec.CreateElement($node.name)
      $metadataNode.InnerText = $node.InnerText
      $nuspec.package.metadata.AppendChild($metadataNode)
    }
  }
  
  ### Write new Nuspec
  Write-Host "Create new XML Document"
  $newNuspecName = $nuspecName -replace ".nuspec",".final.nuspec"
  Set-Content -Path "$nuspecRootPath/$newNuspecName" -Value $nuspec.InnerXML

}