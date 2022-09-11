resource "google_compute_health_check" "default" {
  count = (var.backend_type == "SERVICE" && var.mode == "GLOBAL") ? 1 : 0

  name  = local.google_compute_health_check_name

  check_interval_sec  = local.backend_health_check.check_interval_sec
  timeout_sec         = local.backend_health_check.timeout_sec
  healthy_threshold   = local.backend_health_check.healthy_threshold
  unhealthy_threshold = local.backend_health_check.unhealthy_threshold

  log_config {
    enable = true
  }

  dynamic "http_health_check" {
    for_each = contains(["HTTP","HTTP/2"], local.backend_config.protocol) ? [local.backend_health_check] : []
    content {
      port = coalesce(http_health_check.value.port, 80)
    }
  }

  dynamic "https_health_check" {
    for_each = contains(["HTTPS"], local.backend_config.protocol) ? [local.backend_health_check] : []
    content {
      port = coalesce(https_health_check.value.port, 443)
    }
  }

  dynamic "tcp_health_check" {
    for_each = contains(["TCP"], local.backend_config.protocol) ? [local.backend_health_check] : []
    content {
      port = coalesce(tcp_health_check.value.port, 80)
    }
  }
}

resource "google_compute_region_health_check" "default" {
  count = (var.backend_type == "SERVICE" && var.mode == "REGIONAL") ? 1 : 0

  name  = local.google_compute_region_health_check_name

  check_interval_sec  = local.backend_health_check.check_interval_sec
  timeout_sec         = local.backend_health_check.timeout_sec
  healthy_threshold   = local.backend_health_check.healthy_threshold
  unhealthy_threshold = local.backend_health_check.unhealthy_threshold
  region              = var.region

  log_config {
    enable = true
  }

  dynamic "http_health_check" {
    for_each = contains(["HTTP","HTTP/2"], local.backend_config.protocol) ? [local.backend_health_check] : []
    content {
      port = coalesce(http_health_check.value.port, 80)
    }
  }

  dynamic "https_health_check" {
    for_each = contains(["HTTPS"], local.backend_config.protocol) ? [local.backend_health_check] : []
    content {
      port = coalesce(https_health_check.value.port, 443)
    }
  }

  dynamic "tcp_health_check" {
    for_each = contains(["TCP"], local.backend_config.protocol) ? [local.backend_health_check] : []
    content {
      port = coalesce(tcp_health_check.value.port, 80)
    }
  }
}