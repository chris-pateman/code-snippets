$ffmpegPath=".\code-repos\personal\snippets\PowerShell\ffmpeg\download\ffmpeg-5.1-essentials_build\bin"
$application="audiostream1"
$audioFilePath=".\code-repos\personal\snippets\PowerShell\ffmpeg\audio-example.mp4"
$fileName="cp-deployment-vm1"
$source="20.90.245.136"

$ffmpeg_url="rtmps://$source`:443/$application/$fileName"

Set-Location -Path $ffmpegPath

.\ffmpeg.exe -re -i $audioFilePath -c copy -f flv "$ffmpeg_url flashver=FMLE/3.0\20(compatible;\20FMSc/1.0) live=true pubUser=wowza title=$fileName" -loglevel verbose #2> "$ffmpegPath/output.txt"

Write-Host "FFMPEG Output"
#Write-Host $(Get-Content -Path "$ffmpegPath/output.txt")
