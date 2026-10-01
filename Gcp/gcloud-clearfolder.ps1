$parentFolderId = 449043446014
$childFolders = gcloud resource-manager folders list --folder $parentFolderId
Write-Host('Children folders: ');
$childFolders | Format-Table | Out-String|% {Write-Host $_}

foreach ($childFolder in $childFolders){

    Write-Host('Child folder: ');
    $childFolder | Format-Table | Out-String|% {Write-Host $_}

    $childFolderItems = $childFolder.split(' ');
    $childFolderId = $childFolderItems[$childFolderItems.length - 1];
    Write-Host('Child folder ID: ' + $childFolderId);
    
    $childProjects = gcloud projects list --filter "parent.type:folder parent.id:$childFolderId"

    Write-Host('Children Projects: ');
    $childProjects | Format-Table | Out-String|% {Write-Host $_}

    foreach ($childProject in $childProjects){

        Write-Host('Child Project: ');
        $childProject | Format-Table | Out-String|% {Write-Host $_}
    
        $childProjectItems = $childProject.split(' ');
        $childProjectId = $childProjectItems[$childProjectItems.length - 1];
        Write-Host('Child Project ID: ' + $childProjectId);

        gcloud projects delete $childProjectId --quiet
    }

    gcloud resource-manager folders delete $childFolderId --quiet
}