import {
  to = octopusdeploy_lifecycle.default
  id = var.default_lifecycle_id
}

resource "octopusdeploy_lifecycle" "default" {
  name = "Default Lifecycle"

  phase {
    name                                  = "Development"
    automatic_deployment_targets          = [octopusdeploy_environment.development.id]
    minimum_environments_before_promotion = 0
  }
}

resource "octopusdeploy_lifecycle" "release_blue_green" {
  name = "Release Blue / Green"

  phase {
    name                         = "Test"
    automatic_deployment_targets = [octopusdeploy_environment.test.id]
  }

  phase {
    name = "Production"
    optional_deployment_targets = [
      octopusdeploy_environment.production_blue.id,
      octopusdeploy_environment.production_green.id,
    ]
    minimum_environments_before_promotion = 1
    is_priority_phase                     = true
  }
}

resource "octopusdeploy_lifecycle" "release_test_production" {
  name = "Release Test / Production"

  phase {
    name                         = "Test"
    automatic_deployment_targets = [octopusdeploy_environment.test.id]
  }

  phase {
    name                        = "Production"
    optional_deployment_targets = [octopusdeploy_environment.production.id]
    is_priority_phase           = true    
  }
}

resource "octopusdeploy_lifecycle" "release_test_staging_production" {
  name = "Release Test / Staging / Production"

  phase {
    name                         = "Test"
    automatic_deployment_targets = [octopusdeploy_environment.test.id]
  }

  phase {
    name                        = "Staging"
    optional_deployment_targets = [octopusdeploy_environment.staging.id]
  }

  phase {
    name                        = "Production"
    optional_deployment_targets = [octopusdeploy_environment.production.id]
    is_priority_phase           = true
  }
}
