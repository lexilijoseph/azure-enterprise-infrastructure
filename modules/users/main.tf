resource "azuread_user" "this" {
  for_each = var.users

  display_name          = each.value.display_name
  user_principal_name   = each.value.user_principal_name
  mail_nickname         = each.value.mail_nickname
  password              = var.initial_password
  force_password_change = var.force_password_change
}




