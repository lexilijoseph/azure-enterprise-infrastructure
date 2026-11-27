subscription_id       = "a8d34578-fbeb-4cb3-b3b1-fd0092bf136c"
tenant_id             = "42bd091a-b238-4405-be63-cca871daf96d"
location              = "Central India"
resource_group_name   = "rg-enterprise-dev"
storage_account_name  = "stenterprisedev001" # Must be globally unique.
storage_replication_type = "LRS"

app_registration_name = "app-enterprise-dev"
app_redirect_uris     = []

security_group_name        = "sg-enterprise-dev"
security_group_description = "Enterprise application users - Dev"

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

# Do not commit the real password. Set TF_VAR_initial_user_password in your shell/CI secret.
force_password_change  = true
app_registration_role = "Contributor"
