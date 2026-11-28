
output "virtual_network_id" {
  description = "Virtual Network resource ID"
  value       = azurerm_virtual_network.this.id
}

output "private_endpoint_subnet_id" {
  description = "Private endpoint subnet resource ID"
  value       = azurerm_subnet.private_endpoint.id
}

output "storage_blob_private_dns_zone_id" {
  description = "Storage Blob private DNS zone resource ID"
  value       = azurerm_private_dns_zone.storage_blob.id
}

output "key_vault_private_dns_zone_id" {
  description = "Key Vault private DNS zone resource ID"
  value       = azurerm_private_dns_zone.key_vault.id
}

