variable "display_name" {
  type = string
}

variable "redirect_uris" {
  type    = list(string)
  default = []
}
