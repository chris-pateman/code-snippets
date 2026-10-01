$permissions = @{
    sqlServerName = "azsql-fame-#ENV#-uks-001";
    databaseName  = "IngestionControlMetadata";
    environments = @("dev","sit","uat");
    users         = @(
      @{
        name   = "spn-#ENV#";
        rights = "db_datareader,db_datawriter,db_securityadmin"
      },
    );
  };

$InformationPreference = "Continue";

az login --use-device-code;
$token = $(az account get-access-token --resource=https://database.windows.net --query accessToken --output tsv);

Write-Information "Installing SqlServer now";
Install-Module -Name SqlServer -Scope CurrentUser -Force;

for ($s = 0; $s -lt $permissions.environments.count; $s++) {
  $sqlServer = $permissions;
  $environment = $permissions.environments[$s];
  $sqlServerName = $sqlServer.sqlServerName -replace "#ENV#",$environment ;
  $databaseName = $sqlServer.databaseName;
  Write-Information "";
  Write-Information "Granting for $($databaseName) in $($sqlServerName)";
  
  for ($u = 0; $u -lt $sqlServer.users.count; $u++) {
    $user = $sqlServer.users[$u];
    $username = $user.name -replace "#ENV#",$environment ;
    $roles_csv = $user.rights;

    $roles = $roles_csv.split(",");
    $sql_fqdn = "$($sqlServerName).database.windows.net";


    Write-Information "Grant $($username) access to $($databaseName) in $sql_fqdn";
    Write-Information "with roles: $roles";
  
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
  
    if ($username -like "spn-edp-*") {
      $query += "GRANT CREATE PROCEDURE TO [$username];";
    };
  
    Invoke-SqlCmd -ServerInstance $sql_fqdn -Database $databaseName -Query $query -AccessToken $token;

  };
};


