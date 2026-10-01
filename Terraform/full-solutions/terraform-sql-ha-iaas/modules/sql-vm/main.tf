module "vm" {
  source              = "../vm"
  resource_group_name = var.resource_group_name
  location            = var.location

  backend_pool_id = var.backend_pool_id

  vm_name           = var.vm_name
  vm_size           = var.vm_size
  vm_subnet_id      = var.vm_subnet_id
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password

  network_security_group_id = var.network_security_group_id

  availability_set_id = var.availability_set_id

  storage_uri = var.storage_uri

  vm_storage_image_reference = {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2016SP2-WS2016"
    sku       = "Enterprise"
    version   = "latest"
  }
}

# SQL Settings
resource "azurerm_mssql_virtual_machine" "azurerm_sqlvmmanagement" {

  virtual_machine_id               = module.vm.id
  sql_license_type                 = "PAYG"
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = var.sql_connectivity_update_password
  sql_connectivity_update_username = var.sql_connectivity_update_username

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  storage_configuration {
    disk_type             = "NEW"  # (Required) The type of disk configuration to apply to the SQL Server. Valid values include NEW, EXTEND, or ADD.
    storage_workload_type = "OLTP" # (Required) The type of storage workload. Valid values include GENERAL, OLTP, or DW.

  }
}
