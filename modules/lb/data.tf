data "google_project" "current_project" {
}

data "google_compute_subnetwork" "default" {
  count = can(var.subnetwork) ? 0 : 1
  name   = "default"
  region = var.region
}

data "google_dns_managed_zone" "dns_managed_zone" {
  count = can(var.frontend_ssl.domains) ? 0 : 1
  name = "${data.google_project.current_project.project_id}-zone"
}