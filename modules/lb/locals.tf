locals {
  # Find the backend marked as default_backend
  default_backend = [for k, v in var.backends : k if v["default_backend"] == true]
  # Get the default backend type
  default_backend_type = var.backends[local.default_backend[0]].type
  # Assign the service link to the variable
  default_service = (local.default_backend_type == "SERVICE") ? (
    google_compute_backend_service.backend_service[local.default_backend[0]].self_link
    ) : (
    google_compute_backend_bucket.backend_bucket[local.default_backend[0]].self_link
  )
}