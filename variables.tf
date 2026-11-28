variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "Central India"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique 3-24 character lowercase storage account name."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase letters or numbers."
  }
}

#variable "storage_replication_type" {
# description = "Storage redundancy: LRS, ZRS, GRS or RAGRS."
# type        = string
# default     = "LRS"
#}

variable "app_registration_name" {
  description = "Microsoft Entra application display name."
  type        = string
}

variable "app_redirect_uris" {
  description = "Optional redirect URIs for a web application."
  type        = list(string)
  default     = []
}

variable "security_group_name" {
  description = "Microsoft Entra security group display name."
  type        = string
}

variable "security_group_description" {
  description = "Description of the Entra security group."
  type        = string
  default     = "Managed by Terraform."
}

variable "users" {
  description = "Users to create. Keys are stable Terraform identifiers."
  type = map(object({
    display_name        = string
    user_principal_name = string
    mail_nickname       = string
  }))
}

variable "initial_user_password" {
  description = "Temporary initial password for created users. Supply through TF_VAR_initial_user_password or a secret manager."
  type        = string
  sensitive   = true
}

variable "force_password_change" {
  description = "Require users to change their password at next sign-in."
  type        = bool
  default     = true
}

variable "app_registration_role" {
  description = "Azure RBAC role assigned to the app's service principal at the resource-group scope."
  type        = string
  default     = "Contributor"
}

variable "storage_replication_type" {
  description = "Geo-redundant or zone-redundant Storage Account replication"
  type        = string
  default     = "GRS"

  validation {
    condition = contains(
      ["GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"],
      var.storage_replication_type
    )
    error_message = "Storage replication must be GRS, RAGRS, ZRS, GZRS or RAGZRS."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Private endpoint subnet resource ID"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Storage Blob private DNS zone resource ID"
  type        = string
  default     = null
}

variable "key_vault_private_dns_zone_id" {
  description = "Key Vault private DNS zone resource ID"
  type        = string
  default     = null
}


variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
}

variable "private_endpoint_subnet_name" {
  description = "Private endpoint subnet name"
  type        = string
}

variable "private_endpoint_subnet_prefixes" {
  description = "Private endpoint subnet address prefixes"
  type        = list(string)
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}
