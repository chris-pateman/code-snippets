$containerName = "recordings"
$folderLocation = "audiostream1"
$streamName = "test-stream"
$accountName = "cvprecordingsstgsa"
$accessKey = "************"

$blobSearch = "$folderLocation/$streamName"
Write-Host "Searching for $blobSearch in Container:$containerName in Storage Account:$accountName"

$blobs = az storage blob list -c $containerName --prefix $blobSearch --account-name $accountName --account-key $accessKey --only-show-errors -o json | ConvertFrom-Json

$completed = $true
if ($blobs.Length -lt 1) {
  Write-Host "task.LogIssue type=error;]FAILED - No recordings found"
  $completed = $false
}
else {

  $recording = $blobs[0];

  if ($recording.properties.contentLength -lt 1) {
    Write-Host "task.LogIssue type=error;]FAILED - Recording size is 0"
    $completed = $false
  }
}

if ($completed -eq $true) {
  Write-Host '##vso[task.complete result=Succeeded;]DONE'
}
else {
  Write-Host '##vso[task.complete result=Failed;]FAILED'
}