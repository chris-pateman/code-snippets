#Create the SQL Availiability Sets for hardware and update redundancy
resource "azurerm_availability_set" "avs" {
  name                        = "${var.prefix}-vm-avs"
  location                    = local.resource_group_location
  resource_group_name         = local.resource_group_name
  managed                     = true
  platform_fault_domain_count = 2
}