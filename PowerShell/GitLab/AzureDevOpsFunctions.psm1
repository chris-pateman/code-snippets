# Shared Configuration
$adoBaseUrl = "https://dev.azure.com"

# Acquire access token if not already available or expired
if ($null -eq $adoAccessToken -or $adoAccessToken -eq "" -or $null -eq $access -or (Get-Date $access.expiresOn) -lt (Get-Date)) {
    $access = az account get-access-token -o json | ConvertFrom-Json
    $adoAccessToken = $access.accessToken
}

$adoToken = $adoAccessToken

function Get-AdoProjects {
    param (
        [string]$OrgName
    )

    # Construct API URL for listing projects
    $url = "$adoBaseUrl/$OrgName/_apis/projects?api-version=7.1-preview.4"
    Write-Information "Requesting: $url"

    $response = Invoke-WebRequest -Uri $url -Headers @{ "Authorization" = "Bearer $adoToken" }

    if ($response.StatusCode -ne 200) {
        Write-Information "##[error]API Response Error"
        # throw $response.Content
    }

    return ($response.Content | ConvertFrom-Json).value
}

function Get-AdoRepositories {
    param (
        [string]$OrgName,
        [string]$ProjectName
    )

    # Construct API URL for listing repositories
    $url = "$adoBaseUrl/$OrgName/$ProjectName/_apis/git/repositories?api-version=7.1-preview.1"
    Write-Information "Requesting: $url"

    $response = Invoke-WebRequest -Uri $url -Headers @{ "Authorization" = "Bearer $adoToken" }

    if ($response.StatusCode -ne 200) {
        Write-Information "##[error]API Response Error"
        throw $response.Content
    }

    return ($response.Content | ConvertFrom-Json).value
}
