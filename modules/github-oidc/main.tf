
# GitHub Actions Terraform deployment application
resource "azuread_application" "github_actions" {
  display_name = var.application_name
}

# Service Principal for GitHub Actions authentication
resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application.github_actions.client_id
}

# Federated credentials for GitHub deployment environments
resource "azuread_application_federated_identity_credential" "environment" {
  for_each = toset(var.github_environments)

  application_id = azuread_application.github_actions.id

  display_name = "github-${each.value}"

  description = "GitHub Actions OIDC authentication for ${each.value} environment"

  audiences = ["api://AzureADTokenExchange"]

  issuer = "https://token.actions.githubusercontent.com"

  subject = "repo:${var.github_owner}/${var.github_repository}:environment:${each.value}"
}

# Grant Contributor access to the GitHub Actions Service Principal
resource "azurerm_role_assignment" "github_contributor" {
  scope                = var.scope
  role_definition_name = "Contributor"

  principal_id   = azuread_service_principal.github_actions.object_id
  principal_type = "ServicePrincipal"

  depends_on = [
    azuread_service_principal.github_actions
  ]
}
