
$directory = ".\CodeRepo\pateman"
$folders = Get-ChildItem -Path $directory -Directory

$sourceType = "azdo" #azdo

$project = "ADO Team - Version 1"
$organisation = "patemanukdcs"

$gitCommand = "git clone"

foreach ($folder in $folders) {
  if ($sourceType -eq "github") {
    Write-Host "$gitCommand git@github.com:$project/$($folder.Name).git"
  }
  elseif ($sourceType -eq "azdo") {
    $encodedProject = [uri]::EscapeUriString($project)
    Write-Host "$gitCommand git@ssh.dev.azure.com:v3/$organisation/$encodedProject/$($folder.Name)"
  }
  else {
    Write-Error "Source Type not set"
  }
}