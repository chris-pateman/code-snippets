resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "sql" {
  subnet_id                 = azurerm_subnet.sql.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_rule" "rdp_sql" {
  name                        = "Allow_RDP_VPN"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = ["10.0.0.0/24"]
  destination_address_prefix  = local.ip_config.sql_subnet_address
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "sql" {
  name                        = "Allow_App_SQL"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefixes     = ["10.0.0.0/24"]
  destination_address_prefix  = local.ip_config.sql_subnet_address
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "sql_deny_all" {
  name                        = "Deny_All_Inbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = local.ip_config.sql_subnet_address
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}