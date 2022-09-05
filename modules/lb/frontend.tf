resource "google_compute_global_address" "global_address" {
  # Only create this resource if mode == GLOBAL and EXTERNAL
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "GLOBAL" && (var.scheme == "EXTERNAL" || var.scheme == "EXTERNAL_MANAGED"))
  }

  name         = "${var.name}-${each.key}-address"
  ip_version   = each.value["ip_version"]
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "global_rule" {
  # Only create this resource if mode == GLOBAL HTTP
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "GLOBAL" && var.protocol == "HTTP")
  }

  name = "${var.name}-${each.key}-rule"
  # If frontend protocol is HTTP, create http-proxy, otherwise create https-proxy
  target = (each.value.protocol == "HTTP") ? (
    google_compute_target_http_proxy.default[each.key].self_link
    ) : (
    google_compute_target_https_proxy.default[each.key].self_link
  )
  ip_address = google_compute_global_address.global_address[each.key].address
  port_range = (each.value.protocol == "HTTP") ? (
    "80"
    ) : (
    "443"
  )
  load_balancing_scheme = var.scheme
}

resource "google_compute_address" "regional_address" {
  # Only create this resource if mode == REGIONAL
  for_each = {
    for k, v in var.frontends : k => v
    if(var.mode == "REGIONAL")
  }
  name         = "${var.name}-${each.key}-regional-address"
  address_type = var.scheme == "INTERNAL_SELF_MANAGED" ? "INTERNAL" : "EXTERNAL"
  region       = each.value["region"]
  network_tier = var.scheme == "INTERNAL_SELF_MANAGED" ? null : lookup(each.value, "network_tier", "STANDARD")
}

resource "google_compute_forwarding_rule" "rule" {
  # Only create this resource if HTTP REGIONAL or TCP
  for_each = {
    for k, v in var.frontends : k => v
    if((var.mode == "REGIONAL" && var.protocol == "HTTP") || var.protocol == "TCP")
  }

  name = "${var.name}-${each.key}-rule"
  target = (
    var.mode == "REGIONAL" && var.protocol == "HTTP"
    ) ? (
    each.value.protocol == "HTTP" ? (
      google_compute_region_target_http_proxy.default[each.key].self_link
      ) : (
      google_compute_region_target_https_proxy.default[each.key].self_link
    )
  ) : null
  ip_address  = google_compute_address.regional_address[each.key].address
  ip_protocol = var.protocol
  port_range = ((var.mode == "REGIONAL" && each.value.protocol == "HTTP") || each.value.protocol == "TCP") ? (
    "80"
    ) : (
    "443"
  )
  load_balancing_scheme = var.scheme == "INTERNAL_SELF_MANAGED" ? "INTERNAL_MANAGED" : var.scheme
  region                = var.mode == "REGIONAL" ? var.region : null
  network               = var.mode == "REGIONAL" ? var.network : null
  subnetwork            = var.mode == "REGIONAL" ? var.subnetwork : null
  backend_service = (
    var.protocol == "TCP"
  ) ? google_compute_region_backend_service.region_backend_service[var.url_maps[0].rules[0].target].self_link : null
  network_tier = lookup(each.value, "network_tier", "STANDARD")

}

resource "google_compute_target_http_proxy" "default" {
  # Only create this resource if frontend.protocol == HTTP and GLOBAL
  for_each = {
    for k, v in var.frontends : k => v
    if(v.protocol == "HTTP" && var.mode == "GLOBAL")
  }

  name    = "${var.name}-${each.key}-http-proxy"
  url_map = join("", google_compute_url_map.default.*.self_link)
}

resource "google_compute_region_target_http_proxy" "default" {
  # Only create this resource if frontend.protocol == HTTP and REGIONAL
  for_each = {
    for k, v in var.frontends : k => v
    if(v.protocol == "HTTP" && var.mode == "REGIONAL")
  }

  name    = "${var.name}-${each.key}-region-http-proxy"
  region  = each.value["region"]
  url_map = join("", google_compute_region_url_map.default.*.self_link)
}

resource "google_compute_target_https_proxy" "default" {
  # Only create this resource if frontend.protocol == HTTPS and GLOBAL
  for_each = {
    for k, v in var.frontends : k => v
    if(v.protocol == "HTTPS" && var.mode == "GLOBAL")
  }

  name = "${var.name}-${each.key}-https-proxy"
  url_map = (var.mode == "GLOBAL") ? (
    join("", google_compute_url_map.default.*.self_link)
    ) : (
    join("", google_compute_region_url_map.default.*.self_link)
  )

  ssl_certificates = compact(
    concat(
      can(each.value.ssl.certificate_id) ? [each.value.ssl.certificate_id] : [],
      can(each.value.ssl.private_key) && can(each.value.ssl.certificate) ? [google_compute_ssl_certificate.default[each.key].self_link] : [],
      can(each.value.ssl.domains) ? [google_compute_managed_ssl_certificate.default[each.key].self_link] : [],
    ),
  )
  ssl_policy    = lookup(each.value.ssl, "ssl_policy", null)
  quic_override = lookup(each.value.ssl, "quic_override", "NONE")
}

resource "google_compute_region_target_https_proxy" "default" {
  # Only create this resource if frontend.protocol == HTTPS and REGIONAL
  for_each = {
    for k, v in var.frontends : k => v
    if(v.protocol == "HTTPS" && var.mode == "REGIONAL")
  }

  name   = "${var.name}-${each.key}-region-https-proxy"
  region = each.value["region"]
  url_map = (var.mode == "GLOBAL") ? (
    join("", google_compute_url_map.default.*.self_link)
    ) : (
    join("", google_compute_region_url_map.default.*.self_link)
  )

  ssl_certificates = compact(
    concat(
      can(each.value.ssl.certificate_id) ? [each.value.ssl.certificate_id] : [],
      can(each.value.ssl.private_key) && can(each.value.ssl.certificate) ? [google_compute_region_ssl_certificate.default[each.key].self_link] : [],
    ),
  )
}

resource "google_compute_ssl_certificate" "default" {
  # Only create this resource if frontend.protocol == HTTPS GLOBAL and the private_key and certificate were provided 
  for_each = {
    for k, v in var.frontends : k => v
    if(
      v.protocol == "HTTPS" && var.mode == "GLOBAL" &&
      (can(v.ssl.private_key) ? (coalesce(v.ssl.private_key, null) != null ? true : false) : false) &&
      (can(v.ssl.certificate) ? (coalesce(v.ssl.certificate, null) != null ? true : false) : false)
    )
  }

  name        = "${var.name}-${each.key}-cert"
  private_key = each.value.ssl.private_key
  certificate = each.value.ssl.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_ssl_certificate" "default" {
  # Only create this resource if frontend.protocol == HTTPS REGIONAL and the private_key and certificate were provided 
  for_each = {
    for k, v in var.frontends : k => v
    if(
      v.protocol == "HTTPS" && var.mode == "REGIONAL" &&
      (can(v.ssl.private_key) ? (coalesce(v.ssl.private_key, null) != null ? true : false) : false) &&
      (can(v.ssl.certificate) ? (coalesce(v.ssl.certificate, null) != null ? true : false) : false)
    )
  }

  name        = "${var.name}-${each.key}-cert"
  region      = each.value["region"]
  private_key = each.value.ssl.private_key
  certificate = each.value.ssl.certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  # Only create this resource if frontend.protocol == HTTPS and domains were provided
  for_each = {
    for k, v in var.frontends : k => v
    if(
      v.protocol == "HTTPS" &&
      (can(v.ssl.domains) ? (coalesce(v.ssl.domains, null) != null ? true : false) : false)
    )
  }
  name = "${var.name}-${each.key}-managed-cert"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = each.value.ssl.domains
  }
}