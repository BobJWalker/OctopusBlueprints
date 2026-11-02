# Prompted variable, only available to the "Run AdHoc Database Script" runbook
resource "octopusdeploy_variable" "script_to_run" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "Project.ScriptToRun.Text"

  prompt {
    label       = "SQL Script To Run"
    description = "Please enter the SQL Script you wish to run."
    is_required = true

    display_settings {
      control_type = "MultiLineText"
    }
  }

  scope {
    processes = [octopusdeploy_runbook.run_adhoc_database_script.id]
  }
}
