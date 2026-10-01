# Import updated modules
Remove-Module GitLabFunctions, AzureDevOpsFunctions -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/GitLabFunctions.psm1" -Force
Import-Module "$PSScriptRoot/AzureDevOpsFunctions.psm1" -Force

$InformationPreference = "Continue"

# Configuration
$adoOrganisation = "pateman"
$adoAccessToken = $accessToken

$projects = @(
    @{
        name         = "platform-lz"
        adoName      = "Azure Landing Zones"
        gitlabParent = @{
            name = "platform-landing-zones"
            id   = "4985"
        }
    }
)

# Fetch ADO projects
$adoProjects = Get-AdoProjects -OrgName $adoOrganisation

foreach ($project in $projects) {
    $adoProject = $adoProjects | Where-Object { $_.name -eq $project.adoName }

    if ($null -eq $adoProject -or $adoProject.name -eq "") {
        Write-Warning "Project $($project.adoName) not found"
        continue
    }

    $adoRepositories = Get-AdoRepositories -OrgName $adoOrganisation -ProjectName $adoProject.name
    $gitlabSubGroups = Get-GitLabSubGroups -GroupId $project.gitlabParent.id

    $gitlabProjects = @()

    foreach ($adoRepository in $adoRepositories) {
        $gitlabSubParent = Get-GitLabSubParent -RepoName $adoRepository.name -Project $project

        $gitlabSubParentDetails = if ($null -eq $gitlabSubParent) {
            Write-Information "No GitLab Sub Parent"
            $project.gitlabParent
        }
        elseif ($gitlabSubGroups.name -contains $gitlabSubParent.name) {
            Write-Information "$($gitlabSubParent.name) GitLab Sub Parent Exists"
            $gitlabSubGroups | Where-Object { $_.name -eq $gitlabSubParent.name }
        }
        else {
            Write-Information "Creating $($gitlabSubParent.name) GitLab Sub Parent"
            #$newSubGroup = New-GitLabSubGroup -SubGroupName $gitlabSubParent.name -SubGroupPath $gitlabSubParent.path -ParentGroupId $project.gitlabParent.id
            $gitlabSubGroups += $newSubGroup
            $newSubGroup
        }

        if ($gitlabProjects.Count -lt 1 -or $gitlabProjects.group_name -notcontains $gitlabSubParentDetails.name) {
            $gitlabProjects += @{
                group_name = $gitlabSubParentDetails.name
                group_id   = $gitlabSubParentDetails.id
                projects   = Get-GitLabGroupProjects -GroupId $gitlabSubParentDetails.id
            }
        }

        $gitlabProjectsThisScope = $gitlabProjects | Where-Object { $_.group_name -eq $gitlabSubParentDetails.name }

        <# if ($gitlabProjectsThisScope.projects.name -notcontains $adoRepository.name) {
            $projectCreated = New-GitLabProject -ProjectName $adoRepository.name -ProjectPath $adoRepository.name -GroupId $gitlabProjectsThisScope.group_id
            New-GitLabProjectMirror -ProjectId $projectCreated.id -AdoAccessToken $adoAccessToken -AdoOrg $adoOrganisation -AdoProject $adoProject.name -AdoRepo $adoRepository.name
        } #>
    }
}
