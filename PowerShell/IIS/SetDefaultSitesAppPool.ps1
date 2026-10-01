Param(
  [string]$appCodePath
)

Import-Module WebAdministration

##$appCodePath = "C:\inetpub\wwwroot\"
$appVersionFile = "\web.config"
$targets = ''
$iisRoot = 'Default Web Site'
$appPoolSap = "SapDataService"

$apps = Get-WebApplication -Site $iisRoot

foreach($app in $apps)
{

	$appName = $app.Attributes[0].Value -replace "/", "";
	Write-Host "*** Process App $appName STARTING ***"

	$appPoolPath = "IIS:\AppPools\$appName"
	$appSitePath = "IIS:\Sites\Default Web Site\$appName"
	$appPoolClr = ""

	## Check App Pool Type
	$appVersionDirectory = $appCodePath + $appName + $appVersionFile
	if (-not (Get-Content $appVersionDirectory | Select-String "aspNetCore")){
		$appPoolClr = "v4.0"
	}

	Write-Host 'App Pool Name: ' $appName
	Write-Host 'App Pool Path: ' $appPoolPath
	Write-Host 'App Pool CLR: ' $appPoolClr
	Write-Host 'Site Path: ' $appSitePath
	Write-Host ""

	## check if the app pool exists
	if (!(Test-Path $appPoolPath))
	{
		Write-Host "Creating App Pool"
		## create the app pool
		$appPool = New-Item $appPoolPath
		$appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $appPoolClr
		## check if the new app pool is SapDataService
		if ($appName -eq $appPoolSap)
		{
			##Enable 32 bit applications 
			$appPool | Set-ItemProperty -Name "enable32BitAppOnWin64" -Value "true"
			Write-Host "SapDataService App Pool, Enabling 32 Bit application"
		}
		

	} else {
		Write-Host "App Pool Exists"
	}
	
	Write-Host ""
	Write-Host "Setting App Pool"
	## Set AppPool
	Set-ItemProperty $appSitePath -name 'applicationPool' -value $appName
	
	Write-Host "*** Process App $appName ENDING ***"
	Write-Host ""
	Write-Host ""
}

