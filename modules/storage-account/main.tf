
# Get current Terraform deployment identity
data "azurerm_client_config" "current" {}

# User-assigned identity for Storage Account CMK
resource "azurerm_user_assigned_identity" "storage_cmk" {
  name                = "id-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Key Vault for Customer-Managed Key
resource "azurerm_key_vault" "storage" {
  name                = "kv${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                   = "premium"
  soft_delete_retention_days = 90
  purge_protection_enabled   = true

  rbac_authorization_enabled = false

  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = var.tags
}

# Terraform deployment identity access policy
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.storage.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "List",
    "Update",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]
}

# Storage Account managed identity access policy
resource "azurerm_key_vault_access_policy" "storage_identity" {
  key_vault_id = azurerm_key_vault.storage.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.storage_cmk.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

# Customer-Managed HSM Key
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-cmk"
  key_vault_id = azurerm_key_vault.storage.id

  key_type = "RSA-HSM"
  key_size = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]

  expiration_date = "2028-11-28T00:00:00Z"

  depends_on = [
    azurerm_key_vault_access_policy.terraform
  ]
}

# Storage Account
resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false

  # SAS expiration policy
  sas_policy {
    expiration_period = "7.00:00:00"
    expiration_action = "Block"
  }

  # Queue logging is configured using Azure Monitor diagnostic settings.
  #checkov:skip=CKV_AZURE_33: Queue read, write and delete logging is configured through azurerm_monitor_diagnostic_setting.storage_queue.

  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.storage_cmk.id
    ]
  }

  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage.versionless_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_cmk.id
  }

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_access_policy.storage_identity
  ]
}

# Storage Account Blob Private Endpoint
resource "azurerm_private_endpoint" "storage_blob" {
  name                = "pe-${var.name}-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-blob-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-${var.name}-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}-keyvault"
    private_connection_resource_id = azurerm_key_vault.storage.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [var.key_vault_private_dns_zone_id]
  }

  tags = var.tags
}

# Give Terraform deployment identity access to Storage Blob data
resource "azurerm_role_assignment" "terraform_storage" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
}

# Terraform state container
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"

  #checkov:skip=CKV2_AZURE_21: Blob read logging is configured using azurerm_monitor_diagnostic_setting.storage_blob.

  depends_on = [
    azurerm_role_assignment.terraform_storage
  ]
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "storage" {
  name                = "law-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# Storage Blob Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  name                       = "diag-${var.name}-blob"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.storage.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }
}

# Storage Queue Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage_queue" {
  name                       = "diag-${var.name}-queue"
  target_resource_id         = "${azurerm_storage_account.this.id}/queueServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.storage.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }
}
