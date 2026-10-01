# Define GitLab API details
$GitLabApiUrl = "https://gitlab.example.com/api/v4"
$GroupId = "5317"  # Replace with your GitLab group ID or path
$AccessToken = "********"  # Replace with your GitLab personal access token

# Set headers for authentication
$Headers = @{
    "Private-Token" = $AccessToken
}


# Pagination setup
$PerPage = 100
$Page = 1
$AllProjects = @()

do {
    $ProjectsUrl = "$GitLabApiUrl/groups/$GroupId/projects?per_page=$PerPage&page=$Page"
    $Response = Invoke-RestMethod -Uri $ProjectsUrl -Headers $Headers -Method Get

    if ($Response.Count -gt 0) {
        $AllProjects += $Response
        $Page++
    } else {
        break
    }
} while ($true)

Write-Host "Total projects found: $($AllProjects.Count)"


# Loop through and delete each project
foreach ($Project in $AllProjects) {
    $ProjectId = $Project.id
    $ProjectName = $Project.name
    $DeleteUrl = "$GitLabApiUrl/projects/$ProjectId"

    try {
        Invoke-RestMethod -Uri $DeleteUrl -Headers $Headers -Method Delete
        Write-Host "Deleted project: $ProjectName (ID: $ProjectId)"
    } catch {
        Write-Host "Failed to delete project: $ProjectName (ID: $ProjectId) - $_"
    }
}
