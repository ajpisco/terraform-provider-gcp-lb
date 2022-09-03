resource "google_compute_health_check" "default" {
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