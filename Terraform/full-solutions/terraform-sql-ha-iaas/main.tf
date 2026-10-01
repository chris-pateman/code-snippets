data "azurerm_client_config" "current" {}

/* resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
} 
locals {
  resource_group_name = resource_group_name.rg.name
  resource_group_location = resource_group_name.rg.location
}

*/

// FOR TESTING ONLY
data "azurerm_resource_group" "rg" {
  name = "patemanc-sandbox-rg"
}
locals {
  resource_group_name     = data.azurerm_resource_group.rg.name
  resource_group_location = data.azurerm_resource_group.rg.location
}

locals {
  sqlServerServiceAccountUserName = "svc-tstsql1"
  numberOfSqlVMDisks              = 2
  workloadType                    = "OLTP"
  ad_config = {
    domainUsername = "azureadmin"
    domainName     = "shared.demo.ca"
    serverOUPath   = "OU=Servers,OU=DemoApp,OU=Applications,OU=PSPC,DC=shared,DC=demo,DC=ca"
    accountOUPath  = "OU=Service Accounts,OU=DemoApp,OU=Applications,OU=demo,DC=shared,DC=ca"
  }

  sqlAOEPName       = "${var.prefix}-sql-hadr"
  sqlAOAGName       = "${var.prefix}-sql-ag"
  sqlAOListenerName = "${var.prefix}-sql-lis"
  sharePath         = "${var.prefix}-sql-fsw"
  clusterName       = "${var.prefix}-sql-cl"
  dnsServerName     = "DemoSharedDC01"
  sqlDatabases      = "ExampleDb"

  ##TODO: set IP Addresses
  ip_config = {
    vnet_address_space = "10.50.11.48/28"
    sql_subnet_address = "10.50.11.48/29"

    lb_ip = "10.50.11.48"

    clusterIp = "169.254.1.15"
  }
}
// IP Start //  Mask // Range // Hosts // Broadcast (2)
//10.50.11.48 // 28 // X.48 - X.63 // 16 // X.65
//10.50.11.48 // 29 // X.48 - X.55 // 8 // X.57