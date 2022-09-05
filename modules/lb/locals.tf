locals {
  # Find the backend marked as default_backend
  default_backend = [for k, v in var.backends : k if v["default_backend"] == true]
  # Get the default backend type
  default_backend_type = var.backends[local.default_backend[0]].type
}