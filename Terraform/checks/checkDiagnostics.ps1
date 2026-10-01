param (
    $resource_id,
    $workspace_id
)

$name = ($resource_id -split ("/"))[-1]
$diagSettings = az monitor diagnostic-settings list --resource $resource_id | ConvertFrom-Json
foreach ($diagSetting in $diagSettings) {
    if ($($diagSetting.name).StartsWith($name)) {
        Write-Host "{""exists"": ""OK"", ""law"": ""$($diagSetting.workspaceId)"", ""logAnalyticsDestinationType"": ""$($diagSetting.logAnalyticsDestinationType)""}"
        exit
    }
}

Write-Host "{""exists"": ""FAIL"", ""law"": """", ""logAnalyticsDestinationType"": """"}"
