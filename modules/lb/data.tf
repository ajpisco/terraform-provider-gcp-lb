data "google_project" "current_project" {
}

data "google_compute_subnetwork" "public_subnet" {
  count = (can(var.subnetwork) || (var.scheme != "EXTERNAL_MANAGED" && var.scheme != "EXTERNAL")) ? 0 : 1
  name   = "${data.google_project.current_project.project_id}-public-subnet"
  region = var.region
}

data "google_compute_subnetwork" "private_subnet" {
  count = (can(var.subnetwork) || var.scheme != "INTERNAL_SELF_MANAGED") ? 0 : 1
  name   = "${data.google_project.current_project.project_id}-private-subnet"
  region = var.region
}

data "google_dns_managed_zone" "dns_managed_zone" {
  count = can(var.frontend_ssl.domains) ? 0 : 1
  name = "${data.google_project.current_project.project_id}-zone"
}