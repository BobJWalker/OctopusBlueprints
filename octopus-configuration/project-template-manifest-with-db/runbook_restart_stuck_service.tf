resource "octopusdeploy_runbook" "restart_stuck_service" {
  project_id  = octopusdeploy_project.created_project.id
  name        = "Restart Stuck Service"
  description = "**Action:** Restarts a stuck service in a K8s cluster\n\n**Affects:** The application will be momentarily offline as the service restarts."

  multi_tenancy_mode = "Untenanted"
  environment_scope  = "All"

  connectivity_policy {
    allow_deployments_to_no_targets = local.runbook_connectivity.allow_deployments_to_no_targets
    exclude_unhealthy_targets       = local.runbook_connectivity.exclude_unhealthy_targets
    skip_machine_behavior           = local.runbook_connectivity.skip_machine_behavior
  }
}

resource "octopusdeploy_process" "restart_stuck_service" {
  project_id = octopusdeploy_project.created_project.id
  runbook_id = octopusdeploy_runbook.restart_stuck_service.id
}

resource "octopusdeploy_process_step" "restart_key_vault" {
  process_id           = octopusdeploy_process.restart_stuck_service.id
  name                 = "Key Vault"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.key_vault_properties
}

resource "octopusdeploy_process_step" "restart_service" {
  process_id = octopusdeploy_process.restart_stuck_service.id
  name       = "Restart Service"
  type       = "Octopus.ProcessTemplate"

  execution_properties = {
    "Template.Target.Tags"                                 = var.target_role
    "Template.Namespace.Name"                              = "#{Standards.K8s.Namespace}"
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "runbook-restart-stuck-k8s-application"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["runbook-restart-stuck-k8s-application"]
  }
}

resource "octopusdeploy_process_step" "restart_notify" {
  process_id           = octopusdeploy_process.restart_stuck_service.id
  name                 = "Notify Team of Restart"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.notify_properties
}

resource "octopusdeploy_process_steps_order" "restart_stuck_service" {
  process_id = octopusdeploy_process.restart_stuck_service.id
  steps = [
    octopusdeploy_process_step.restart_key_vault.id,
    octopusdeploy_process_step.restart_service.id,
    octopusdeploy_process_step.restart_notify.id,
  ]
}
