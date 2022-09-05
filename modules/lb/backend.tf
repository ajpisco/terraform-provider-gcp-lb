resource "google_compute_url_map" "default" {
  count = var.protocol == "HTTP" && var.mode == "GLOBAL" ? 1 : 0
  name  = "${var.name}-url-map"
  default_service = (local.default_backend_type == "SERVICE") ? (
    google_compute_backend_service.backend_service[local.default_backend[0]].self_link
    ) : (
    google_compute_backend_bucket.backend_bucket[local.default_backend[0]].self_link
  )

  dynamic "host_rule" {
    for_each = toset(var.url_maps)
    content {
      hosts = host_rule.value.hosts
      # replace all the special characters from hosts to create a unique path_matcher
      path_matcher = replace(join("", host_rule.value.hosts), "/[-.*]/", "a")
    }
  }

  dynamic "path_matcher" {
    for_each = toset(var.url_maps)
    content {

      name = replace(join("", path_matcher.value.hosts), "/[-.*]/", "a")
      default_service = (local.default_backend_type == "SERVICE") ? (
        var.mode == "GLOBAL" ? (
          google_compute_backend_service.backend_service[local.default_backend[0]].self_link
          ) : (
          google_compute_region_backend_service.region_backend_service[local.default_backend[0]].self_link
        )
        ) : (
        google_compute_backend_bucket.backend_bucket[local.default_backend[0]].self_link
      )

      dynamic "path_rule" {
        for_each = toset(path_matcher.value.rules)
        content {

          paths = path_rule.value.path
          service = (var.backends[path_rule.value.target].type == "SERVICE") ? (
            var.mode == "GLOBAL" ? (
              google_compute_backend_service.backend_service[path_rule.value.target].self_link
              ) : (
              google_compute_region_backend_service.region_backend_service[path_rule.value.target].self_link
            )
            ) : (
            google_compute_backend_bucket.backend_bucket[path_rule.value.target].self_link
          )

        }
      }
    }
  }
}

resource "google_compute_region_url_map" "default" {
  count  = var.protocol == "HTTP" && var.mode == "REGIONAL" ? 1 : 0
  name   = "${var.name}-region-url-map"
  region = var.region

  default_service = (local.default_backend_type == "SERVICE") ? (
    google_compute_region_backend_service.region_backend_service[local.default_backend[0]].self_link
    ) : (
    google_compute_backend_bucket.backend_bucket[local.default_backend[0]].self_link
  )

  dynamic "host_rule" {
    for_each = toset(var.url_maps)
    content {
      hosts = host_rule.value.hosts
      # replace all the special characters from hosts to create a unique path_matcher
      path_matcher = replace(join("", host_rule.value.hosts), "/[-.*]/", "a")
    }
  }

  dynamic "path_matcher" {
    for_each = toset(var.url_maps)
    content {

      name = replace(join("", path_matcher.value.hosts), "/[-.*]/", "a")
      default_service = (local.default_backend_type == "SERVICE") ? (
        google_compute_region_backend_service.region_backend_service[local.default_backend[0]].self_link
        ) : (
        google_compute_backend_bucket.backend_bucket[local.default_backend[0]].self_link
      )

      dynamic "path_rule" {
        for_each = toset(path_matcher.value.rules)
        content {

          paths = path_rule.value.path
          service = (var.backends[path_rule.value.target].type == "SERVICE") ? (
            google_compute_region_backend_service.region_backend_service[path_rule.value.target].self_link
            ) : (
            google_compute_backend_bucket.backend_bucket[path_rule.value.target].self_link
          )
        }
      }
    }
  }
}

resource "google_compute_backend_service" "backend_service" {
  for_each = {
    for k, v in var.backends : k => v
    if(v.type == "SERVICE" && var.mode == "GLOBAL")
  }

  name = "${var.name}-${each.key}-backend"

  port_name = each.value["config"]["port_name"]
  protocol  = each.value["config"]["protocol"]

  timeout_sec                     = lookup(each.value.config, "timeout_sec", 5)
  connection_draining_timeout_sec = lookup(each.value.config, "connection_draining_timeout_sec", 300)
  enable_cdn                      = lookup(each.value.config, "enable_cdn", false)
  custom_request_headers          = lookup(each.value.config, "custom_request_headers", null)
  custom_response_headers         = lookup(each.value.config, "custom_response_headers", null)
  health_checks                   = [google_compute_health_check.default[each.key].self_link]
  session_affinity                = lookup(each.value.config, "session_affinity", "NONE")
  affinity_cookie_ttl_sec         = lookup(each.value.config, "affinity_cookie_ttl_sec", 0)
  security_policy                 = lookup(each.value.config, "security_policy", "")
  load_balancing_scheme           = var.scheme

  backend {
    group = each.value["config"]["target"]

    balancing_mode               = lookup(each.value.config, "balancing_mode")
    capacity_scaler              = lookup(each.value.config, "capacity_scaler", 1)
    max_connections              = lookup(each.value.config, "max_connections", null)
    max_connections_per_instance = lookup(each.value.config, "max_connections_per_instance", null)
    max_connections_per_endpoint = lookup(each.value.config, "max_connections_per_endpoint", null)
    max_rate                     = lookup(each.value.config, "max_rate", null)
    max_rate_per_instance        = lookup(each.value.config, "max_rate_per_instance", null)
    max_rate_per_endpoint        = lookup(each.value.config, "max_rate_per_endpoint", null)
    max_utilization              = lookup(each.value.config, "max_utilization", 0)
  }

  log_config {
    enable      = true
    sample_rate = 1
  }
}

resource "google_compute_backend_bucket" "backend_bucket" {
  for_each = {
    for k, v in var.backends : k => v
    if(v.type == "BUCKET")
  }

  name = "${var.name}-${each.key}-backend"

  bucket_name = lookup(each.value.config, "bucket_name")
  enable_cdn  = lookup(each.value.config, "enable_cdn", false)

}

resource "google_compute_region_backend_service" "region_backend_service" {
  for_each = {
    for k, v in var.backends : k => v
    if(v.type == "SERVICE" && var.mode == "REGIONAL")
  }
  name   = "${var.name}-${each.key}-region-backend"
  region = var.region

  port_name = each.value["config"]["port_name"]
  protocol  = each.value["config"]["protocol"]

  timeout_sec                     = lookup(each.value.config, "timeout_sec", 5)
  connection_draining_timeout_sec = lookup(each.value.config, "connection_draining_timeout_sec", 300)
  enable_cdn                      = lookup(each.value.config, "enable_cdn", false)
  health_checks                   = [google_compute_region_health_check.default[each.key].self_link]
  session_affinity                = lookup(each.value.config, "session_affinity", "NONE")
  affinity_cookie_ttl_sec         = lookup(each.value.config, "affinity_cookie_ttl_sec", 0)
  load_balancing_scheme           = var.scheme == "INTERNAL_SELF_MANAGED" ? "INTERNAL_MANAGED" : var.scheme

  backend {
    group = each.value["config"]["target"]

    balancing_mode               = lookup(each.value.config, "balancing_mode")
    capacity_scaler              = lookup(each.value.config, "capacity_scaler", null)
    max_connections              = lookup(each.value.config, "max_connections", null)
    max_connections_per_instance = lookup(each.value.config, "max_connections_per_instance", null)
    max_connections_per_endpoint = lookup(each.value.config, "max_connections_per_endpoint", null)
    max_rate                     = lookup(each.value.config, "max_rate", null)
    max_rate_per_instance        = lookup(each.value.config, "max_rate_per_instance", null)
    max_rate_per_endpoint        = lookup(each.value.config, "max_rate_per_endpoint", null)
    max_utilization              = lookup(each.value.config, "max_utilization", null)
  }
}