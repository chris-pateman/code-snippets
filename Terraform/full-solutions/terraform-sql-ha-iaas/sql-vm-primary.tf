module "primary_sql_vm" {
  source              = "./modules/sql-vm"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

  backend_pool_id = azurerm_lb_backend_address_pool.be_pool.id

  vm_name           = format("${var.prefix}-vm-pri-%02s", 1)
  vm_subnet_id      = azurerm_subnet.sql.id
  vm_admin_username = module.vm_user_secret.username
  vm_admin_password = module.sql_user_secret.password

  network_security_group_id = azurerm_network_security_group.nsg.id

  availability_set_id = azurerm_availability_set.avs.id

  storage_uri = azurerm_storage_account.sa.id

  sql_connectivity_update_password = module.sql_user_secret.password
  sql_connectivity_update_username = module.sql_user_secret.username
}

data "azurerm_storage_account_blob_container_sas" "PrepareAlwaysOn" {
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


#Prepare the servers for Always On.  
#Adds FailOver windows components, joins machines to AD, adjusts firewall rules and adds sql service account
resource "azurerm_virtual_machine_extension" "PrepareAlwaysOn" {
  name                 = "PrepareAlwaysOn"
  virtual_machine_id   = module.primary_sql_vm.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.71"
  depends_on           = [module.primary_sql_vm, module.witness_sql_vm]
  settings             = <<SETTINGS
            {
                "modulesURL": "${azurerm_storage_blob.PrepareAlwaysOn.url}",
                "sasToken": "${data.azurerm_storage_account_blob_container_sas.PrepareAlwaysOn.sas}",
                "configurationFunction": "PrepareAlwaysOnSqlServer.ps1\\PrepareAlwaysOnSqlServer",
                "properties": {
                    "domainName": "${local.ad_config.domainName}",
                    "sqlAlwaysOnEndpointName": "${module.primary_sql_vm.name}-hadr",
                    "adminCreds": {
                        "userName": "${module.vm_user_secret.username}",
                        "password": "privateSettingsRef:AdminPassword"
                    },
                    "domainCreds": {
                        "userName": "${module.domain_user_secret.username}",
                        "password": "privateSettingsRef:domainPassword"
                    },
                    "sqlServiceCreds": {
                        "userName": "${module.sql_user_secret.username}",
                        "password": "privateSettingsRef:SqlServerServiceAccountPassword"
                    },
                    "NumberOfDisks": "${local.numberOfSqlVMDisks}",
                    "WorkloadType": "${local.workloadType}",
                    "serverOUPath": "${local.ad_config.serverOUPath}",
                    "accountOUPath": "${local.ad_config.accountOUPath}"
                }
            }
SETTINGS
  protected_settings   = <<PROTECTED_SETTINGS
         {
      "Items": {
                        "domainPassword": "${module.domain_user_secret.password}",
                        "adminPassword": "${module.vm_user_secret.password}",
                        "sqlServerServiceAccountPassword": "${module.sql_user_secret.password}"
                }
        }
    PROTECTED_SETTINGS
}
