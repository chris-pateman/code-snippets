resource "azurerm_storage_account" "sa" {
  name                      = replace("${var.prefix}sa", "-", "")
  location                  = local.resource_group_location
  resource_group_name       = local.resource_group_name
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Cool"
  enable_https_traffic_only = "true"

}

resource "azurerm_storage_container" "dsc" {
  name                  = "dsc"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}
resource "azurerm_storage_blob" "PrepareAlwaysOn" {
  name                   = "PrepareAlwaysOnSqlServer.ps1.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.dsc.name
  type                   = "Block"
  source                 = "./resources/DSC/PrepareAlwaysOnSqlServer.ps1.zip"
}
resource "azurerm_storage_blob" "FailoverCluster" {
  name                   = "CreateFailoverCluster.ps1.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.dsc.name
  type                   = "Block"
  source                 = "./resources/DSC/CreateFailoverCluster.ps1.zip"
}
resource "azurerm_storage_blob" "FileShareWitness" {
  name                   = "CreateFileShareWitness.ps1.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.dsc.name
  type                   = "Block"
  source                 = "./resources/DSC/CreateFileShareWitness.ps1.zip"
}