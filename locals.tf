locals {
  common_tags = {
    managed_by  = "Terraform"
    environment = terraform.workspace
    project     = "azure-enterprise-infrastructure"
  }
}
