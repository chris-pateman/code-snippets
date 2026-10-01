
$repoName = "example-models"
$organisation = "cpbuild"
$projectName = "Collaborative"
$nuspecPath="automation\package\Automation.nuspec"

mkdir $repoName
Set-Location $repoName
git init
git remote add origin "https://$organisation@dev.azure.com/$organisation/$projectName/_git/$repoName"

git config core.sparseCheckout true
Set-Content -Path ".git/info/sparse-checkout" -Value $nuspecPath

git pull --depth=1 origin develop
