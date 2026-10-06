[CmdletBinding()]
param(
    [string]$PoliciesDirectory, 
    [string]$OutputDirectory 
)

if (-not (Test-Path -LiteralPath $PoliciesDirectory -PathType Container)) {
    throw "Policy directory not found: $PoliciesDirectory"
}

$policyPaths = @(Get-ChildItem -LiteralPath $PoliciesDirectory -File | Sort-Object -Property FullName | ForEach-Object {
    Write-Host "Adding path $($_.FullName)" -ForegroundColor Green
    $_.FullName
})

if ($policyPaths.Count -eq 0) {
    throw "No policy files found in: $PoliciesDirectory"
}

if (-not (Get-Command policylinter -ErrorAction SilentlyContinue)) {
    throw "policylinter was not found on PATH. Install it or add it to PATH before running this script."
}

if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
}

$resultPath = Join-Path -Path $OutputDirectory -ChildPath "results.json"
& policylinter @policyPaths --output $resultPath

if ($LASTEXITCODE -ne 0) {
    throw "policylinter failed with exit code $LASTEXITCODE."
}