$org="cp"
$repo = "cp-shared-infrastructures"

$path="infrastructure\.terraform-version"
$files=$(gh api -H "Accept: application/vnd.github+json" /repos/$org/$repo/contents/$path | ConvertFrom-Json) 



## Check TF Files
$tfFiles= $files | Where-Object {$_.name -like "*.tf"}
$stringSearch="*azurerm_key_vault_secret*"
foreach ($tfFile in $tfFiles){

  $myfile=$(gh api -H "Accept: application/vnd.github+json"  /repos/$org/$repo/contents/$($tfFile.path) | ConvertFrom-Json) 
  $content=$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($myfile.content)))

  if ($content -like $stringSearch){
    Write-Host "$repo contains $stringSearch in $($tfFile.path)"
    #break;
  }
}

#-H "Content-Type: application/vnd.github.VERSION.raw"