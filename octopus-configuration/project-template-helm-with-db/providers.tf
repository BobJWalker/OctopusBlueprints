terraform {
  required_version = ">= 1.5.0"

  required_providers {
    octopusdeploy = {
      source  = "OctopusDeploy/octopusdeploy"
      version = ">= 1.0.0"
    }
  }
}

provider "octopusdeploy" {
  address  = var.octopus_server
  api_key  = var.octopus_api_key
  space_id = var.space_id
}
