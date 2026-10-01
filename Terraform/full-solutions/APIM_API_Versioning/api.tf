
resource "azurerm_api_management_api_version_set" "set" {
  name                = "tf-example-set"
  resource_group_name = "christopher-pateman-sandbox-rg"
  api_management_name = "patemanapim"
  display_name        = "TF-Example-Set"
  versioning_scheme   = "Query"
  version_query_name  = "api-version"
}

data "azurerm_api_management" "apim" {
  name                = "patemanapim"
  resource_group_name = "christopher-pateman-sandbox-rg"
}

data "azapi_resource_list" "apis" {
  type      = "Microsoft.ApiManagement/service/apis@2024-05-01"
  parent_id = data.azurerm_api_management.apim.id
  query_parameters = {
    "$filter" = ["contains(name ,'tf-pateman')"]
  }
}

locals {
  version_count_to_keep = 2
  new_version = {
    "1.6.0" = {
      name = "tf-pateman-example"
    }
  }
  current_versions = flatten([
    for api in data.azapi_resource_list.apis.output.value : replace(api.properties.apiVersion, "v", "")
  ])
  latest_versions = slice(provider::semvers::sort(local.current_versions), 0, local.version_count_to_keep)
  tostay_api_versions = {
    for api in data.azapi_resource_list.apis.output.value :
    replace(api.properties.apiVersion, "v", "") => api
    if contains(local.latest_versions, replace(api.properties.apiVersion, "v", ""))
  }
  todeploy_api_versions = merge(local.tostay_api_versions, local.new_version)
}

resource "azurerm_api_management_api" "api" {
  for_each              = local.todeploy_api_versions
  name                  = "tf-pateman-example-${replace(each.key, ".", "-")}"
  resource_group_name   = "christopher-pateman-sandbox-rg"
  api_management_name   = "patemanapim"
  revision              = "1"
  display_name          = "TF-Example-API"
  path                  = "example-tf"
  protocols             = ["https"]
  subscription_required = false

  version        = "v${each.key}"
  version_set_id = azurerm_api_management_api_version_set.set.id

  import {
    content_format = "openapi+json"
    content_value  = file("./api-swagger.json")
  }

  depends_on = [azurerm_api_management_api_version_set.set]
  lifecycle {
    ignore_changes = [
      import,
    ]
  }
}