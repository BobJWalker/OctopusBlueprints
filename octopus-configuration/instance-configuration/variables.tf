variable "octopus_address" {
    type = string
}

variable "octopus_api_key" {
    type = string
}

variable "octopus_space_id" {
    type = string
}

variable "default_lifecycle_id" {
  type        = string
  default     = "Lifecycles-1"
  description = "ID of the existing Default Lifecycle. Differs between instances (for example Lifecycles-1 or Lifecycles-383)."
}

variable "default_target_tags_tag_set_id" {
  type        = string
  default     = "TagSets-242"
  description = "ID of the existing Default Target Tags tag set. Differs between instances."
}