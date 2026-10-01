resource "azurerm_virtual_network" "vnet" {
  name          = "${var.prefix}-vnet"
  address_space = [local.ip_config.vnet_address_space]

  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

}

resource "azurerm_subnet" "sql" {
  name                 = "sql-subnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.ip_config.sql_subnet_address]
}
