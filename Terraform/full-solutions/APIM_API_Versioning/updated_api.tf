## Input Examples
locals {
  apim_name = "cpexampleapim"
  apim_resource_group_name = "cp-example-rg"
  api_name_prefix       = "cp-api-example"
  api_version = "1.6.0"
  version_count_to_keep = 5
}

data "azurerm_api_management" "apim" {
  name                = local.apim_name
  resource_group_name = local.apim_resource_group_name
}

resource "azurerm_api_management_api_version_set" "main" {
  name                = "cp-example-set"
  resource_group_name = local.apim_resource_group_name
  api_management_name = local.apim_name
  display_name        = "CP-Example-Set"
  versioning_scheme   = "Query"
  version_query_name  = "api-version"
}

data "azapi_resource_list" "apis" {
  type      = "Microsoft.ApiManagement/service/apis@2024-05-01"
  parent_id = data.azurerm_api_management.apim.id
  query_parameters = {
    "$filter" = ["contains(name ,'${local.api_name_prefix}')"]
  }
}

locals {
  new_version = {
    "${local.api_version}" = {
      name    = "${local.api_name_prefix}"
      version = "${local.api_version}"
    }
  }
  current_versions = flatten([
    for api in data.azapi_resource_list.apis.output.value : api.properties.apiVersion
  ])

  latest_versions = slice(provider::semvers::sort(local.current_versions), 0, local.version_count_to_keep)

  tostay_api_versions = {
    for api in data.azapi_resource_list.apis.output.value :
    api.properties.apiVersion => api
    if contains(local.latest_versions, api.properties.apiVersion)
  }

  todeploy_api_versions = merge(local.tostay_api_versions, local.new_version)
}

resource "azurerm_api_management_api" "api" {
  for_each              = local.todeploy_api_versions
  
  name                  = "${local.api_name_prefix}-${replace(each.key, ".", "-")}"
  resource_group_name = local.apim_resource_group_name
  api_management_name = local.apim_name
  revision              = "1"

  version        = each.key
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
