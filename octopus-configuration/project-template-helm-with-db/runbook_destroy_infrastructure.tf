resource "octopusdeploy_runbook" "destroy_infrastructure" {
  project_id  = octopusdeploy_project.created_project.id
  name        = "Destroy Infrastructure"
  description = "**Action:** Destroy all the back-end infrastructure for this application.  Deletes the namespace and database.\n\n**Affects:** The SQL Server and K8s Hosting the Application"

  multi_tenancy_mode = "Untenanted"
  environment_scope  = "All"

  connectivity_policy {
    allow_deployments_to_no_targets = local.runbook_connectivity.allow_deployments_to_no_targets
    exclude_unhealthy_targets       = local.runbook_connectivity.exclude_unhealthy_targets
    skip_machine_behavior           = local.runbook_connectivity.skip_machine_behavior
  }
}

resource "octopusdeploy_process" "destroy_infrastructure" {
  project_id = octopusdeploy_project.created_project.id
  runbook_id = octopusdeploy_runbook.destroy_infrastructure.id
}

resource "octopusdeploy_process_step" "destroy_infrastructure_key_vault" {
  process_id = octopusdeploy_process.destroy_infrastructure.id
  name       = "Key Vault"
  type       = "Octopus.ProcessTemplate"

  # NOTE: the live instance sets Secrets.List to #{KeyVault.Azure.Name}, which looks
  # like a copy/paste slip (every other process uses #{KeyVault.Azure.Secrets.List}).
  # Replicated as-is; change it if that wasn't intentional.
  execution_properties = merge(local.key_vault_properties, {
    "KeyVault.Template.Secrets.List" = "#{KeyVault.Azure.Name}"
  })
}

resource "octopusdeploy_process_step" "destroy_infrastructure_k8s" {
  process_id = octopusdeploy_process.destroy_infrastructure.id
  name       = "Destroy K8s Infrastructure"
  type       = "Octopus.ProcessTemplate"

  execution_properties = {
    "Template.Kubernetes.Namespace.Name"                   = "#{Standards.K8s.Namespace}"
    "Template.Kubernetes.TargetTags"                       = var.target_role
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "runbook-destroy-container-infrastructure"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["runbook-destroy-container-infrastructure"]
  }
}

resource "octopusdeploy_process_step" "destroy_infrastructure_database" {
  process_id = octopusdeploy_process.destroy_infrastructure.id
  name       = "Destroy Database Infrastructure"
  type       = "Octopus.ProcessTemplate"

  execution_properties = merge(local.sql_properties, {
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "runbook-destroy-database-infrastructure"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["runbook-destroy-database-infrastructure"]
  })
}

resource "octopusdeploy_process_step" "destroy_infrastructure_notify" {
  process_id           = octopusdeploy_process.destroy_infrastructure.id
  name                 = "Notify Team of Runbook Status"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.notify_properties
}

resource "octopusdeploy_process_steps_order" "destroy_infrastructure" {
  process_id = octopusdeploy_process.destroy_infrastructure.id
  steps = [
    octopusdeploy_process_step.destroy_infrastructure_key_vault.id,
    octopusdeploy_process_step.destroy_infrastructure_k8s.id,
    octopusdeploy_process_step.destroy_infrastructure_database.id,
    octopusdeploy_process_step.destroy_infrastructure_notify.id,
  ]
}
