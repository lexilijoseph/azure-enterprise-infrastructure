
variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
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
    error_message = "Replication must be geo-redundant or zone-redundant."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "private_endpoint_subnet_id" {
  description = "Existing subnet ID for the Storage Account private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for Blob Storage"
  type        = string
}

variable "key_vault_private_dns_zone_id" {
  description = "Private DNS zone ID for Azure Key Vault"
  type        = string
}
