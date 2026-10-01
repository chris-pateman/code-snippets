module "api" {
  source   = "git@github.com:bank-of-england-technology/tf-az-mod-apim-workspace-api?ref=v0.0.4"
  for_each = local.deploy_versions

  workspace_id = data.azapi_resource_id.workspace.id
  name         = local.api_name
  config = {
    apiName     = local.api_name
    description = "Core Databricks API"
    displayName = "Core Databricks API"
    path        = "/${local.platform_name}/${local.api_slug}"
    protocols   = ["https"]
    type        = "http"
    apiType     = "http"
    serviceUrl  = "https://something.com"

    format = "openapi+json"
    value  = file("./resources/api-openai.json")

    apiRevision           = "1"
    apiVersion            = "v${each.value.version}"
    apiVersionDescription = "v${each.value.version}"
    apiVersionSetId       = azapi_resource.version_set.id
  }
  import_operations_policies = [
    for policy_file in fileset("./resources/operations-policies", "*.xml") : {
      name          = replace(basename(policy_file), ".xml", "")
      format        = "xml"
      policy_value  = file("./resources/operations-policies/${policy_file}")
      operations_id = replace(basename(policy_file), ".xml", "")
    }
  ]
}