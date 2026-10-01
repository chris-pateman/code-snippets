$CatalogName = "cleansed_dev_old"
$workspaceUrl = "https://999999999999.5.azuredatabricks.net"
$BearerToken = "**********"


# Helper function to call Databricks REST API
function Invoke-DatabricksAPI {
    param (
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null
    )

    $Headers = @{
        Authorization = "Bearer $BearerToken"
        "Content-Type" = "application/json"
    }

    if ($Body) {
        $BodyJson = $Body | ConvertTo-Json -Depth 10
    }

    Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers -Body $BodyJson
}

# Step 1: List all schemas in the catalog
$schemasUri = "$WorkspaceUrl/api/2.1/unity-catalog/schemas?catalog_name=$CatalogName"
$schemas = Invoke-DatabricksAPI -Method "GET" -Uri $schemasUri

foreach ($schema in $schemas.schemas) {
    $schemaName = $schema.name
    if ($schemaName -eq "information_schema") {
        Write-Host "Skipping system schema: $schemaName"
        continue
    }
    # Step 2: List all tables in the schema
    $tablesUri = "$WorkspaceUrl/api/2.1/unity-catalog/tables?catalog_name=$CatalogName&schema_name=$schemaName"
    $tables = Invoke-DatabricksAPI -Method "GET" -Uri $tablesUri

    foreach ($table in $tables.tables) {
        $tableFullName = $table.full_name
        Write-Host "Deleting table: $tableFullName"
        $deleteTableUri = "$WorkspaceUrl/api/2.1/unity-catalog/tables/$tableFullName"
        Invoke-DatabricksAPI -Method "DELETE" -Uri $deleteTableUri
    }

    # Step 3: List and delete functions
    $functionsUri = "$WorkspaceUrl/api/2.1/unity-catalog/functions?catalog_name=$CatalogName&schema_name=$schemaName"
    $functions = Invoke-DatabricksAPI -Method "GET" -Uri $functionsUri

    foreach ($function in $functions.functions) {
        $functionFullName = $function.full_name
        Write-Host "Deleting function: $functionFullName"
        $deleteFunctionUri = "$WorkspaceUrl/api/2.1/unity-catalog/functions/$functionFullName"
        Invoke-DatabricksAPI -Method "DELETE" -Uri $deleteFunctionUri
    }

    # Step 4: Delete the schema
    Write-Host "Deleting schema: $schemaName"
    $deleteSchemaUri = "$WorkspaceUrl/api/2.1/unity-catalog/schemas/$CatalogName.$schemaName`?force=true"
    Invoke-DatabricksAPI -Method "DELETE" -Uri $deleteSchemaUri
}

# Step 5: Delete the catalog
Write-Host "Deleting catalog: $CatalogName"
$deleteCatalogUri = "$WorkspaceUrl/api/2.1/unity-catalog/catalogs/$CatalogName"
Invoke-DatabricksAPI -Method "DELETE" -Uri $deleteCatalogUri

Write-Host "Catalog '$CatalogName' and all children deleted successfully."
