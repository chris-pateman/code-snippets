
# Shared Configuration
$gitLabBaseUrl = "https://gitlab.example.com/api/v4"
$gitLabToken = "********"

function Get-GitLabSubGroups {
    param (
        [string]$GroupId,
        [int]$Page = 0
    )

    $pageLimit = 100
    $url = "$gitLabBaseUrl/groups/$GroupId/subgroups?per_page=$pageLimit&page=$Page"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "Private-Token" = $gitLabToken } -Method Get

    if ($response.Count -eq $pageLimit) {
        $response += Get-GitLabSubGroups -GroupId $GroupId -Page ($Page + 1)
    }

    return $response
}

function New-GitLabSubGroup {
    param (
        [string]$SubGroupName,
        [string]$ParentGroupId,
        [string]$SubGroupPath
    )

    $body = @{
        name      = $SubGroupName
        path      = $SubGroupPath
        parent_id = $ParentGroupId
    }

    $jsonBody = $body | ConvertTo-Json -Depth 3
    $url = "$gitLabBaseUrl/groups"
    $response = Invoke-RestMethod -Uri $url -Method Post -Headers @{ "Private-Token" = $gitLabToken } -Body $jsonBody -ContentType "application/json"

    return $response
}

function Get-GitLabGroupProjects {
    param (
        [string]$GroupId
    )

    $url = "$gitLabBaseUrl/groups/$GroupId/projects"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "Private-Token" = $gitLabToken } -Method Get

    return $response
}

function New-GitLabProject {
    param (
        [string]$ProjectName,
        [string]$ProjectPath,
        [string]$GroupId
    )

    $body = @{
        name         = $ProjectName
        path         = $ProjectPath
        namespace_id = $GroupId
        visibility   = "private"
    }

    $jsonBody = $body | ConvertTo-Json -Depth 3
    $url = "$gitLabBaseUrl/projects"
    $response = Invoke-RestMethod -Uri $url -Headers @{ "Private-Token" = $gitLabToken } -Method Post -Body $jsonBody -ContentType "application/json"

    return $response
}

function New-GitLabProjectMirror {
    param (
        [string]$ProjectId,
        [string]$AdoAccessToken,
        [string]$AdoOrg,
        [string]$AdoProject,
        [string]$AdoRepo
    )

    $mirrorUrl = "https://$AdoAccessToken@dev.azure.com/$AdoOrg/$AdoProject/_git/$AdoRepo"
    $url = "$gitLabBaseUrl/projects/$ProjectId/remote_mirrors"

    $body = @{
        url                     = $mirrorUrl
        enabled                 = $true
        only_protected_branches = $true
        keep_divergent_refs     = $true
    }

    $jsonBody = $body | ConvertTo-Json -Depth 3
    $response = Invoke-RestMethod -Uri $url -Headers @{ "Private-Token" = $gitLabToken } -Method Post -Body $jsonBody -ContentType "application/json"
}

function Get-GitLabSubParent {
    param (
        [string]$RepoName,
        [object]$Project
    )

    switch ($Project.name) {
        "tf-modules" {
            if ($RepoName.StartsWith("tf-az-mod-")) {
                return @{ path = "tf-modules"; name = "Terraform Modules" }
            }
            elseif ($RepoName.StartsWith("tf-az-pattern-")) {
                return @{ path = "tf-patterns"; name = "Terraform Patterns" }
            }
        }
        "devops-tools" {
            if ($RepoName.StartsWith("ado-")) {
                return @{ path = "ado-tools"; name = "Azure DevOps" }
            }
            elseif ($RepoName.StartsWith("github-")) {
                return @{ path = "github-tools"; name = "GitHub Tools" }
            }
        }
        "platform-lz" {
            if ($RepoName.StartsWith("caf-tf-az-")) {
                return @{ path = "platform-caf-lz"; name = "Platform CAF Landing Zone" }
            }
            elseif ($RepoName.StartsWith("tf-az-lz-")) {
                return @{ path = "platform-hubspoke-lz"; name = "Platform Hub and Spoke Landing Zone" }
            }
            <# elseif ($RepoName.StartsWith("engineer-guide")) {
                return @{ path = "engineer-guide-standards"; name = "Engineering Guide" }
            } #>
        }
        "application-lz" {
            if ($RepoName.StartsWith("az-spoke-")) {
                # Remove prefix
                $subName = $subName -replace "^az-spoke-", ""
                # Remove suffix if it ends with -app, -docs, or -infra
                if ($subName -match "-(app|docs|infra)$") {
                    $subName = $subName -replace "-(app|docs|infra)$", ""
                }
                # Remove all hyphens
                $subName = $subName -replace "-", " "
                return @{ path = "app-lz-$subName"; name = "$subName App Landing Zone" }
            }
            <# elseif ($RepoName.StartsWith("engineer-guide")) {
                return @{ path = "engineer-guide-standards"; name = "Engineering Guide" }
            } #>
        }
        Default {
            return $null
        }
    }
}
