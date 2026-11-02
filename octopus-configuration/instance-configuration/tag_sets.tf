import {
  to = octopusdeploy_tag_set.default_target_tags
  id = var.default_target_tags_tag_set_id
}

resource "octopusdeploy_tag_set" "default_target_tags" {
  name        = "Default Target Tags"
  description = "Default tag set for deployment target tags"
  scopes      = ["Target"]
  type        = "MultiSelect"  
}

resource "octopusdeploy_tag_set" "branch_type" {
  description = "Indicates if the branch for the tenant is a real edge location or a pseudo edge location."
  name        = "Branch Type"
  scopes      = ["Tenant"]
  type        = "SingleSelect"
}

resource "octopusdeploy_tag_set" "release_ring" {
  description = "Indicates the release ring for the tenant."
  name        = "Release Ring"
  scopes      = ["Tenant"]
  type        = "SingleSelect"
}

resource "octopusdeploy_tag_set" "time_zone" {
  description = "Indicates the time zone for the tenant."
  name        = "Time Zone"
  scopes      = ["Tenant"]
  type        = "SingleSelect"
}

resource "octopusdeploy_tag_set" "environment_type" {
  description = "Indicates if the environment is a production or non-production."
  name       = "Environment Type"  
  scopes      = ["Environment"]
  type        = "SingleSelect"
}

resource "octopusdeploy_tag_set" "requires_approval" {
  description = "Indicates if the project requires approval"
  name       = "Requires Approval"
  scopes     = ["Project"]
  type       = "SingleSelect"
}

locals {
  tags = {
    "branch_type_pseudo"       = { tag_set = octopusdeploy_tag_set.branch_type.id, name = "Pseudo", color = "#77B7C5", sort_order = 2 }
    "branch_type_physical"     = { tag_set = octopusdeploy_tag_set.branch_type.id, name = "Physical", color = "#333333", sort_order = 3 }

    "release_ring_edge"           = { tag_set = octopusdeploy_tag_set.release_ring.id, name = "Edge", color = "#E8634F", sort_order = 2 }
    "release_ring_early_adopters" = { tag_set = octopusdeploy_tag_set.release_ring.id, name = "Early Adopters", color = "#ECAD3F", sort_order = 3 }
    "release_ring_stable"         = { tag_set = octopusdeploy_tag_set.release_ring.id, name = "Stable", color = "#36A766", sort_order = 4 }

    "time_zone_eastern"  = { tag_set = octopusdeploy_tag_set.time_zone.id, name = "Eastern", color = "#B9B9B9", sort_order = 2 }
    "time_zone_central"  = { tag_set = octopusdeploy_tag_set.time_zone.id, name = "Central", color = "#333333", sort_order = 3 }
    "time_zone_mountain" = { tag_set = octopusdeploy_tag_set.time_zone.id, name = "Mountain", color = "#B8E7D3", sort_order = 4 }    
    
    "environment_type_production" = { tag_set = octopusdeploy_tag_set.environment_type.id, name = "Production", color = "#FF0000", sort_order = 2 }
    "environment_type_non_prod"   = { tag_set = octopusdeploy_tag_set.environment_type.id, name = "Non-Prod", color = "#009900", sort_order = 3 }

    "requires_approval_yes" = { tag_set = octopusdeploy_tag_set.requires_approval.id, name = "Yes", color = "#FF0000", sort_order = 2 }
    "requires_approval_no"  = { tag_set = octopusdeploy_tag_set.requires_approval.id, name = "No", color = "#00FF00", sort_order = 3 }

    "target_argocd_managed"        = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "argocd-managed", color = "#333333", sort_order = 0 }
    "target_eks"                   = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "EKS", color = "#333333", sort_order = 1 }
    "target_petclinic_tenanted"    = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "petclinic-tenanted", color = "#333333", sort_order = 2 }
    "target_trident_heritage"      = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "trident-heritage", color = "#333333", sort_order = 3 }
    "target_trident_web"           = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "trident-web", color = "#333333", sort_order = 4 }
    "target_hello_containers"      = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "hello-containers", color = "#333333", sort_order = 0 }
    "target_traditional_paas_app"  = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "traditional-paas-app", color = "#333333", sort_order = 0 }
    "target_spear_web"             = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "spear-web", color = "#333333", sort_order = 0 }
    "target_hello_containers_web"  = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "hello-containers-web", color = "#333333", sort_order = 0 }
    "target_k8s_infrastructure"    = { tag_set = octopusdeploy_tag_set.default_target_tags.id, name = "k8s-infrastructure", color = "#333333", sort_order = 9 }    
  }
}

resource "octopusdeploy_tag" "tags" {
  for_each = local.tags

  name       = each.value.name
  color      = each.value.color
  sort_order = each.value.sort_order
  tag_set_id = each.value.tag_set
}
