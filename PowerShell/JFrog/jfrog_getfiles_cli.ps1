
$path = "docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019"


$jfUser = "99999"
$jfPassword = "******"

$paths = @("docker-sitecore-local/sitecore-xp1-cd-10.1.2-ltsc2019")
$includeFolders = $true
$jfUrl = "binarycentral.jfrog.io"


foreach ($path in $paths ) {
    
    Write-host "Path: $path"
    $jf_files = @()
    if ($includeFolders){
        $jf_files = $(jf rt s --include-dirs --recursive=$false "$path/" | ConvertFrom-Json)
    } else {
        $jf_files = $(jf rt s --recursive=$false "$path/" | ConvertFrom-Json)
    }


    $outputJson = $jf_files | ConvertTo-Json -Compress -Depth 100

}
#--fail-no-op
#--dry-run