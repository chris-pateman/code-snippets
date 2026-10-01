
$username = "cp-wowza-dev-1"
$roles = @("db_datareader")

$sql_fqdn = "cp-infra-core-dev.database.windows.net"
$database_names = "vhbookings"

$token = $(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv)

if (-not $(Get-Module SqlServer -ListAvailable)) { 
    Write-Host "Not got sqlServer Installed" 
    Write-Host "Installing now"
    Install-Module -Name SqlServer -Scope CurrentUser -Force
}

foreach ($database_name in $database_names) {

    Write-Host "Grant $username access to $database_name in $sql_fqdn"
    Write-Host "with roles $($roles | ConvertTo-Json)"

    $query = "IF NOT EXISTS (
    SELECT  [name]
    FROM    sys.database_principals
    WHERE   [name] = '$username'
)
BEGIN
    create user [$username] from external provider;
END;"

    foreach ($role in $roles) {
        $query += "alter role $role add member [$username];"
    }

    Invoke-SqlCmd -ServerInstance $sql_fqdn -Database $database_name -Query $query -AccessToken $token 

}