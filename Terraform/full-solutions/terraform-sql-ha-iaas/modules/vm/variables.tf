variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}
variable "location" {
  type        = string
  description = "Resource Location"
}

variable "backend_pool_id" {
  type        = string
  description = "ID for the LB Backend Pool"
}

variable "vm_name" {
  type        = string
  description = "Virtual Machine Name"
}
variable "vm_size" {
  type        = string
  description = "Virtual Machine Size"
  default     = "Standard_E4ds_v5"
}
variable "vm_subnet_id" {
  type        = string
  description = "Virtual Machine Subnet ID"
}
variable "vm_admin_username" {
  type        = string
  description = "Virtual Machine Username"
}
variable "vm_admin_password" {
  type        = string
  description = "Virtual Machine Password"
  sensitive   = true
}
variable "vm_storage_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "Virtual Machine Image Details"
}

variable "network_security_group_id" {
  type        = string
  description = "Network Security Group ID"
}

variable "availability_set_id" {
  type        = string
  description = "Availability Set ID"
}

variable "storage_uri" {
  type        = string
  description = "Storage Account for logs URI"
}
