
Import-Module WebAdministration

<#
.SYNOPSIS
 This function creates an application pool

.PARAMETER appPoolName
Application Pool Name
.PARAMETER appPoolRuntime
Application Pool Management Runtime

.EXAMPLE
AppPoolName
#>
Function CreateAppPool {
    Param([string] $appPoolName,
    [string] $appPoolRuntime)
 
    ## If App Pool doesn't exist then create it
    $testPath = Test-Path ("IIS:\AppPools\" + $appPoolName);
    if ($testPath -eq $false) {
        New-WebAppPool -Name $appPoolName
    }
 
    ## Set run time
    Set-ItemProperty IIS:\AppPools\$appPoolName -Name managedRuntimeVersion -Value $appPoolRuntime
    Set-ItemProperty IIS:\AppPools\$appPoolName -Name "processModel.loadUserProfile" -Value "True"
}

## Params
$websiteName = "$(IIS-SiteName)"
$websitePath = "IIS:\Sites\$websiteName"
$Websites = Get-ChildItem $websitePath

## Loop Vitual Apps in Site
foreach ($webApp in $Websites) {
    
    $siteName = $webApp.Name
    $sitePath = "$websitePath\$siteName"
    $appPoolName = "GDAPI-$siteName"
    write-Host("Creating/Updating Pool for site $siteName")

    CreateAppPool -appPoolName $siteName -appPoolRuntime ""
    Set-ItemProperty -path $sitePath -name applicationPool -value $siteName -Force
}