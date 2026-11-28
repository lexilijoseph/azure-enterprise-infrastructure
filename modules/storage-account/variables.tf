variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

#variable "account_replication_type" {
# type    = string
#  default = "LRS"
#}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"

  validation {
    condition = contains(
      ["GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"],
      var.account_replication_type
    )
    error_message = "Use GRS, RAGRS, ZRS, GZRS or RAGZRS. LRS is not allowed."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID used by Storage and Key Vault private endpoints"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for Storage Blob"
  type        = string
}

variable "key_vault_private_dns_zone_id" {
  description = "Private DNS zone ID for Azure Key Vault"
  type        = string
}

