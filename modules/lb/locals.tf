locals {
  # Define resource names
  google_compute_global_address_name = "${var.project}-address"
  google_compute_global_forwarding_rule_name = "${var.project}-rule"
  google_compute_address_name = "${var.project}-regional-address"
  google_compute_forwarding_rule_name = "${var.project}-regional-rule"
  google_compute_target_http_proxy_name = "${var.project}-http-proxy"
  google_compute_region_target_http_proxy_name = "${var.project}-regional-http-proxy"
  google_compute_target_https_proxy_name = "${var.project}-https-proxy"
  google_compute_region_target_https_proxy_name = "${var.project}-regional-https-proxy"
  google_compute_ssl_certificate_name = "${var.project}-certificate"
  google_compute_region_ssl_certificate_name = "${var.project}-regional-certificate"
  google_compute_managed_ssl_certificate_name = "${var.project}-managed-certificate"
  google_compute_url_map_name = "${var.project}"
  google_compute_region_url_map_name = "${var.project}-regional-url-map"
  google_compute_backend_service_name = "${var.project}-backend-service"
  google_compute_backend_bucket_name = "${var.project}-backend-bucket"
  google_compute_region_backend_service_name = "${var.project}-regional-backend-service"
  google_compute_health_check_name = "${var.project}-healthcheck"
  google_compute_region_health_check_name = "${var.project}-regional-healthcheck"

  domains = can(var.frontend_ssl.domains) ? "" : data.google_dns_managed_zone.dns_managed_zone[0].dns_name
  frontend_ssl = merge(
    {
      domains = [local.domains]
      ssl_policy = null
      quic_override = "NONE"
    },
    var.frontend_ssl,
  )
  
  backend_config = merge(
    {
      bucket_name = null
      protocol = "HTTPS"
      port_name = "https"
      timeout_sec = 10
      connection_draining_timeout_sec = 300
      enable_cdn = false
      custom_request_headers = []
      custom_response_headers = []
      session_affinity = "NONE"
      affinity_cookie_ttl_sec = 0 
      security_policy = ""
      balancing_mode = "UTILIZATION"
      max_connections = null
      max_connections_per_instance = null
      max_connections_per_endpoint = null
      max_rate = 1
      max_rate_per_instance = null
      max_rate_per_endpoint = null
      max_utilization = 0
      capacity_scaler = 1.0

    },
    var.backend_config,
  )
  
  backend_health_check = merge(
    {
      port = 80
      check_interval_sec = 5
      timeout_sec = 5
      healthy_threshold = 2
      unhealthy_threshold = 2
    },
    var.backend_health_check,
  )
}