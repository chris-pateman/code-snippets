resource "azurerm_resource_group" "this" {
  name     = "example-rg"
  location = "uksouth"
}

resource "azurerm_network_security_group" "this" {
  name                = "example-nsg"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.this.name
}

locals {
  csv_data  = file("${path.module}/nsg_rules.csv")
  nsg_rules = csvdecode(local.csv_data)
}
resource "azurerm_network_security_rule" "this" {
  for_each = { for nsg_rule in local.nsg_rules : nsg_rule.name => nsg_rule }

  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.this.name
  name                        = each.key

  direction                  = each.value.direction
  access                     = each.value.access
  priority                   = each.value.priority
  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix
}