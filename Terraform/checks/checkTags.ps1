param (
    $requiredTags,
    $tags
) 

$requiredTags = $requiredTags.split(',')

$tags = $tags | ConvertFrom-Json
$missingTags = @()

foreach ($key in $requiredTags) {
    if ($tags.PSObject.Properties.Name -notcontains $key) {
        $missingTags += $key
    }
}

if ($missingTags.Count -gt 0) {
    $string = $missingTags -join ", "
    write-host "{""check"": ""FAIL"", ""missing_tags"": ""$string""}"
}
else {
    write-host "{""check"": ""OK"", ""missing_tags"": """"}"
}