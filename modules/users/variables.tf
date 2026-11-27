variable "users" {
  type = map(object({
    display_name        = string
    user_principal_name = string
    mail_nickname       = string
  }))
}
variable "initial_password" {
  type      = string
  sensitive = true
}
variable "force_password_change" {
  type    = bool
  default = true
}
