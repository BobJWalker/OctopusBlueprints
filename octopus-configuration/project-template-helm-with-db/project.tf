resource "octopusdeploy_project" "created_project" {
  name        = var.project_name 
  description = var.project_description

  project_group_id = var.project_group_id
  lifecycle_id     = var.lifecycle_id

  is_disabled                       = false
  tenanted_deployment_participation = "Untenanted"
  default_guided_failure_mode       = "EnvironmentDefault"
  auto_create_release               = false

  included_library_variable_sets = var.library_variable_set_ids
  project_tags                   = ["Requires Approval/Yes"]

  provisioning_runbook_id   = var.provisioning_runbook_id
  deprovisioning_runbook_id = var.deprovisioning_runbook_id

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.LastPatch}.i"
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
}
