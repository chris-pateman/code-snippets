
$jsonPath = ".\code-repos\automation\entities\Flow\applications\flow-application.json"

$file = Get-Content -Path $jsonPath -replace "`n",", " -replace "`r",", " | ConvertFrom-Json

$currentChecksum = $file."_checksum"
Write-Host "Current checksum: $currentChecksum"

#$file."_checksum" = [NullString]::Value
$fileStr = $file | ConvertTo-Json -Depth 100

Set-Content -Path .\code-repos\personal\snippets\PowerShell\temp.json -Value $fileStr
$content = Get-Content -Path .\code-repos\personal\snippets\PowerShell\temp.json #-Raw

$hasher = [System.Security.Cryptography.SHA256]::Create()
$fileBytes = [System.Text.Encoding]::UTF8.GetBytes($file.ToString())

$signSHA=$hasher.ComputeHash($fileBytes)

Write-host "signSHA: $signSHA"

$hexString = [System.Convert]::ToHexString($signSHA)

Write-Host "New hexString: $hexString"
Write-Host "New signSHA: $signSHA"


if ($currentChecksum -eq $newChecksum.Hash){
    Write-host "ALL GOOD"

} else {
    Write-host "Does not match"
}


