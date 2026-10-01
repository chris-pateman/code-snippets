$org="cp"
$repo="cp-example"


$collaborators=$(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/collaborators?affiliation=direct  | ConvertFrom-Json)

foreach ($collaborator in $collaborators){
  Write-Host "$($collaborator.login) - $($collaborator.id) - $($collaborator.type) - $($collaborator.role_name)"
}