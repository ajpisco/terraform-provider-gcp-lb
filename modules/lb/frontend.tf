resource "google_compute_global_address" "global_address" {
  # Only create this resource if mode == GLOBAL and EXTERNAL
  count = (var.mode == "GLOBAL" && (var.scheme == "EXTERNAL" || var.scheme == "EXTERNAL_MANAGED")) ? 1 : 0

  name         = local.google_compute_global_address_name
  ip_version   = var.frontend_ip_version
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "global_rule" {
  # Only create this resource if mode == GLOBAL HTTP
  count = (var.mode == "GLOBAL" && (var.protocol == "HTTP" || var.protocol == "HTTPS")) ? 1 : 0

  name = local.google_compute_global_forwarding_rule_name

  target = google_compute_target_https_proxy.default[0].self_link

  ip_address = google_compute_global_address.global_address[0].address
  port_range = "443"
  load_balancing_scheme = var.scheme
}

resource "google_compute_address" "regional_address" {
  # Only create this resource if mode == REGIONAL
  count = (var.mode == "REGIONAL") ? 1 : 0

  name         = local.google_compute_address_name
  address_type = var.scheme == "INTERNAL_SELF_MANAGED" ? "INTERNAL" : "EXTERNAL"
  region       = var.region
  network_tier = var.scheme == "INTERNAL_SELF_MANAGED" ? null : var.frontend_network_tier
}

resource "google_compute_forwarding_rule" "rule" {
  # Only create this resource if HTTP REGIONAL or TCP
  count = (
    (
      var.mode == "REGIONAL" && 
      (var.protocol == "HTTP" || var.protocol == "HTTPS")
    ) || 
    var.protocol == "TCP"
    ) ? 1 : 0

  name = local.google_compute_forwarding_rule_name
  target = (
    var.mode == "REGIONAL" && (var.protocol == "HTTP" || var.protocol == "HTTPS")
    ) ? (
    google_compute_region_target_https_proxy.default[0].self_link
    ) : null
    
  ip_address  = google_compute_address.regional_address[0].address
  ip_protocol = var.protocol
  port_range = (
    (
      var.mode == "REGIONAL" && var.protocol == "HTTP"
    ) || 
    var.protocol == "TCP"
  ) ? (
    "80"
  ) : (
    "443"
  )
  load_balancing_scheme = var.scheme == "INTERNAL_SELF_MANAGED" ? "INTERNAL_MANAGED" : var.scheme
  region                = var.mode == "REGIONAL" ? var.region : null
  network               = can(var.network) ? var.network : data.google_compute_subnetwork.default[0].network
  subnetwork            = can(var.subnetwork) ? var.subnetwork : data.google_compute_subnetwork.default[0].id
  backend_service = (
    var.protocol == "TCP"
  ) ? google_compute_region_backend_service.region_backend_service[0].self_link : null
  network_tier = var.frontend_network_tier

}

resource "google_compute_target_https_proxy" "default" {
  # Only create this resource if frontend.protocol == HTTPS and GLOBAL
  count = ((var.protocol == "HTTP" || var.protocol == "HTTPS") && var.mode == "GLOBAL") ? 1 : 0

  name = local.google_compute_target_https_proxy_name
  url_map = (var.mode == "GLOBAL") ? (
    join("", google_compute_url_map.default.*.self_link)
    ) : (
    join("", google_compute_region_url_map.default.*.self_link)
  )

  ssl_certificates = compact(
    concat(
      can(local.frontend_ssl.certificate_id) ? [local.frontend_ssl.certificate_id] : [],
      can(local.frontend_ssl.private_key) && can(local.frontend_ssl.certificate) ? [google_compute_ssl_certificate.default[0].self_link] : [],
      can(local.frontend_ssl.domains) ? [google_compute_managed_ssl_certificate.default[0].self_link] : [],
    ),
  )
  ssl_policy    = local.frontend_ssl.ssl_policy
  quic_override = local.frontend_ssl.quic_override
}

resource "google_compute_region_target_https_proxy" "default" {
  # Only create this resource if frontend.protocol == HTTPS and REGIONAL
  count = ((var.protocol == "HTTP" || var.protocol == "HTTPS") && var.mode == "REGIONAL") ? 1 : 0

  name   = local.google_compute_region_target_https_proxy_name
  region = var.region
  url_map = (var.mode == "GLOBAL") ? (
    join("", google_compute_url_map.default.*.self_link)
    ) : (
    join("", google_compute_region_url_map.default.*.self_link)
  )

  ssl_certificates = compact(
    concat(
      # We can't use managed certificates here because Terraform doesn't support regional managed certificates. 
      # We must create certificate and pass its id or pass private_key and certificate
      can(local.frontend_ssl.certificate_id) ? [local.frontend_ssl.certificate_id] : [],
      can(local.frontend_ssl.private_key) && can(local.frontend_ssl.certificate) ? [google_compute_region_ssl_certificate.default[0].self_link] : [],
    ),
  )
}

resource "google_compute_ssl_certificate" "default" {
  # Only create this resource if frontend.protocol == HTTPS GLOBAL and the private_key and certificate were provided 
  count = (
    var.protocol == "HTTPS" && var.mode == "GLOBAL" &&
    (can(local.frontend_ssl.private_key) ? (coalesce(local.frontend_ssl.private_key, null) != null ? true : false) : false) &&
    (can(local.frontend_ssl.certificate) ? (coalesce(local.frontend_ssl.certificate, null) != null ? true : false) : false)
  ) ? 1 : 0

  name        = local.google_compute_ssl_certificate_name
  private_key = local.frontend_ssl.private_key
  certificate = local.frontend_ssl.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_ssl_certificate" "default" {
  # Only create this resource if frontend.protocol == HTTPS REGIONAL and the private_key and certificate were provided 
  count = (
    var.protocol == "HTTPS" && var.mode == "REGIONAL" &&
    (can(local.frontend_ssl.private_key) ? (coalesce(local.frontend_ssl.private_key, null) != null ? true : false) : false) &&
    (can(local.frontend_ssl.certificate) ? (coalesce(local.frontend_ssl.certificate, null) != null ? true : false) : false)
  ) ? 1 : 0

  name        = local.google_compute_region_ssl_certificate_name
  region      = var.region
  private_key = local.frontend_ssl.private_key
  certificate = local.frontend_ssl.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  # Only create this resource if frontend.protocol == HTTPS and domains were provided
  count = (
    (var.protocol == "HTTP" || var.protocol == "HTTPS") &&
    ((can(local.frontend_ssl.private_key) && can(local.frontend_ssl.certificate)) || can(local.frontend_ssl.certificate_id) ? false : true)
  ) ? 1 : 0

  name = local.google_compute_managed_ssl_certificate_name

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = local.frontend_ssl.domains
  }
}