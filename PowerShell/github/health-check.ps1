$org = "cp"
$repos=@(
  "ia-case-api",
  "ia-case-documents-api"
  )

$exportToFile = $true
$exportOnlyFailures = $true
$exportName = "health-check-$((get-date).ToString("yyyy-MM-dd")).csv"
if ($exportToFile) {
  Set-Content -Path "./$exportName" -Value "Date, Repository, Result, Message `n"
}

## PR Config
$updatedDate = (get-date).AddDays(-10).ToString("yyyy-MM-dd")
$maxOpen = 10
$prefix = "IA"

foreach ($repo in $repos){

$repoWithOwner = "$org/$repo"

function addRow($result, $message) {
  
  $currentContent = Get-Content -Path "./$exportName"
  $currentContent += "$((get-date).ToString("dd/MM/yyyy")), $repo, $result, $message `n"
  Set-Content -Path "./$exportName" -Value $currentContent
  
}

function printResult($successMsg, $condition, $failureMsg = "", $softFailure = $false, [scriptblock]$callback = {}) {
  if ($condition) {
    $messageColor = "Green"
    $messageResult = "Success"
    $message = $successMsg
  }
  else {
    $messageColor = "Red"
    if ($softFailure) {
      $messageColor = "Orange"
    }
    $message = $failureMsg
    if ($failureMsg -eq "") {
      $message = $successMsg
    }
    $messageResult = "Failed"
  }
  
  Write-Host "$messageResult`: $message" -ForegroundColor $messageColor

  if ($exportToFile) {
    if (($exportOnlyFailures -and $messageResult -eq "Failed") -or !$exportOnlyFailures) {
      addRow -result $messageResult -message $message
    }
  }

  $callback.Invoke()
}


Write-Host "### Pull Request Checks ###"
### Stale PRs
$prs = $(gh pr list --search "type:pr updated:<$updatedDate" --state "open" -R $repoWithOwner --json "number,title,author,state,updatedAt") | ConvertFrom-Json
printResult -successMsg "There are No Stale PRs" -failureMsg "There are $($prs.length) Stale PRs" -condition $($prs.length -lt 1) -callback { $prs | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize number, title, author, state, updatedAt }

### Open PRs
$prs = $(gh pr list --search "type:pr" --state "open" -R $repoWithOwner --json "number,title,author,state,updatedAt") | ConvertFrom-Json
printResult -successMsg "Open PRs are below $maxOpen" -failureMsg "There are $($prs.length) Open PRs more then the maximum of $maxOpen" -condition ($prs.length -lt $maxOpen)

### PR Titles
$titleRegex = "^($prefix-[0-9]{3,4} [a-zA-Z0-9._\- ]+)|(\[Snyk\].+)$"
$titleFilteredPrs = $($prs | Where-Object { $_.title -notmatch $titleRegex })
printResult -successMsg "PR title match format $titleRegex" -failureMsg "There are $($titleFilteredPrs.length) PRs title not matching the format $titleRegex" -condition ($titleFilteredPrs.length -lt 1) -callback { $titleFilteredPrs | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize number, title, author, state, updatedAt }

Write-Host "### Repo Content ###"
### Workflow ###
$path = ".github"
$files = $(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/contents/$path | ConvertFrom-Json)
$filesToCheck = @("stale.yml", "renovate.json", "dependabot.yml", "PULL_REQUEST_TEMPLATE.md", "ISSUE_TEMPLATE.md", "CONTRIBUTING.md")
foreach ($fileName in $filesToCheck) {
  $contains = $($files | Where-Object { $_.type -eq "file" -and $_.name -eq $fileName })
  printResult -successMsg "Path $path does contain $fileName" -failureMsg "Path $path does not contain $fileName" -condition ($null -ne $contains -and $contains -ne "" )
}
### Base ###
$path = ""
$files = $(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/contents/$path | ConvertFrom-Json)
$filesToCheck = @("Jenkinsfile_CNP", "Jenkinsfile_parameterized", "LICENSE", "README.md", ".gitignore")
foreach ($fileName in $filesToCheck) {
  $contains = $($files | Where-Object { $_.type -eq "file" -and $_.name -eq $fileName })
  printResult -successMsg "Path $path does contain $fileName" -failureMsg "Path $path does not contain $fileName" -condition ($null -ne $contains -and $contains -ne "" )
}

Write-Host "### Security Protection ###"
### Branch Protection ###
$branch = "master"
$protection = $(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/branches/$branch/protection | ConvertFrom-Json)

printResult -successMsg "Require Checks is $($protection.required_status_checks.strict)" -condition ($protection.required_status_checks.strict -eq $true)
printResult -successMsg "There is $($protection.required_status_checks.checks.length) required checks" -condition ($protection.required_status_checks.checks.length -gt 0)
printResult -successMsg "Require $($protection.required_pull_request_reviews.required_approving_review_count.length) Reviewers required" -condition ($protection.required_pull_request_reviews.required_approving_review_count.length -gt 0)
printResult -successMsg "Enforce for Admin is Enabled" -failureMsg "Enforce for Admin is Disabled" -condition ($protection.enforce_admins.enabled -eq $true)

### Access ###
$teamAccess = $(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/teams | ConvertFrom-Json)

$maxAdmin = 2
$adminAccess = $teamAccess | Where-Object { $_.permission -eq "admin" }
printResult -successMsg "Only $($adminAccess.length) have Admin Access" -failureMsg "$($adminAccess.length) have Admin Access, please reduce below $maxAdmin" -condition ($adminAccess.length -lt $maxAdmin)

$collaborators = $(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/collaborators?affiliation=direct  | ConvertFrom-Json)
printResult -successMsg "No direct access" -failureMsg "No one should have direct access. $($collaborators.length) do" -condition ($collaborators.length -lt 1) -callback { $collaborators | ForEach-Object { [PSCustomObject]$_ } | Format-Table -AutoSize login, type, role_name }

}