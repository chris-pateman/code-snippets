# EDP Core Databricks API
Deploys the EDP Core Databricks API for APIM


## Environment Deployment Status
| Environment     | Apply Status |
|-----------------|--------------|
| **Deployment**    | [![cd.yml](https://github.com/bank-of-england-technology/api-edp-core-dbw/actions/workflows/-cd.yml/badge.svg?branch=main)](https://github.com/bank-of-england-technology/api-edp-core-dbw/actions/workflows/cd.yml) |
| **CI**            | [![ci.yaml](https://github.com/bank-of-england-technology/api-edp-core-dbw/actions/workflows/ci.yaml/badge.svg)](https://github.com/bank-of-england-technology/api-edp-core-dbw/actions/workflows/ci.yaml) |


<!-- textlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.15.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.15.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =3.115.0 |
| <a name="requirement_semvers"></a> [semvers](#requirement\_semvers) | =0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 1.15.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | =3.115.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api"></a> [api](#module\_api) | git@github.com:bank-of-england-technology/tf-az-mod-apim-workspace-api | v0.0.4 |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.version_set](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource_id.workspace](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_id) | data source |
| [azapi_resource_list.apis](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.115.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_TAG_VERSION"></a> [TAG\_VERSION](#input\_TAG\_VERSION) | Repositories Version | `string` | `"0.0.0"` | no |
| <a name="input_apim_name"></a> [apim\_name](#input\_apim\_name) | APIM Service Name | `string` | n/a | yes |
| <a name="input_apim_resource_group_name"></a> [apim\_resource\_group\_name](#input\_apim\_resource\_group\_name) | APIM Service Resource Group Name | `string` | n/a | yes |
| <a name="input_envirionment"></a> [envirionment](#input\_envirionment) | Environment name | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription id envirionment | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Workspace Name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->