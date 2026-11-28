output "user_object_ids" {
  value = toset([for user in azuread_user.this : user.object_id])
}
output "user_principal_names" {
  value = { for key, user in azuread_user.this : key => user.user_principal_name }
}
