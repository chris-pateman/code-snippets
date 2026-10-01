Param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Manual', 'Automatic', 'AutomaticDelayedStart', 'Disabled', 'InvalidValue')]
    [string]$startupType = "Manual",
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$serviceName = "",
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$serviceDisplayName = "",
    [string]$serviceDescription = "",
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$serviceExecutablePath = "",
    [string]$serviceUserName = "",
    [string]$servicePassword = "",
    [string]$startServiceAfter = $true
)

if ($serviceName -eq "")
{
    Write-Host("Service Name is empty $serviceName")
    exit 1
}

# verify if the service already exists, and if yes remove it first
if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    Write-Host("service already installed, stopping...")
    # using WMI to remove Windows service because PowerShell does not have CmdLet for this
    $serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
    $serviceToRemove | Stop-Service
    $serviceToRemove.delete()
    Write-Host("service removed")
}
else {
    # just do nothing
    Write-Host("service does not exist")
}

Write-Host("installing service $serviceName")

# creating credentials which can be used to run my windows service
$Credentials = $null
if ($serviceUserName -ne "" -and $servicePassword -ne "") {
    $secpasswd = ConvertTo-SecureString $servicePassword -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential ($servicePassword, $secpasswd)
}

# detect current execution directory
#$directoryPath = Split-Path $MyInvocation.MyCommand.Path
#$binaryPath = $directoryPath + "\" + $serviceExecutablePath

# creating widnows service using all provided parameters
$params = @{
    Name           = $serviceName
    BinaryPathName = $serviceExecutablePath
    DependsOn      = ""
    DisplayName    = $serviceDisplayName
    StartupType    = $startupType
    Description    = $serviceDescription
    Credential     = $Credentials
}
New-Service @params

if ($startServiceAfter -eq $true) {
    Start-Service -Name $serviceName
}

Get-Service $serviceName

Write-Host("installation completed")