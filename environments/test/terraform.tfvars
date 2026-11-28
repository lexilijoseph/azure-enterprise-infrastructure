subscription_id          = "a8d34578-fbeb-4cb3-b3b1-fd0092bf136c"
tenant_id                = "42bd091a-b238-4405-be63-cca871daf96d"
location                 = "Central India"
resource_group_name      = "rg-enterprise-test"
storage_account_name     = "stenterprisetest001" # Replace with a globally unique name if unavailable.
storage_replication_type = "LRS"

app_registration_name = "app-enterprise-test"
app_redirect_uris     = []

security_group_name        = "sg-enterprise-test"
security_group_description = "Enterprise application users - TEST"

users = {
  user01 = {
    display_name        = "Test User One"
    user_principal_name = "testuser01@YOUR-DOMAIN.onmicrosoft.com"
    mail_nickname       = "testuser01"
  }
  user02 = {
    display_name        = "Test User Two"
    user_principal_name = "testuser02@YOUR-DOMAIN.onmicrosoft.com"
    mail_nickname       = "testuser02"
  }
}

force_password_change = true
app_registration_role = "Contributor"
