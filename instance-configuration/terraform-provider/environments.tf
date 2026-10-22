resource "octopusdeploy_environment" "development" {
  name                         = "Development"
  slug                         = "development"
  sort_order                   = 0
  use_guided_failure           = false
  allow_dynamic_infrastructure = true
  environment_tags             = ["Type/Non-Prod"]

  jira_extension_settings {
    environment_type = "development"
  }
}

resource "octopusdeploy_environment" "test" {
  name                         = "Test"
  slug                         = "test"
  sort_order                   = 1
  use_guided_failure           = false
  allow_dynamic_infrastructure = true
  environment_tags             = ["Type/Non-Prod"]

  jira_extension_settings {
    environment_type = "testing"
  }
}

resource "octopusdeploy_environment" "staging" {
  name                         = "Staging"
  slug                         = "staging"
  sort_order                   = 2
  use_guided_failure           = false
  allow_dynamic_infrastructure = true
  environment_tags             = ["Type/Non-Prod"]

  jira_extension_settings {
    environment_type = "staging"
  }
}

resource "octopusdeploy_environment" "production" {
  name                         = "Production"
  slug                         = "production"
  sort_order                   = 3
  use_guided_failure           = false
  allow_dynamic_infrastructure = true
  environment_tags             = ["Type/Production"]

  jira_extension_settings {
    environment_type = "production"
  }  
}

resource "octopusdeploy_environment" "production_blue" {
  name                         = "Production-Blue"
  slug                         = "production-blue"
  sort_order                   = 4
  use_guided_failure           = false
  allow_dynamic_infrastructure = true
  environment_tags             = ["Type/Production"]

  jira_extension_settings {
    environment_type = "production"
  }
}

resource "octopusdeploy_environment" "production_green" {
  name                         = "Production-Green"
  slug                         = "production-green"
  sort_order                   = 5
  use_guided_failure           = false
  allow_dynamic_infrastructure = true
  environment_tags             = ["Type/Production"]

  jira_extension_settings {
    environment_type = "production"
  }
}
