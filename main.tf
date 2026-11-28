module "resource_group" {
  source   = "./modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source              = "./modules/network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
  subnet_name         = var.private_endpoint_subnet_name
  subnet_prefixes     = var.private_endpoint_subnet_prefixes
  tags                = local.common_tags
}

module "storage_account" {
  source                   = "./modules/storage-account"
  name                     = var.storage_account_name
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_replication_type = var.storage_replication_type
  tags                     = local.common_tags

  # Automatically pass network resource IDs
  private_endpoint_subnet_id    = module.network.private_endpoint_subnet_id
  private_dns_zone_id           = module.network.storage_blob_private_dns_zone_id
  key_vault_private_dns_zone_id = module.network.key_vault_private_dns_zone_id

  depends_on = [module.network]
}

module "users" {
  source                = "./modules/users"
  users                 = var.users
  initial_password      = var.initial_user_password
  force_password_change = var.force_password_change
}

module "security_group" {
  source          = "./modules/security-group"
  display_name    = var.security_group_name
  description     = var.security_group_description
  user_object_ids = module.users.user_object_ids
}

module "app_registration" {
  source        = "./modules/app-registration"
  display_name  = var.app_registration_name
  redirect_uris = var.app_redirect_uris
}

module "role_assignment" {
  source               = "./modules/role-assignment"
  scope                = module.resource_group.id
  principal_id         = module.app_registration.service_principal_object_id
  role_definition_name = var.app_registration_role
  depends_on           = [module.resource_group, module.app_registration]
}


