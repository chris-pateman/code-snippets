
$connection_string = "Server=localhost;Initial Catalog=master;User ID=sa;Password"

$root_path = "$PsScriptRoot"

function Invoke-FolderSql($parent_path){
    $sql_path = "$root_path/$parent_path"
    Write-Host "Implementing $parent_path"
    Invoke-SubFolderSql -sub_path "setup" -parent_path $sql_path
    Invoke-SubFolderSql -sub_path "inject" -parent_path $sql_path
    Invoke-SubFolderSql -sub_path "post" -parent_path $sql_path
    Write-Host ""
}
function Invoke-SubFolderSql($sub_path, $parent_path){
    Write-Host "Apply '$sub_path' for $parent_path"
    Get-ChildItem -Path "$parent_path/$sub_path" -Filter "*.sql" | ForEach-Object {
        Write-Host "Run $($_.FullName)"
        #Invoke-Sqlcmd -InputFile $_.FullName -ConnectionString $connection_string
    }
}

Invoke-FolderSql -parent_path "auditing"

Get-ChildItem -Path "$root_path/customers" -Directory | ForEach-Object {
    Invoke-FolderSql -parent_path "customers/$($_.Name)"
}