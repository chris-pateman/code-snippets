# Fetch and prune remote-tracking branches
git fetch -p

# Get local branches that are not in the remote
$localBranches = git branch | ForEach-Object { $_.Trim() }
$remoteBranches = git branch -r | ForEach-Object { $_.Trim() -replace 'origin/', '' }

# Find branches that are local but not remote
$branchesToDelete = $localBranches | Where-Object { $remoteBranches -notcontains $_ }

# Delete the branches
$branchesToDelete | ForEach-Object { git branch -D $_ }
