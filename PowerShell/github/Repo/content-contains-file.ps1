$org="cp"
$repo = "cp-shared-infrastructures"

$path=".github"
$files=$(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/contents/$path | ConvertFrom-Json)

$filesToCheck=@("stale.yml","renovate.json","dependabot.yml","PULL_REQUEST_TEMPLATE.md","ISSUE_TEMPLATE.md","CONTRIBUTING.md")

foreach ($fileName in $filesToCheck) {
  $contains=$($files | Where-Object {$_.type -eq "file" -and $_.name -eq $fileName})
  if ($null -eq $contains -or $contains -eq "" ){
    Write-Host "Path $path does not contain $fileName"
  } else {
    Write-Host "Path $path does contain $fileName"
  }
}