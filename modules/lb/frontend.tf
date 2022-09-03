resource "google_compute_global_address" "global_address" {
  # Only create this resource if mode == GLOBAL
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "GLOBAL")
  }

  name         = "${var.name}-${each.key}-address"
  ip_version   = each.value["ip_version"]
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "global_rule" {
  # Only create this resource if mode == GLOBAL
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "GLOBAL")
  }

  name                  = "${var.name}-${each.key}-rule"
  target                = google_compute_target_http_proxy.default.self_link
  ip_address            = google_compute_global_address.global_address[each.key].address
  port_range            = "80"
  load_balancing_scheme = var.scheme
}

resource "google_compute_address" "regional_default" {
  # Only create this resource if mode == REGIONAL
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "REGIONAL")
  }
  name         = "test-address"
  address_type = "EXTERNAL"
  region       = each.value["region"]
}

resource "google_compute_forwarding_rule" "regional_rule" {
  # Only create this resource if mode == REGIONAL
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "REGIONAL")
  }

  name                  = "${var.name}-${each.key}-rule"
  target                = google_compute_target_http_proxy.default.self_link
  ip_address            = google_compute_global_address.global_address[each.key].address
  port_range            = "80"
  load_balancing_scheme = var.scheme
}