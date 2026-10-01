param(
  [Parameter()]
  [string]$sourceBranch="remotes/origin/HEAD",

  [Parameter(Mandatory)]
  [string]$rootDirectory,

  [Parameter(Mandatory)]
  [string]$testFileOrDirectory
)

Set-Location $rootDirectory

$output = git diff --name-only $sourceBranch $testFileOrDirectory

$changes=$($output.length -gt 0)
if ($changes){
  Write-Host "There has been changes to $testFileOrDirectory compared to $sourceBranch"
  $output
} else {
  Write-Host "There has been NO changes to $testFileOrDirectory compared to $sourceBranch"
}

Write-Host "##vso[task.setvariable variable=changes;isoutput=true]$changes";