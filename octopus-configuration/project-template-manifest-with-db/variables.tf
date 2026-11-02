variable "octopus_server" {
  type        = string
  description = "URL of the Octopus Deploy instance, e.g. https://octopus.example.com"
}

variable "octopus_api_key" {
  type        = string
  sensitive   = true
  description = "API key used by the provider."
}

variable "space_id" {
  type        = string
  default     = "Spaces-1" # Default space
  description = "Space to create the project in."
}

# ---- Templated values to be changed by user ----

variable "project_name" {
  type        = string
  description = "The name of the project to create"
}

variable "project_description" {
  type        = string
  description = "The description of the project you wish to create"
}

variable "sbom_package_id" {
  type        = string
  default     = "Trident.SBOM"
  description = "Package ID of the SBOM artifact."
}

variable "database_package_id" {
  type        = string
  default     = "Trident.Database.DbUp"
  description = "Package ID of the DbUp database package (also used as the DbUp executable name)."
}

variable "container_package_id" {
  type        = string
  default     = "bobjwalker99/trident"
  description = "Package ID of the application container image."
}

variable "target_role" {
  type    = string
  default = "trident-web"
}

variable "manifest_git_repo_url" {
  type        = string
  default     = "https://github.com/bobjwalker/trident.git"
  description = "Repository the Deploy K8s Manifest process template pulls manifests from."
}

variable "git_branch" {
  type        = string
  default     = "main"
  description = "Branch used for the manifest and secrets repositories."
}

# ---- Pre-existing resources (IDs taken from the current instance) change only if on a different space than the default space ----

variable "project_group_id" {
  type    = string
  default = "ProjectGroups-483"
}

variable "lifecycle_id" {
  type    = string
  default = "Lifecycles-403"
}

variable "library_variable_set_ids" {
  type        = list(string)
  description = "Standards, Key Vault and Core Configuration library variable sets."
  default = [
    "LibraryVariableSets-421", # Standards
    "LibraryVariableSets-441", # Key Vault
    "LibraryVariableSets-461", # Core Configuration
  ]
}

variable "builtin_feed_id" {
  type        = string
  default     = "feeds-builtin"
  description = "Feed that hosts the SBOM and database packages."
}

variable "container_feed_id" {
  type        = string
  default     = "Feeds-1283"
  description = "Docker feed that hosts the application container image."
}

variable "notification_team_id" {
  type    = string
  default = "Teams-81"
}

variable "approval_environment_id" {
  type        = string
  default     = "Environments-42" # Test
  description = "Environment used by the Deploy Database template for approvals."
}

variable "github_connection_id" {
  type    = string
  default = "GitHubAppConnections-1"
}

# ---- Process template version masks ----

variable "process_template_version_masks" {
  type        = map(string)
  description = "Version mask for each process template, keyed by the process template slug."
  default = {
    "key-vault-retrieve-secrets"                            = "2.X"
    "deploy-process-verify-build-artifacts"                 = "2.X"
    "deploy-database"                                       = "2.X"
    "deploy-process-deploy-to-kubernetes-via-manifest"      = "2.X"
    "notification-emails"                                   = "1.X"
    "runbook-create-database-infrastructure"                = "1.X"
    "create-container-infrastructure"                       = "1.X"
    "runbook-destroy-container-infrastructure"              = "1.X"
    "runbook-destroy-database-infrastructure"               = "1.X"
    "runbook-run-adhoc-data-update-script"                  = "1.X"
    "runbook-restart-stuck-k8s-application"                 = "1.X"
  }
}
