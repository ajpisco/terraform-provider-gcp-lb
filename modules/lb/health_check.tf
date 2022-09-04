resource "google_compute_health_check" "default" {
  count = var.mode == "GLOBAL" ? 1 : 0
  name = "${var.name}-hc"

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  log_config {
    enable = false
  }

  tcp_health_check {
    port = 80
  }
}

resource "google_compute_region_health_check" "default" {
  count = var.mode == "REGIONAL" ? 1 : 0
  name = "${var.name}-regional-hc"

  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
  region = var.region

  log_config {
    enable = false
  }

  tcp_health_check {
    port = 80
  }
}