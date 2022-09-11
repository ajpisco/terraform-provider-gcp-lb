resource "google_compute_url_map" "default" {
  count = (var.protocol == "HTTP" || var.protocol == "HTTPS") && var.mode == "GLOBAL" ? 1 : 0

  name  = local.google_compute_url_map_name
  default_service = (var.backend_type == "SERVICE") ? (
      google_compute_backend_service.backend_service[0].self_link
    ) : (
      google_compute_backend_bucket.backend_bucket[0].self_link
    )
}

resource "google_compute_region_url_map" "default" {
  count  = (var.protocol == "HTTP" || var.protocol == "HTTPS") && var.mode == "REGIONAL" ? 1 : 0

  name   = local.google_compute_region_url_map_name
  region = var.region

  default_service = (var.backend_type == "SERVICE") ? (
    google_compute_region_backend_service.region_backend_service[0].self_link
    ) : (
    google_compute_backend_bucket.backend_bucket[0].self_link
  )
}

resource "google_compute_backend_service" "backend_service" {
  count = (var.backend_type == "SERVICE" && var.mode == "GLOBAL") ? 1 : 0

  name = local.google_compute_backend_service_name

  port_name = local.backend_config.port_name
  protocol  = local.backend_config.protocol

  timeout_sec                     = local.backend_config.timeout_sec
  connection_draining_timeout_sec = local.backend_config.connection_draining_timeout_sec
  enable_cdn                      = local.backend_config.enable_cdn
  custom_request_headers          = local.backend_config.custom_request_headers
  custom_response_headers         = local.backend_config.custom_response_headers
  health_checks                   = [google_compute_health_check.default[0].self_link]
  session_affinity                = local.backend_config.session_affinity
  affinity_cookie_ttl_sec         = local.backend_config.affinity_cookie_ttl_sec
  security_policy                 = local.backend_config.security_policy
  load_balancing_scheme           = var.scheme

  backend {
    group = local.backend_config.target

    balancing_mode               = local.backend_config.balancing_mode
    capacity_scaler              = local.backend_config.capacity_scaler
    max_connections              = local.backend_config.max_connections
    max_connections_per_instance = local.backend_config.max_connections_per_instance
    max_connections_per_endpoint = local.backend_config.max_connections_per_endpoint
    max_rate                     = local.backend_config.max_rate
    max_rate_per_instance        = local.backend_config.max_rate_per_instance
    max_rate_per_endpoint        = local.backend_config.max_rate_per_endpoint
    max_utilization              = local.backend_config.max_utilization
  }

  log_config {
    enable      = true
    sample_rate = 1
  }
}

resource "google_compute_backend_bucket" "backend_bucket" {
  count = (var.backend_type == "BUCKET") ? 1 : 0

  name = local.google_compute_backend_bucket_name

  bucket_name = local.backend_config.bucket_name
  enable_cdn  = local.backend_config.enable_cdn

}

resource "google_compute_region_backend_service" "region_backend_service" {
  count = (var.backend_type == "SERVICE" && var.mode == "REGIONAL") ? 1 : 0

  name   = local.google_compute_region_backend_service_name
  region = var.region

  port_name = local.backend_config.port_name
  protocol  = local.backend_config.protocol

  timeout_sec                     = local.backend_config.timeout_sec
  connection_draining_timeout_sec = local.backend_config.connection_draining_timeout_sec
  enable_cdn                      = local.backend_config.enable_cdn
  health_checks                   = [google_compute_region_health_check.default[0].self_link]
  session_affinity                = local.backend_config.session_affinity
  affinity_cookie_ttl_sec         = local.backend_config.affinity_cookie_ttl_sec
  load_balancing_scheme           = var.scheme == "INTERNAL_SELF_MANAGED" ? "INTERNAL_MANAGED" : var.scheme

  backend {
    group = local.backend_config.target

    balancing_mode               = var.protocol == "TCP" ? "CONNECTION" : local.backend_config.balancing_mode
    capacity_scaler              = var.protocol == "TCP" ? null : local.backend_config.capacity_scaler
    max_connections              = local.backend_config.max_connections
    max_connections_per_instance = local.backend_config.max_connections_per_instance
    max_connections_per_endpoint = local.backend_config.max_connections_per_endpoint
    max_rate                     = var.protocol == "TCP" ? null : local.backend_config.max_rate
    max_rate_per_instance        = local.backend_config.max_rate_per_instance
    max_rate_per_endpoint        = local.backend_config.max_rate_per_endpoint
    max_utilization              = local.backend_config.max_utilization
  }
}