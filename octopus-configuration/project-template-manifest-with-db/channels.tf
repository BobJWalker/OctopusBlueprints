locals {
  # Deployment actions / package references that the channel version rules apply to
  channel_action_packages = [
    {
      deployment_action = "Verify SBOM and Attestations-Attach and Verify SBOM"
      package_reference = "Template.SBOM.Artifact"
    },
    {
      deployment_action = "Deploy Database Changes-Build Delta Report and check for auto approval"
      package_reference = "Template.Database.Package"
    },
    {
      deployment_action = "Deploy Database Changes-Deploy Database Changes"
      package_reference = "Template.Database.Package"
    },
    {
      deployment_action = "Deploy K8s Manifest-Deploy Container"
      package_reference = "K8sTemplate.Container"
    },
  ]
}

# Branches: ephemeral environment channel for in-flight work (pre-release tags required)
resource "octopusdeploy_channel" "branches" {
  project_id  = octopusdeploy_project.created_project.id
  name        = "Branches"
  description = "This channel is for in-flight work that is not ready for production.\n- Packages and containers MUST have a pre-release tag (1.0.0-VerifyCustomer)\n- The release MUST be created from a branch"
  type        = "EphemeralEnvironment"
  is_default  = false

  parent_environment_id               = var.ephemeral_parent_environment_id
  ephemeral_environment_name_template = "#{Octopus.Release.CustomFields[BranchName]}"

  custom_field_definitions = [
    {
      field_name  = "BranchName"
      description = "The escaped branch name that comes from the build server, this will be the name of the ephemeral environment"
    },
  ]

  rule {
    tag           = "^[^\\+].*"
    version_range = ""

    dynamic "action_package" {
      for_each = local.channel_action_packages
      content {
        deployment_action = action_package.value.deployment_action
        package_reference = action_package.value.package_reference
      }
    }
  }

  depends_on = [
    octopusdeploy_process_steps_order.deployment,
  ]
}
