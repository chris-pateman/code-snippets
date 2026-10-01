variable "location_abbreviated" {
  description = "Abbreviated Environment Resource Locations e.g. uks, ukw"
  type        = string
}

variable "corehub_azfw_ip" {
  description = "Private IP address of the Azure Firewall in the core hub."
  type        = string
}

variable "orc_subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "hub_subscription_id" {
  type = string
}

variable "required_tags" {
  type = string
}

variable "tenant" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "service" {
  type = string
}

variable "hub_firewall_ip" {
  type = string
}

variable "laws_workspace_resource_id" {
  type = string
}

variable "hub_vnet_address_space" {
  type = string
}

variable "spoke_vnet_address_space" {
  type = string
}
