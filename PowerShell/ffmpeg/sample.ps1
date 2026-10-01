$source="https://filesamples.com/samples/video/mp4/sample_640x360.mp4"

$output=".\CodeSnippets\snippets\PowerShell\ffmpeg\audio-example.mp4"

## DOWNLOAD AUDI
if ((Test-Path -Path $output) -eq $false) {
  Invoke-WebRequest -Uri $source -OutFile $output 
}

Write-Host "##vso[task.setvariable variable=audioPath;isOutput=true]$output"