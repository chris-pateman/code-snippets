resource "azurerm_resource_group" "this" {
  name     = "example-rg"
  location = "uksouth"
}

resource "azurerm_network_security_group" "this" {
  for_each = { for nsg in local.nsg_names : nsg => nsg }

  name                = "example-${each.key}-nsg"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.this.name
}

locals {
  nsg_names           = ["hub", "spoke"]
  current_environment = "dev"
  csv_data            = file("${path.module}/nsg_rules.csv")
  nsg_rules           = csvdecode(local.csv_data)
}
resource "azurerm_network_security_rule" "this" {
  for_each = {
    for item in flatten([
      for nsg in local.nsg_names : [
        for nsg_rule in local.nsg_rules : {
          nsg_rule = nsg_rule
          nsg      = azurerm_network_security_group.this[nsg]
        }
        if((nsg_rule.environment == "*" || nsg_rule.environment == local.current_environment) && (nsg_name == "*" || nsg_name == "spoke"))
      ]
    ]) : "${item.nsg.name}_${item.nsg_rule.name}" => item
  }

  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = each.value.nsg.name
  name                        = each.value.nsg_rule

  direction                  = each.value.nsg_rule.direction
  access                     = each.value.nsg_rule.access
  priority                   = each.value.nsg_rule.priority
  protocol                   = each.value.nsg_rule.protocol
  source_port_range          = each.value.nsg_rule.source_port_range
  destination_port_range     = each.value.nsg_rule.destination_port_range
  source_address_prefix      = each.value.nsg_rule.source_address_prefix
  destination_address_prefix = each.value.nsg_rule.destination_address_prefix
}