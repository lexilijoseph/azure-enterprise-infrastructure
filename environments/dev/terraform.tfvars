# Microsoft Entra Users
users = {
  user01 = {
    display_name        = "Dev User One"
    user_principal_name = "devuser01@lexilijosephgmail.onmicrosoft.com"
    mail_nickname       = "devuser01"
  }

  user02 = {
    display_name        = "Dev User Two"
    user_principal_name = "devuser02@lexilijosephgmail.onmicrosoft.com"
    mail_nickname       = "devuser02"
  }
}

# Microsoft Entra Custom Domain
custom_domain_name = "lexilijosephgmail.onmicrosoft.com"

private_endpoint_subnet_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_NETWORK_RG/providers/Microsoft.Network/virtualNetworks/YOUR_VNET/subnets/YOUR_SUBNET"

private_dns_zone_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_DNS_RG/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"

# User configuration
force_password_change    = true
storage_replication_type = "GRS"

key_vault_private_dns_zone_id = "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_DNS_RG/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"

