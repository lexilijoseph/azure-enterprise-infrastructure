
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
  description = "Azure Resource Group name."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique 3-24 character lowercase Storage Account name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage Account name must contain 3-24 lowercase letters or numbers."
  }
}

variable "storage_replication_type" {
  description = "Storage redundancy: LRS, ZRS, GRS, RAGRS or GZRS."
  type        = string
  default     = "LRS"

  validation {
    condition = contains(
      ["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"],
      var.storage_replication_type
    )
    error_message = "Invalid Storage Account replication type."
  }
}

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
  description = "Temporary initial password for created users."
  type        = string
  sensitive   = true
  default     = "Temp@Azure2026!Secure"
}

variable "force_password_change" {
  description = "Require users to change their password at next sign-in."
  type        = bool
  default     = true
}

variable "app_registration_role" {
  description = "Azure RBAC role assigned to the app's service principal."
  type        = string
  default     = "Contributor"
}

variable "custom_domain_name" {
  description = "Verified Microsoft Entra custom domain."
  type        = string
}