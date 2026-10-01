git fetch -p ; 

$localBranches = git branch | ForEach-Object { 
  $_.Trim() -replace "\* ",""
}

$remoteBranches = git branch -r | Where-Object { 
  $_ -match 'origin' 
}| ForEach-Object { 
  $_.Trim() -replace "origin/",""
}

$compareResults = Compare-Object $remoteBranches $localBranches

$compareResults | Where-Object {$_.SideIndicator -eq "=>" } | ForEach-Object {
  $branchName = $_.InputObject
  Write-host "Delete $branchName"
  git branch -D $branchName
}
