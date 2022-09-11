data "google_compute_subnetwork" "default" {
  count = can(var.subnetwork) ? 0 : 1
  name   = "default"
  region = var.region
}