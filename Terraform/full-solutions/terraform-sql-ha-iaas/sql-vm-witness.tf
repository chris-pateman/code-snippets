module "witness_sql_vm" {
  source              = "./modules/vm"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

  backend_pool_id = azurerm_lb_backend_address_pool.be_pool.id

  vm_name           = format("${var.prefix}-vm-sec-%02s", 1)
  vm_subnet_id      = azurerm_subnet.sql.id
  vm_admin_username = module.vm_user_secret.username
  vm_admin_password = module.sql_user_secret.password

  network_security_group_id = azurerm_network_security_group.nsg.id

  availability_set_id = azurerm_availability_set.avs.id

  storage_uri = azurerm_storage_account.sa.id

  vm_storage_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


data "azurerm_storage_account_blob_container_sas" "FileShareWitness" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  container_name    = azurerm_storage_container.dsc.name
  https_only        = true

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), "120h"))

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }
}


#Configure the fileshare witness
resource "azurerm_virtual_machine_extension" "CreateFileShareWitness" {
  name                 = "CreateFileShareWitness"
  virtual_machine_id   = module.witness_sql_vm.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.71"
  depends_on           = [module.witness_sql_vm]
  settings             = <<SETTINGS
            {
                "modulesURL": "${azurerm_storage_blob.FileShareWitness.url}",
                "sasToken": "${data.azurerm_storage_account_blob_container_sas.FileShareWitness.sas}",
                    "configurationFunction": "CreateFileShareWitness.ps1\\CreateFileShareWitness",
                    "properties": {
                        "domainName": "${local.ad_config.domainName}",
                        "SharePath": "${local.sharePath}",
                        "domainCreds": {
                        "userName": "${module.domain_user_secret.username}",
                            "password": "privateSettingsRef:domainPassword"
                        },
                        "ouPath": "${local.ad_config.serverOUPath}"
                    }
            }
            SETTINGS
  protected_settings   = <<PROTECTED_SETTINGS
         {
      "Items": {
                        "domainPassword": "${module.domain_user_secret.password}"
                }
        }
    PROTECTED_SETTINGS
}