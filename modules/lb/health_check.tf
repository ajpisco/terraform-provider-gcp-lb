resource "google_compute_health_check" "default" {
  for_each = {
    for k, v in var.backends : k => v
    if(v.type == "SERVICE" && var.mode == "GLOBAL")
  }
  name  = "${var.name}-${each.key}-hc"

  check_interval_sec  = lookup(each.value.health_check, "check_interval_sec", 5)
  timeout_sec         = lookup(each.value.health_check, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 2)

  log_config {
    enable = false
  }

  dynamic "http_health_check" {
    for_each = contains(["HTTP","HTTP/2"], each.value.config.protocol) ? [each.value.health_check] : []
    content {
      port = coalesce(http_health_check.value.port, 80)
    }
  }

  dynamic "https_health_check" {
    for_each = contains(["HTTPS"], each.value.config.protocol) ? [each.value.health_check] : []
    content {
      port = coalesce(https_health_check.value.port, 443)
    }
  }

  dynamic "tcp_health_check" {
    for_each = contains(["TCP"], each.value.config.protocol) ? [each.value.health_check] : []
    content {
      port = coalesce(tcp_health_check.value.port, 80)
    }
  }
}

resource "google_compute_region_health_check" "default" {
  for_each = {
    for k, v in var.backends : k => v
    if(v.type == "SERVICE" && var.mode == "REGIONAL")
  }
  name  = "${var.name}-${each.key}-regional-hc"

  check_interval_sec  = lookup(each.value.health_check, "check_interval_sec", 5)
  timeout_sec         = lookup(each.value.health_check, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 2)
  region              = var.region

  log_config {
    enable = false
  }

  dynamic "http_health_check" {
    for_each = contains(["HTTP","HTTP/2"], each.value.config.protocol) ? [each.value.health_check] : []
    content {
      port = coalesce(http_health_check.value.port, 80)
    }
  }

  dynamic "https_health_check" {
    for_each = contains(["HTTPS"], each.value.config.protocol) ? [each.value.health_check] : []
    content {
      port = coalesce(https_health_check.value.port, 443)
    }
  }

  dynamic "tcp_health_check" {
    for_each = contains(["TCP"], each.value.config.protocol) ? [each.value.health_check] : []
    content {
      port = coalesce(tcp_health_check.value.port, 80)
    }
  }
}