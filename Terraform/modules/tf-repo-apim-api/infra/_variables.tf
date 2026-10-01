variable "subscription_id" {
  description = "Subscription id envirionment"
  type        = string
}
variable "envirionment" {
  description = "Environment name"
  type        = string
}

variable "workspace_name" {
  description = "Workspace Name"
  type        = string
}
variable "apim_name" {
  description = "APIM Service Name"
  type        = string
}
variable "apim_resource_group_name" {
  description = "APIM Service Resource Group Name"
  type        = string
}

variable "TAG_VERSION" {
  description = "Repositories Version"
  type        = string
  default     = "0.0.0"
}