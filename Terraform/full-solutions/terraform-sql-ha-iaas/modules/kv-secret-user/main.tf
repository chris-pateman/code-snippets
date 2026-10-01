locals {

  pass_secret_name = "${var.type}-admin-password"
  user_secret_name = "${var.type}-admin-username"
  user_name        = var.user_name != "" ? var.user_name : "adminuser"
}

resource "random_password" "pass" {
  length           = 32
  special          = true
  override_special = "_%*"
}
resource "azurerm_key_vault_secret" "pass" {
  key_vault_id = var.key_vault_id
  name         = local.pass_secret_name
  value        = random_password.pass.result
  content_type = "password"
}
resource "azurerm_key_vault_secret" "user" {
  key_vault_id = var.key_vault_id
  name         = local.user_secret_name
  value        = local.user_name
  content_type = "username"
}
