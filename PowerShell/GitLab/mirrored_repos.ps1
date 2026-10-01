# Define variables
$GitLabToken = "******"
$RootGroupId = "9999"
$GitLabApiUrl = "https://gitlab.example.com/api/v4"
$PageLimit = 100
$OutputPath = ".\code-repos\personal\snippets\PowerShell\GitLab/output/$RootGroupId.json"

# Set headers for the API request
$Headers = @{
    "Private-Token" = $GitLabToken
}

function Get-GitLabSubGroups {
    param (
        [string]$GroupID,
        [int]$Page = 0
    )
    Write-host "Get SubGroups for $GroupID"
    $url = "$GitLabApiUrl/groups/$GroupID/subgroups?per_page=$PageLimit&page=$Page"
    Write-Host "Sub Groups URL: $url"
    $response = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get
    if ($reponse.Count -eq $PageLimit) {
        $newPage = ($Page + 1)
        Write-host "More than $PageLimit going to page $newPage"
        $response += Get-GitLabSubGroups -GroupID $GroupID -Page $newPage
    }
    return $response
}

function Get-GitLabProjects {
    param (
        [string]$GroupID,
        [int]$Page = 0
    )
    Write-host "Get Projects for $GroupID"
    $url = "$GitLabApiUrl/groups/$GroupID/projects?per_page=$PageLimit&page=$Page"
    Write-Host "Project List URL: $url"
    $response = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get
    if ($reponse.Count -eq $PageLimit) {
        $newPage = ($Page + 1)
        Write-host "More than $PageLimit going to page $newPage"
        $response += Get-GitLabProjects -GroupID $GroupID -Page $newPage
    }
    return $response
}

function Get-GroupProjects {
    param (
        [string]$GroupID
    )

    $projects = @()
    $groupProjects = Get-GitLabProjects -GroupID $GroupID
    Write-host "$($group.name) has $($groupProjects.count) projects"
    $projects += $groupProjects
    Write-host "--"
    $subgroups = Get-GitLabSubGroups -GroupID $GroupID
    if ($subgroups.count -gt 0) {
        foreach ($subgroup in $subgroups) {
            $subgroupProjects = Get-GroupProjects -GroupID $subgroup.Id
            Write-host "$($subgroup.name) has $($subgroupProjects.count) projects"
            $projects += $groupProjects
            Write-host "--"
        }
    }
    return $projects
}
function Get-ProjectMirrorStatus {
    param (
        [string]$projectId
    )
    $url = "$GitLabApiUrl/projects/$projectId/mirror/pull"
    Write-Host "URL: $url"
    $response = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get
    return $response
}

# Get repositories and their mirroring status
$groups = Get-GitLabSubGroups -GroupID $RootGroupId
$projects = @()
foreach ($group in $groups) {
    $groupProjects = Get-GroupProjects -GroupID $group.Id
    Write-host "Root $($group.name) has $($groupProjects.count) projects"
    $projects += $groupProjects
    Write-host "--"
    
}

$mirrored = 0
$notMirrored = 0
$mirroredCompleted = 0
$mirroredNotCompleted = 0
$projects_report = @()
foreach ($project in $projects) {
    $repoName = $project.name
    Write-Host ""
    Write-Host "Repository: $repoName, Mirroring Status: "
    if ($project.mirror) { 
        $mirrored++
        $mirrorStatus = Get-ProjectMirrorStatus -projectId $project.id
        Write-Host "Mirrored" #-BackgroundColor Green
        Write-Host "Status: $($mirrorStatus.update_status)"
        if ($mirrorStatus.update_status -eq "finished"){
            $mirroredCompleted++
        } else {
            $mirroredNotCompleted++
        }
    }
    else { 
        $notMirrored++
        $mirrorStatus = @{}
        Write-Host "Not Mirrored" #-BackgroundColor Red
    }
    $projects_report += @{
        name = $project.name
        id = $project.id
        mirrored = $project.mirror
        mirrorStatus = $mirrorStatus
        adoUrl = $project.import_url
        gitLabUrl = $project.web_url
        gitlabPath = $project.path_with_namespace
    }
}

Set-Content -Path $OutputPath -Value $($projects_report | ConvertTo-Json -Depth 100)

Write-Host ""
Write-Host "Summary"
Write-Host "mirrored: $mirrored"
Write-Host "notMirrored: $notMirrored"
Write-Host "mirroredCompleted: $mirroredCompleted"
Write-Host "mirroredNotCompleted: $mirroredNotCompleted"
