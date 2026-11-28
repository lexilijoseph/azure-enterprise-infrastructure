
variable "application_name" {
  description = "Azure App Registration name for GitHub Actions"
  type        = string
  default     = "app-github-actions-terraform"
}

variable "github_owner" {
  description = "GitHub username or organization name"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "github_environments" {
  description = "GitHub deployment environments"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "scope" {
  description = "Azure resource scope for GitHub Actions Contributor access"
  type        = string
}
