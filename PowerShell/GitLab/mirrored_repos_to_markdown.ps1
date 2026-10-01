# Define variables
$tfModuleReport = ".\code-repos\personal\snippets\PowerShell\GitLab/output/3863.json"
$lzReport = ".\code-repos\personal\snippets\PowerShell\GitLab/output/3868.json"
$OutputPath = ".\code-repos\personal\snippets\PowerShell\GitLab/output/report.md"


Set-Content -Path $OutputPath -Value ""

Add-Content -Path $OutputPath -Value "# GitLab Repositories and Mirroring"
Add-Content -Path $OutputPath -Value ""
Add-Content -Path $OutputPath -Value "These are the GitLab Repositories that are mirrored from Azure DevOps."
Add-Content -Path $OutputPath -Value ""

## Terraform Modules
$report = Get-Content -Path $lzReport -Raw | ConvertFrom-Json
Add-Content -Path $OutputPath -Value "## Landing Zones"
Add-Content -Path $OutputPath -Value ""
Add-Content -Path $OutputPath -Value "|ID|Name|GitLab Link | Mirrored? | Azure DevOps Link | Mirror Status | Mirror Comment |"
Add-Content -Path $OutputPath -Value "|--|--|--|--|--|--|--|"

foreach ($item in $report) {
    
    $outputStr = "|$($item.id)|$($item.name)|[$($item.gitlabPath)]($($item.gitlabUrl))|$($item.mirrored)|"
    if ([bool]$item.mirrored -eq $true) {
        $outputStr += "[$($item.name)]($($item.adoUrl))|$($item.mirrorStatus.update_status)|$($item.mirrorStatus.last_update_at) : $($item.mirrorStatus.last_error)|"
    }
    else {
        $outputStr += "N/A|N/A|N/A|"
    }
    Add-Content -Path $OutputPath -Value $outputStr
}


## Terraform Modules
$report = Get-Content -Path $tfModuleReport -Raw | ConvertFrom-Json
Add-Content -Path $OutputPath -Value "## Terraform Modules"
Add-Content -Path $OutputPath -Value ""
Add-Content -Path $OutputPath -Value "|ID|Name|GitLab Link | Mirrored? | Azure DevOps Link | Mirror Status | Mirror Comment |"
Add-Content -Path $OutputPath -Value "|--|--|--|--|--|--|--|"

foreach ($item in $report) {
    
    $outputStr = "|$($item.id)|$($item.name)|[$($item.gitlabPath)]($($item.gitlabUrl))|$($item.mirrored)|"
    if ([bool]$item.mirrored -eq $true) {
        $outputStr += "[$($item.name)]($($item.adoUrl))|$($item.mirrorStatus.update_status)|$($item.mirrorStatus.last_update_at) : $($item.mirrorStatus.last_error)|"
    }
    else {
        $outputStr += "N/A|N/A|N/A|"
    }
    Add-Content -Path $OutputPath -Value $outputStr
}
