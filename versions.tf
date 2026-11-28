terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  # First-time bootstrap:
  # terraform init -backend=false
  # terraform apply -var-file="environments/dev/terraform.tfvars"
  # terraform init -migrate-state -backend-config="environments/dev/backend.hcl"
  # backend "azurerm" {}
}
