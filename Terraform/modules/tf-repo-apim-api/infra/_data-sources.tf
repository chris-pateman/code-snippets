data "azurerm_client_config" "current" {}

data "azapi_resource_id" "workspace" {
  type      = "Microsoft.ApiManagement/service/workspaces@2024-05-01"
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.apim_resource_group_name}/providers/Microsoft.ApiManagement/service/${var.apim_name}"
  name      = format(var.workspace_name, var.envirionment)
}