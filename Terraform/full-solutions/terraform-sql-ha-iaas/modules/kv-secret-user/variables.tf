variable "key_vault_id" {
  type        = string
  description = "Key Vault ID"
}
variable "type" {
  type        = string
  description = "Secret Type"
}
variable "user_name" {
  type        = string
  description = "Username. Default = adminuser"
  default     = ""
}
