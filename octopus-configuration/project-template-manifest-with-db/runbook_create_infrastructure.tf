resource "octopusdeploy_runbook" "create_infrastructure" {
  project_id  = octopusdeploy_project.created_project.id
  name        = "Create Infrastructure"
  description = "**Action:** Create all the back-end infrastructure for this application.  Creates the namespace and database.\n\n**Affects:** The SQL Server and K8s hosting the application"

  multi_tenancy_mode = "Untenanted"
  environment_scope  = "All"

  connectivity_policy {
    allow_deployments_to_no_targets = local.runbook_connectivity.allow_deployments_to_no_targets
    exclude_unhealthy_targets       = local.runbook_connectivity.exclude_unhealthy_targets
    skip_machine_behavior           = local.runbook_connectivity.skip_machine_behavior
  }
}

resource "octopusdeploy_process" "create_infrastructure" {
  project_id = octopusdeploy_project.created_project.id
  runbook_id = octopusdeploy_runbook.create_infrastructure.id
}

resource "octopusdeploy_process_step" "create_infrastructure_key_vault" {
  process_id           = octopusdeploy_process.create_infrastructure.id
  name                 = "Key Vault"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.key_vault_properties
}

resource "octopusdeploy_process_step" "create_infrastructure_database" {
  process_id = octopusdeploy_process.create_infrastructure.id
  name       = "Create Database Infrastructure"
  type       = "Octopus.ProcessTemplate"

  execution_properties = merge(local.sql_properties, {
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "runbook-create-database-infrastructure"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["runbook-create-database-infrastructure"]
  })
}

resource "octopusdeploy_process_step" "create_infrastructure_container" {
  process_id = octopusdeploy_process.create_infrastructure.id
  name       = "Create Container Infrastructure"
  type       = "Octopus.ProcessTemplate"

  execution_properties = {
    "Template.Kubernetes.Namespace.Name"                   = "#{Standards.K8s.Namespace}"
    "Template.Kubernetes.TargetTags"                       = var.target_role
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "create-container-infrastructure"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["create-container-infrastructure"]
  }
}

resource "octopusdeploy_process_step" "create_infrastructure_secrets" {
  process_id           = octopusdeploy_process.create_infrastructure.id
  name                 = "Deploy Secrets"
  type                 = "Octopus.KubernetesDeployRawYaml"
  worker_pool_variable = "Core.Worker.Pool"

  properties = {
    "Octopus.Action.TargetRoles" = var.target_role
  }

  git_dependencies = {
    "" = {
      repository_uri       = var.manifest_git_repo_url
      default_branch       = var.git_branch
      git_credential_type  = "GitHub"
      github_connection_id = var.github_connection_id
      file_path_filters    = ["k8s/base/*-app-secrets.yaml"]
    }
  }

  execution_properties = {
    "Octopus.Action.RunOnServer"                                     = "true"
    "Octopus.Action.Script.ScriptSource"                             = "GitRepository"
    "Octopus.Action.GitRepository.Source"                            = "External"
    "Octopus.Action.Kubernetes.ResourceStatusCheck"                  = "True"
    "Octopus.Action.Kubernetes.DeploymentTimeout"                    = "180"
    "Octopus.Action.Kubernetes.ServerSideApply.Enabled"              = "True"
    "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts"       = "True"
    "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "k8s/base/*-app-secrets.yaml"
    "Octopus.Action.Package.JsonConfigurationVariablesTargets"       = "**/*.{yml,yaml}"
    "Octopus.Action.KubernetesContainers.Namespace"                  = "#{Standards.K8s.Namespace}"
  }
}

resource "octopusdeploy_process_step" "create_infrastructure_notify" {
  process_id           = octopusdeploy_process.create_infrastructure.id
  name                 = "Notify Team of Successful Completion"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.notify_properties
}

resource "octopusdeploy_process_steps_order" "create_infrastructure" {
  process_id = octopusdeploy_process.create_infrastructure.id
  steps = [
    octopusdeploy_process_step.create_infrastructure_key_vault.id,
    octopusdeploy_process_step.create_infrastructure_database.id,
    octopusdeploy_process_step.create_infrastructure_container.id,
    octopusdeploy_process_step.create_infrastructure_secrets.id,
    octopusdeploy_process_step.create_infrastructure_notify.id,
  ]
}
