param (
  #AD or MI name
  [Parameter(Mandatory = $true)]
  [string]$username,
  #CSV of roles to apply
  [Parameter(Mandatory = $true)]
  [string]$roles_csv,
  #Azure Server Name
  [Parameter(Mandatory = $true)]
  [string]$sqlServerName,
  #Azure Database
  [Parameter(Mandatory = $true)]
  [string]$databaseName
)
$username="adf-dev-uks-01";
$roles_csv="db_datareader,db_datawriter";
$sqlServerName="azsql-dev-uks-001";
$databaseName="IngestionControlMetadata";


$roles = $roles_csv.split(",");
$sql_fqdn = "$($sqlServerName).database.windows.net";

$token = $(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv);

Write-Host "Installing SqlServer now";
Install-Module -Name SqlServer -Scope CurrentUser -Force;

Write-Host "Grant $username access to $databaseName in $sql_fqdn";
Write-Host "with roles: $roles";

$query = "IF NOT EXISTS (
            SELECT  [name]
            FROM    sys.database_principals
            WHERE   [name] = '$username'
        )
        BEGIN
            create user [$username] from external provider;
        END;";

foreach ($role in $roles) {
  $query += "alter role $role add member [$username];";
};

Invoke-SqlCmd -ServerInstance $sql_fqdn -Database $databaseName -Query $query -AccessToken $token 