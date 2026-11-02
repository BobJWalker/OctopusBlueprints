locals {
  # Package parameters are passed to process templates as JSON strings
  sbom_package_json     = "{\"PackageId\":\"${var.sbom_package_id}\",\"FeedId\":\"${var.builtin_feed_id}\"}"
  database_package_json = "{\"PackageId\":\"${var.database_package_id}\",\"FeedId\":\"${var.builtin_feed_id}\"}"
  container_package_json = "{\"PackageId\":\"${var.container_package_id}\",\"FeedId\":\"${var.container_feed_id}\"}"
}

resource "octopusdeploy_process" "deployment" {
  project_id = octopusdeploy_project.created_project.id
}

# 1. Key Vault
resource "octopusdeploy_process_step" "key_vault" {
  process_id           = octopusdeploy_process.deployment.id
  name                 = "Key Vault"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.key_vault_properties
}

# 2. Verify SBOM and Attestations
resource "octopusdeploy_process_step" "verify_sbom" {
  process_id = octopusdeploy_process.deployment.id
  name       = "Verify SBOM and Attestations"
  type       = "Octopus.ProcessTemplate"

  packages = {
    "Template.SBOM.Artifact" = {
      package_id           = var.sbom_package_id
      feed_id              = var.builtin_feed_id
      acquisition_location = ""
      properties = {
        "PackageParameterName" = "Template.SBOM.Artifact"
        "SelectionMode"        = "immediate"
      }
    }
  }

  execution_properties = {
    "Template.Git.AuthToken"                               = "#{KeyVault.GitHub.Token}"
    "Template.Verify.WorkerPool"                           = "#{Core.Worker.Pool}"
    "Template.Verify.ExecutionContainerFeed"               = var.container_feed_id
    "Template.SBOM.Artifact"                               = local.sbom_package_json
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "deploy-process-verify-build-artifacts"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["deploy-process-verify-build-artifacts"]
  }
}

# 3. Deploy Database Changes
resource "octopusdeploy_process_step" "deploy_database" {
  process_id = octopusdeploy_process.deployment.id
  name       = "Deploy Database Changes"
  type       = "Octopus.ProcessTemplate"

  packages = {
    "Template.Database.Package" = {
      package_id           = var.database_package_id
      feed_id              = var.builtin_feed_id
      acquisition_location = ""
      properties = {
        "PackageParameterName" = "Template.Database.Package"
        "SelectionMode"        = "immediate"
      }
    }
  }

  execution_properties = {
    "Template.DbUp.Executable"                             = var.database_package_id
    "Template.Database.ConnectionString"                   = "#{KeyVault.SQLServer.Connection.String}"
    "Template.WorkerPool"                                  = "#{Core.Worker.Pool}"
    "Template.Approval.Environments"                       = var.approval_environment_id
    "Template.Database.Package"                            = local.database_package_json
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "deploy-database"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["deploy-database"]
  }
}

# 4. Deploy Application
resource "octopusdeploy_process_step" "deploy_application" {
  process_id = octopusdeploy_process.deployment.id
  name       = "Deploy Application"
  type       = "Octopus.ProcessTemplate"

  packages = {
    "K8sTemplate.Container" = {
      package_id           = var.container_package_id
      feed_id              = var.container_feed_id
      acquisition_location = ""
      properties = {
        "PackageParameterName" = "K8sTemplate.Container"
        "SelectionMode"        = "immediate"
      }
    }
  }

  execution_properties = {
    "K8sTemplate.Target.tag"                               = var.target_role
    "K8sTemplate.Git.Repo"                                 = var.manifest_git_repo_url
    "K8sTemplate.Namespace"                                = "#{Standards.K8s.Namespace}"
    "K8sTemplate.Helm.AdditionalArguments"                 = "--set trident.configurationFileName=utah"
    "K8sTemplate.SumoLogicUrl"                             = "#{KeyVault.Sumologic.Url}"
    "K8sTemplate.ConnectionString"                         = "#{KeyVault.SQLServer.Connection.String}"
    "K8sTemplate.Workerpool"                               = "#{Core.Worker.Pool}"
    "K8sTemplate.Container"                                = local.container_package_json
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "deploy-process-k8s-via-helm"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["deploy-process-k8s-via-helm"]
  }
}

# 5. Notify Team of Deployment Status
resource "octopusdeploy_process_step" "notify_team" {
  process_id           = octopusdeploy_process.deployment.id
  name                 = "Notify Team of Deployment Status"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.notify_properties
}

resource "octopusdeploy_process_steps_order" "deployment" {
  process_id = octopusdeploy_process.deployment.id
  steps = [
    octopusdeploy_process_step.key_vault.id,
    octopusdeploy_process_step.verify_sbom.id,
    octopusdeploy_process_step.deploy_database.id,
    octopusdeploy_process_step.deploy_application.id,
    octopusdeploy_process_step.notify_team.id,
  ]
}
