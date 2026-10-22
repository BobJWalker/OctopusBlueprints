resource "octopusdeploy_library_variable_set" "standards" {
  name        = "Standards"
  description = "A set of variables to establish consistent deployment standards for all deployments"

  template {
    name         = "Tenant.Common.Abbreviation"
    label        = "Common Abbreviation"
    default_value = ""
    display_settings = {
      "Octopus.ControlType" = "SingleLineText"
    }
  }
}

resource "octopusdeploy_variable" "standards_terraform_execution_container" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.Terraform.ExecutionContainer"
  type     = "String"
  value    = "octopuslabs/terraform-workertools:latest"
}

resource "octopusdeploy_variable" "standards_k8s_execution_container" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.K8s.ExecutionContainer"
  type     = "String"
  value    = "octopuslabs/k8s-workertools:1.36.2"
}

resource "octopusdeploy_variable" "standards_azure_execution_container" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.Azure.ExecutionContainer"
  type     = "String"
  value    = "octopuslabs/azure-workertools:2.88.0"
}

resource "octopusdeploy_variable" "standards_formatted_branch_name" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.Formatted.Branch.Name"
  type     = "String"
  value    = "#{if Octopus.Runbook.Id}#{Octopus.RunbookRun.Git.BranchName | Replace \"/\" \"-\" | ToLower | Replace \"refs-heads-\" \"\" | Replace \"feature\" \"\" | Replace \"hotfix\" \"\"}#{else}#{Octopus.Release.Git.BranchName | Replace \"/\" \"-\" | ToLower | Replace \"refs-heads-\" \"\" | Replace \"feature\" \"\" | Replace \"hotfix\" \"\" }#{/if}"
}

resource "octopusdeploy_variable" "standards_database_change_report_path" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.Database.ChangeReport.Path"
  type     = "String"
  value    = "../../#{Octopus.Project.Name}/#{Octopus.Release.Number}/#{Octopus.Environment.Name}"
}

resource "octopusdeploy_variable" "standards_application_name_prefix" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.ApplicationName.Prefix"
  type     = "String"
  value    = "#{Octopus.Project.Name | ToLower | Replace \" \" \"-\"}#{if Octopus.Deployment.Tenant.Name}#{Tenant.Common.Abbreviation | ToLower}#{if Octopus.Runbook.Tenant.Name}#{Tenant.Common.Abbreviation | ToLower}#{/if}#{/if}"
}

resource "octopusdeploy_variable" "standards_k8s_hostname" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.K8s.HostName"
  type     = "String"
  value    = "#{Standards.ApplicationName.Prefix}#{Octopus.Environment.Name | ToLower}.bobjwalker.local"
}

# Production-scoped override of Standards.K8s.HostName
resource "octopusdeploy_variable" "standards_k8s_hostname_production" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.K8s.HostName"
  type     = "String"
  value    = "#{Standards.ApplicationName.Prefix}.bobjwalker.local"

  scope {
    environments = [octopusdeploy_environment.production.id]
  }
}

resource "octopusdeploy_variable" "standards_k8s_namespace" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.K8s.Namespace"
  type     = "String"
  value    = "#{Standards.ApplicationName.Prefix}-#{Octopus.Environment.Name | ToLower }"
}

resource "octopusdeploy_variable" "standards_database_name" {
  owner_id = octopusdeploy_library_variable_set.standards.id
  name     = "Standards.Database.Name"
  type     = "String"
  value    = "#{Standards.ApplicationName.Prefix}-#{Octopus.Environment.Name | ToLower}"
}
