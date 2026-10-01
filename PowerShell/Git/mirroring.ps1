
$repos = @(
    @{
        name = "tf-az-mod-log-analytics"
        gitlab = "https://gitlab.pateman.com/shared/azure/terraform-modules/logging/tf-az-mod-log-analytics.git"
        ado = "https://patemanukdcs@dev.azure.com/patemanukdcs/Azure%20Capability%20Landing%20Zones/_git/tf-az-mod-log-analytics"
    }
)

$gitlab_base_path = ".\code-repos\pateman\gitlab-az-lz"
$ado_base_path = ".\code-repos\pateman\az-lz"

foreach ($repo in $repos) {
    Write-Host "Checkout GitLab Repo $($repo.name) ($($repo.gitlab))"
    set-location $gitlab_base_path

    git clone $repo.gitlab

    Write-Host "Checkout ADO Repo $($repo.name) ($($repo.gitlab))"
    set-location $ado_base_path

    git clone $repo.ado

    Write-Host "Setup Mirroring"
    Set-Location "./$($repo.name)"

    git push --force --mirror $repo.gitlab
}