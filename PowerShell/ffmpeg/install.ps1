$source = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

$currentPath = Get-Location
$downloadPath = "$currentPath\download"
if ((Test-Path -Path $downloadPath) -eq $false) {
  Write-Host "Creating $downloadPath"
  mkdir $downloadPath 
}
$zipFile = "$downloadPath\$(Split-Path -Path $source -Leaf)" 

## DOWNLOAD FFMPEG
if ((Test-Path -Path $zipFile) -eq $false) {
  Write-Host "Downloading $source"
  Write-Host "To $zipFile"
  Invoke-WebRequest -Uri $source -OutFile $zipFile 
}

## EXTRACT PROGRAM
$children = Get-ChildItem -Path $downloadPath -Directory
if ($children.length -lt 1) {
  Expand-Archive -LiteralPath $zipFile -DestinationPath $downloadPath
}

##PATH
$tries=0
$max=5
while ($children.length -lt 1){
  if ($tries -eq $max){
    break;
  }
  if ($children.length -lt 1) {
    $tries++
    Write-Host "Not found folder yet"
    Start-Sleep -Seconds 5
    $children = Get-ChildItem -Path $downloadPath -Directory
    continue;
  } else {
    break;
  }
}

$ffmpegPath = "$downloadPath/$($children[0].name)/bin"
Write-Host "##vso[task.setvariable variable=ffmpegPath;isOutput=true]$ffmpegPath"