[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", '',Justification='string is secured from Terraform')]
param (
    [Parameter(Mandatory = $true)]
    [string]$ApplicationId,

    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,

    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$GatewayName,

    [Parameter(Mandatory = $true)]
    [string]$RecoveryKey,

    [Parameter(Mandatory = $true)]
    [string]$AdminAccountObjectId
)

$InformationPreference = "Continue"
$LogFile = "PowerBIGatewaySetup.log"
function Write-LogTrace {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $LogFile -Value $logEntry
    Write-Information $Message -InformationAction Continue
}

Write-LogTrace "🔄 Starting Power BI Gateway setup..."

# Convert sensitive strings to secure strings
$SecureClientSecret = $ClientSecret | ConvertTo-SecureString -AsPlainText -Force
$SecureRecoveryKey = $RecoveryKey | ConvertTo-SecureString -AsPlainText -Force

# Install and import DataGateway module if not present
try {
    if (-not (Get-Module -ListAvailable -Name DataGateway)) {

        $nugetProvider = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
        if ($nugetProvider -and $nugetProvider.Version -ge [Version]"2.8.5.201") {
            Write-LogTrace  "✅ NuGet provider version $($nugetProvider.Version) is already installed."
        }
        else {
            Write-LogTrace  "📦 Installing NuGet provider version 2.8.5.201 or higher..."
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        }

        Write-LogTrace "📦 Installing DataGateway module..."
        Install-Module -Name DataGateway -Force
    }
    Import-Module DataGateway
    Write-LogTrace "✅ DataGateway module loaded."
}
catch {
    Write-LogTrace "❌ Failed to install or import DataGateway module: $_"
    exit 1
}

# Authenticate using service principal
try {
    Write-LogTrace "🔐 Authenticating with service principal..."
    Connect-DataGatewayServiceAccount -ApplicationId $ApplicationId -ClientSecret $SecureClientSecret -Tenant $TenantId
    Write-LogTrace "✅ Authentication successful."
}
catch {
    Write-LogTrace "❌ Authentication failed: $_"
    exit 1
}

# Install the gateway silently
try {
    Write-LogTrace "📥 Installing Power BI Gateway..."
    Install-DataGateway -AcceptConditions
    Write-LogTrace "✅ Gateway installation completed."
}
catch {
    Write-LogTrace "❌ Gateway installation failed: $_"
    exit 1
}

# Create a new gateway cluster
try {
    Write-LogTrace "🛠️ Creating gateway cluster '$GatewayName'..."
    $gatewayDetails = Add-DataGatewayCluster -Name $GatewayName -RecoveryKey $SecureRecoveryKey
    Write-LogTrace "✅ Gateway cluster created with ID: $($gatewayDetails.GatewayObjectId)"
}
catch {
    Write-LogTrace "❌ Failed to create gateway cluster: $_"
    exit 1
}

# Add an admin to the gateway cluster
try {
    Write-LogTrace "👤 Adding admin user to gateway cluster..."
    Add-DataGatewayClusterUser -GatewayClusterId $gatewayDetails.GatewayObjectId `
        -PrincipalObjectId $AdminAccountObjectId `
        -Role Admin `
        -AllowedDataSourceTypes $null
    Write-LogTrace "✅ Admin user added successfully."
}
catch {
    Write-LogTrace "❌ Failed to add admin user: $_"
    exit 1
}

Write-LogTrace "🎉 Power BI Gateway installed and configured successfully."
exit 0
