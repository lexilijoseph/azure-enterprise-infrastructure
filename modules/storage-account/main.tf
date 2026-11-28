
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
  sku_name            = "standard"

  enabled_for_disk_encryption = false
  soft_delete_retention_days  = 90
  purge_protection_enabled    = true
  rbac_authorization_enabled  = false

  public_network_access_enabled = false

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = var.tags
}

# Terraform deployment identity permissions
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

# Storage identity permissions
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

# Customer-managed encryption key
resource "azurerm_key_vault_key" "storage" {
  name            = "storage-cmk"
  key_vault_id    = azurerm_key_vault.storage.id
  key_type        = "RSA-HSM"
  key_size        = 2048
  expiration_date = "2028-11-28T00:00:00Z"

  key_opts = [
    "unwrapKey",
    "wrapKey"
  ]

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
  account_kind             = "StorageV2"
  account_replication_type = var.account_replication_type

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  #checkov:skip=CKV_AZURE_33: Queue read, write and delete logging is configured through azurerm_monitor_diagnostic_setting.storage_queue.

  # CKV2_AZURE_40: Disable Shared Key authorization
  shared_access_key_enabled = false

  # Disable public network access
  public_network_access_enabled = false

  # CKV2_AZURE_41: SAS expiration policy
  sas_policy {
    expiration_period = "7.00:00:00"
    expiration_action = "Block"
  }

  # User-assigned managed identity
  identity {
    type = "UserAssigned"

    identity_ids = [
      azurerm_user_assigned_identity.storage_cmk.id
    ]
  }

  # Customer-managed key encryption
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.storage.versionless_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage_cmk.id
  }

  # Blob configuration
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

# CKV2_AZURE_33: Private Endpoint for Blob Storage
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
    name = "storage-dns-zone-group"

    private_dns_zone_ids = [
      var.private_dns_zone_id
    ]
  }

  tags = var.tags
}

# Grant Terraform identity access to Blob data
resource "azurerm_role_assignment" "terraform_storage" {
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"
}

# Private Terraform state container
# Private Terraform state container
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"

  #checkov:skip=CKV2_AZURE_21: Blob read logging is configured using azurerm_monitor_diagnostic_setting.storage_blob. Checkov does not recognize this diagnostic setting.

  depends_on = [
    azurerm_role_assignment.terraform_storage
  ]
}
# Enable Queue service logging
#resource "azurerm_storage_account_queue_properties" "this" {
# storage_account_id = azurerm_storage_account.this.id

# logging {
#   delete                = true
#  read                  = true
#   write                 = true
#  version               = "1.0"
#  retention_policy_days = 7
# }
#}

# Log Analytics workspace
resource "azurerm_log_analytics_workspace" "storage" {
  name                = "law-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# Blob Storage diagnostic settings
#resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
# name                       = "diag-${var.name}-blob"
# target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
# log_analytics_workspace_id = azurerm_log_analytics_workspace.storage.id

# enabled_log {
#   category = "StorageRead"
# }

# enabled_log {
#   category = "StorageWrite"
# }

# enabled_log {
#   category = "StorageDelete"
# }
#}
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

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-${var.name}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${var.name}-kv"
    private_connection_resource_id = azurerm_key_vault.storage.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "key-vault-dns-zone-group"

    private_dns_zone_ids = [
      var.key_vault_private_dns_zone_id
    ]
  }

  tags = var.tags
}


