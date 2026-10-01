username="$1";
roles="$2";
sqlServerName="$3";
databaseName="$4";

sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc;
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)";

sudo apt-get update;
sudo apt-get install sqlcmd;

username="adf-dev-uks-01";
roles="db_datareader db_datawriter";
sqlServerName="azsql-dev-uks-001";
databaseName="IngestionControlMetadata";




sql_fqdn="$sqlServerName.database.windows.net";

echo "Grant $username access to $databaseName in $sql_fqdn";
echo "with roles: $roles";

query="""IF NOT EXISTS (
            SELECT  [name]
            FROM    sys.database_principals
            WHERE   [name] = '$username'
        )
        BEGIN
            create user [$username] from external provider;
        END""";

for role in $roles; do
  query="$query;alter role $role add member [$username]"
done;

echo $query >> identityCmd.sql
echo "running query"
cat identityCmd.sql

sqlcmd -S azsql-dev-uks-001.database.windows.net -d IngestionControlMetadata --authentication-method ActiveDirectoryManagedIdentity -i identityCmd.sql -o identityCmdOutput.txt

echo "output is:"
cat identityCmdOutput.txt