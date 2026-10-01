locals {
  platform_name        = "core"
  api_slug             = "databricks"
  api_name             = "${local.platform_name}-${local.api_slug}"
  num_versions_to_keep = 5
}