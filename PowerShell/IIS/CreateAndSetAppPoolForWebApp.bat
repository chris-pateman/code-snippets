set AppName=%1
set AppPool=%2

set SiteName=Default Web Site
set ClrVersion="No Managed Code"
set FullSiteName="%SiteName%/%AppName%"

:: Go to Appcmd
cd %systemroot%/system32/inetsrv/

:: Create App Pool or ignore error if already created
appcmd add apppool /name:%AppPool% /managedRuntimeVersion: /managedPipelineMode:"Integrated"

:: Set apps app pool
appcmd set app /app.name:%FullSiteName% /applicationPool:%AppPool%