$policies_dir = "./\pateman.workspace\code-repos\version1\sandbox\sandbox-central-resources\infra\modules\policies\policies"
$output_path = "./\pateman.workspace\test-shit"

$policy_paths = @(Get-ChildItem -Path $policies_dir -File | ForEach-Object {
    Write-Host "Adding path $($_.FullName)" -ForegroundColor Green
    $_.FullName
})

policylinter @policy_paths --output "$output_path/results.json"