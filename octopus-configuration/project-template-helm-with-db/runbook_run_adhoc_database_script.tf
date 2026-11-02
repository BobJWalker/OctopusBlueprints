resource "octopusdeploy_runbook" "run_adhoc_database_script" {
  project_id  = octopusdeploy_project.created_project.id
  name        = "Run AdHoc Database Script"
  description = "**Action**: Allows users to run an ad-hoc script to fix any data funk within the application.  All scripts are verified before running by checking the number of rows effected and the SQL Statements.\n  \n**Affects**: The SQL Server this application is running on."

  multi_tenancy_mode = "Untenanted"
  environment_scope  = "All"

  connectivity_policy {
    allow_deployments_to_no_targets = local.runbook_connectivity.allow_deployments_to_no_targets
    exclude_unhealthy_targets       = local.runbook_connectivity.exclude_unhealthy_targets
    skip_machine_behavior           = local.runbook_connectivity.skip_machine_behavior
  }
}

resource "octopusdeploy_process" "run_adhoc_database_script" {
  project_id = octopusdeploy_project.created_project.id
  runbook_id = octopusdeploy_runbook.run_adhoc_database_script.id
}

resource "octopusdeploy_process_step" "adhoc_key_vault" {
  process_id           = octopusdeploy_process.run_adhoc_database_script.id
  name                 = "Key Vault"
  type                 = "Octopus.ProcessTemplate"
  execution_properties = local.key_vault_properties
}

resource "octopusdeploy_process_step" "adhoc_run_script" {
  process_id = octopusdeploy_process.run_adhoc_database_script.id
  name       = "Run AdHoc Data Update Script"
  type       = "Octopus.ProcessTemplate"

  execution_properties = merge(local.sql_properties, {
    "Template.ScriptToRun.Text"                            = "#{Project.ScriptToRun.Text}"
    "Octopus.Action.ProcessTemplate.Reference.Slug"        = "runbook-run-adhoc-data-update-script"
    "Octopus.Action.ProcessTemplate.Reference.VersionMask" = var.process_template_version_masks["runbook-run-adhoc-data-update-script"]
  })
}

resource "octopusdeploy_process_steps_order" "run_adhoc_database_script" {
  process_id = octopusdeploy_process.run_adhoc_database_script.id
  steps = [
    octopusdeploy_process_step.adhoc_key_vault.id,
    octopusdeploy_process_step.adhoc_run_script.id,
  ]
}
