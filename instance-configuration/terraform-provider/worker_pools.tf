resource "octopusdeploy_static_worker_pool" "homelab_k8s" {
  name       = "Homelab K8s"
  is_default = true
  sort_order = 4
}
