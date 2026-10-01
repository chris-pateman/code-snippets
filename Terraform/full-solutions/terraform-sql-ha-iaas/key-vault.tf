locals {
  kv_key_permissions_full = ["backup", "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge",
  "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey"]
  kv_secret_permissions_full = ["backup", "delete", "get", "list", "purge", "recover", "restore", "set"]
  kv_certificate_permissions_full = ["create", "delete", "deleteissuers", "get", "getissuers", "import", "list", "listissuers",
  "managecontacts", "manageissuers", "purge", "recover", "setissuers", "update", "backup", "restore"]
  kv_storage_permissions_full = ["backup", "delete", "deletesas", "get", "getsas", "list", "listsas",
  "purge", "recover", "regeneratekey", "restore", "set", "setsas", "update"]
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv"
  location                    = local.resource_group_location
  resource_group_name         = local.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions     = local.kv_key_permissions_full
    secret_permissions  = local.kv_secret_permissions_full
    storage_permissions = local.kv_storage_permissions_full
  }
}

module "vm_user_secret" {
  source       = "./modules/kv-secret-user"
  type         = "vm"
  key_vault_id = azurerm_key_vault.kv.id
}
module "sql_user_secret" {
  source       = "./modules/kv-secret-user"
  type         = "sql"
  key_vault_id = azurerm_key_vault.kv.id
}
module "domain_user_secret" {
  source       = "./modules/kv-secret-user"
  type         = "domain"
  key_vault_id = azurerm_key_vault.kv.id
}
module "sqlsa_user_secret" {
  source       = "./modules/kv-secret-user"
  type         = "sqlsa"
  user_name    = "sqlsa"
  key_vault_id = azurerm_key_vault.kv.id
}
