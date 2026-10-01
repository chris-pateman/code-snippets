$org="cp"
$repo="cp-example"
$branch="master"

$protection=$(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/branches/$branch/protection | ConvertFrom-Json)

$protection.required_status_checks.strict -eq $true
$protection.required_status_checks.checks.length -gt 0
$protection.required_pull_request_reviews.required_approving_review_count.length -gt 0
$protection.enforce_admins.enabled -eq $true