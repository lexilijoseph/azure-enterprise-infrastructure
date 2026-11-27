subscription_id       = "00000000-0000-0000-0000-000000000000"
tenant_id             = "00000000-0000-0000-0000-000000000000"
location              = "Central India"
resource_group_name   = "rg-enterprise-dev"
storage_account_name  = "stenterprisedev001" # Replace with a globally unique name if unavailable.
storage_replication_type = "LRS"

app_registration_name = "app-enterprise-dev"
app_redirect_uris     = []

security_group_name        = "sg-enterprise-dev"
security_group_description = "Enterprise application users - DEV"

users = {
  user01 = {
    display_name        = "Dev User One"
    user_principal_name = "devuser01@YOUR-DOMAIN.onmicrosoft.com"
    mail_nickname       = "devuser01"
  }
  user02 = {
    display_name        = "Dev User Two"
    user_principal_name = "devuser02@YOUR-DOMAIN.onmicrosoft.com"
    mail_nickname       = "devuser02"
  }
}

force_password_change  = true
app_registration_role = "Contributor"
