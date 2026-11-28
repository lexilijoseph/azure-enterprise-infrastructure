
subscription_id = "a8d34578-fbeb-4cb3-b3b1-fd0092bf136c"
tenant_id       = "42bd091a-b238-4405-be63-cca871daf96d"

location            = "Central India"
resource_group_name = "rg-enterprise-dev"

storage_account_name     = "stenterprisedev001"
storage_replication_type = "GRS"

# Network configuration
vnet_name                        = "vnet-enterprise-dev"
vnet_address_space               = ["10.10.0.0/16"]
private_endpoint_subnet_name     = "snet-private-endpoints"
private_endpoint_subnet_prefixes = ["10.10.1.0/24"]

# Application registration
app_registration_name = "app-enterprise-dev"
app_redirect_uris     = []

# Security group
security_group_name        = "sg-enterprise-dev"
security_group_description = "Enterprise application users - DEV"

# Users
users = {
  user01 = {
    display_name        = "Dev User One"
    user_principal_name = "devuser01@YOUR-ACTUAL-DOMAIN.onmicrosoft.com"
    mail_nickname       = "devuser01"
  }

  user02 = {
    display_name        = "Dev User Two"
    user_principal_name = "devuser02@YOUR-ACTUAL-DOMAIN.onmicrosoft.com"
    mail_nickname       = "devuser02"
  }
}

force_password_change = true
app_registration_role = "Contributor"


