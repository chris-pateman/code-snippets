# Parameters
$githubToken = "*******"
$repoOwner = "cp-technology"
$repoName = "platform"
$sourceSubscriptionId = "0000-0000-0000-0000"
$runnerRepositoryname = "plat-ghr-001";

# Set Azure subscription
az account set --subscription $sourceSubscriptionId

# Get GitHub runners
$headers = @{ Authorization = "Bearer $githubToken" }
$runnersResponse = Invoke-RestMethod -Uri "https://api.github.com/repos/$repoOwner/$repoName/actions/runners" -Headers $headers

# Extract runner names
$runners = $runnersResponse.runners | Where-Object { $_.status -eq "offline" } | Select-Object -ExpandProperty name

# Start matching Azure VMs
foreach ($runner in $runners) {
    Write-Host "Attempting to start VM for runner: $runner"
    try {
        az vm start -g $runnerRepositoryname  --name $runner --no-wait
        Write-Host "Started VM: $runner"
    }
    catch {
        Write-Warning "Failed to start VM: $runner"
    }
}
