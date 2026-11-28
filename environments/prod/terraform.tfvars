subscription_id          = "a8d34578-fbeb-4cb3-b3b1-fd0092bf136c"
tenant_id                = "42bd091a-b238-4405-be63-cca871daf96d"
location                 = "Central India"
resource_group_name      = "rg-enterprise-prod"
storage_account_name     = "stenterpriseprod001" # Replace with a globally unique name if unavailable.
storage_replication_type = "GRS"

app_registration_name = "app-enterprise-prod"
app_redirect_uris     = []

security_group_name        = "sg-enterprise-prod"
security_group_description = "Enterprise application users - PROD"

users = {
  user01 = {
    display_name        = "Prod User One"
    user_principal_name = "produser01@YOUR-DOMAIN.onmicrosoft.com"
    mail_nickname       = "produser01"
  }
  user02 = {
    display_name        = "Prod User Two"
    user_principal_name = "produser02@YOUR-DOMAIN.onmicrosoft.com"
    mail_nickname       = "produser02"
  }
}
force_password_change = true
app_registration_role = "Contributor"
