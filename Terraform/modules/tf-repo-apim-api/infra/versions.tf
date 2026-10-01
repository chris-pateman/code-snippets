resource "azapi_resource" "version_set" {
  type      = "Microsoft.ApiManagement/service/workspaces/apiVersionSets@2024-06-01-preview"
  name      = "${local.platform_name}-${local.api_slug}"
  parent_id = data.azapi_resource_id.workspace.id
  body = {
    properties = {
      description      = "${local.platform_name} ${local.api_slug} API"
      displayName      = "${local.platform_name} ${local.api_slug}"
      versioningScheme = "Query"
      versionQueryName = "api-version"
    }
  }
}

data "azapi_resource_list" "apis" {
  type      = "Microsoft.ApiManagement/service/workspaces/apis@2024-06-01-preview"
  parent_id = data.azapi_resource_id.workspace.id
  query_parameters = {
    "$filter" = ["contains(name ,'${local.api_name}')"]
  }
}

locals {
  new_version = {
    "new_version-${var.TAG_VERSION}" = {
      name    = local.api_name
      version = replace(var.TAG_VERSION, "v", "")
    }
  }
  current_versions = flatten([
    for api in data.azapi_resource_list.apis.output.value : replace(api.properties.apiVersion, "v", "")
  ])
  sorted_list = provider::semvers::sort(local.current_versions)

  latest_versions = slice(local.sorted_list, 0, length(local.sorted_list) > local.num_versions_to_keep ? local.num_versions_to_keep : length(local.sorted_list))
  keep_versions = {
    for api in data.azapi_resource_list.apis.output.value :
    replace(api.properties.apiVersion, "v", "") => {
      name    = api.name
      version = replace(api.properties.apiVersion, "v", "")
    }
    if contains(local.latest_versions, replace(api.properties.apiVersion, "v", ""))
  }
  deploy_versions = merge(local.keep_versions, local.new_version)
}