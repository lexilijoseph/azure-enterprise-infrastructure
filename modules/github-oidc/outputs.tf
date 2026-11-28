
output "client_id" {
  description = "Application client ID for GitHub Actions OIDC"
  value       = azuread_application.github_actions.client_id
}

output "application_object_id" {
  description = "Object ID of the GitHub Actions App Registration"
  value       = azuread_application.github_actions.object_id
}

output "service_principal_object_id" {
  description = "Object ID of the GitHub Actions Service Principal"
  value       = azuread_service_principal.github_actions.object_id
}

output "federated_credential_ids" {
  description = "Federated identity credential IDs for GitHub environments"
  value = {
    for environment, credential in azuread_application_federated_identity_credential.environment :
    environment => credential.id
  }
}

output "role_assignment_id" {
  description = "Azure Contributor role assignment ID"
  value       = azurerm_role_assignment.github_contributor.id
}
