locals {
  lb_frontend_config_name = "${var.prefix}-lb-fe"
  lb_backend_config_name  = "${var.prefix}-lb-be"
}

#Create the SQL Load Balencer
resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-lb"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  frontend_ip_configuration {
    name                          = local.lb_frontend_config_name
    private_ip_address_allocation = "Static"
    private_ip_address            = local.ip_config.lb_ip
    subnet_id                     = azurerm_subnet.sql.id
  }

}

#Create the load balencer backend pool
resource "azurerm_lb_backend_address_pool" "be_pool" {
  #resource_group_name = local.resource_group_name
  loadbalancer_id = azurerm_lb.lb.id
  name            = local.lb_backend_config_name
}

#Create the load balencer rules
resource "azurerm_lb_rule" "sql_rule" {
  resource_group_name            = local.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "${var.prefix}-lb-rule-sql"
  protocol                       = "Tcp"
  frontend_port                  = 1433
  backend_port                   = 1433
  frontend_ip_configuration_name = local.lb_frontend_config_name
  probe_id                       = azurerm_lb_probe.probe.id
}

#Create a health probe for the load balencer
resource "azurerm_lb_probe" "probe" {
  resource_group_name = local.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.prefix}-lb-probe"
  port                = 59999
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}
