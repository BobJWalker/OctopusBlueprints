resource "octopusdeploy_variable" "sumologic_url" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "stringData:sumologicUrl"
  value    = "#{KeyVault.Sumologic.Url}"
}

resource "octopusdeploy_variable" "connection_string" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "stringData:connectionString"
  value    = "#{KeyVault.SQLServer.Connection.String}"
}

resource "octopusdeploy_variable" "open_feature_client_id" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "stringData:openFeatureClientId"
  value    = "#{Octopus.FeatureToggles.ClientIdentifier}"
}

# Kubernetes manifest substitutions
resource "octopusdeploy_variable" "spec_hostnames_0" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "spec:hostnames:0"
  value    = "#{Standards.K8s.HostName}"
}

resource "octopusdeploy_variable" "metadata_namespace" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "metadata:namespace"
  value    = "#{Standards.K8s.Namespace}"
}

resource "octopusdeploy_variable" "container_image" {
  owner_id = octopusdeploy_project.created_project.id
  type     = "String"
  name     = "spec:template:spec:containers:0:image"
  value    = "${var.container_package_id}:#{Octopus.Action[Deploy K8s Manifest-Deploy Container].Package[K8sTemplate.Container].PackageVersion}"
}

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
