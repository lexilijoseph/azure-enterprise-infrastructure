output "resource_group_name" {
  description = "Created Azure Resource Group."
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "Resource Group ARM ID."
  value       = module.resource_group.id
}

output "storage_account_name" {
  description = "Created Storage Account."
  value       = module.storage_account.name
}

output "app_registration_client_id" {
  description = "Application (client) ID. Treat as an identifier, not a secret."
  value       = module.app_registration.client_id
}

output "app_registration_object_id" {
  description = "Application object ID."
  value       = module.app_registration.application_object_id
}

output "service_principal_object_id" {
  description = "Enterprise application / service principal object ID."
  value       = module.app_registration.service_principal_object_id
}

output "security_group_id" {
  description = "Created Entra security group object ID."
  value       = module.security_group.group_id
}

output "created_users" {
  description = "Created users, keyed by the Terraform map key."
  value       = module.users.user_principal_names
}

output "github_actions_client_id" {
  description = "Azure Client ID generated for GitHub Actions"
  value       = module.github_oidc.client_id
}

output "github_actions_service_principal_id" {
  description = "GitHub Actions Service Principal Object ID"
  value       = module.github_oidc.service_principal_object_id
}