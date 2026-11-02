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
    octopusdeploy_process_step.create_infrastructure_notify.id,
  ]
}
