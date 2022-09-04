module "regional_http_load_balancer" {
  source = "./modules/lb"

  name     = "dummy-regional-http"
  scheme   = "EXTERNAL_MANAGED"
  mode     = "REGIONAL"
  protocol = "HTTP"
  region = "europe-west2"
  network = "default"

  frontends = {
    regional-http-f1 = {
      region = "europe-west2"
      ip_version = "IPV4"
      protocol   = "HTTP"
      network_tier = "STANDARD"
    },
    regional-http-f3 = {
      region = "europe-west2"
      ip_version = "IPV4"
      protocol   = "HTTPS"
      network_tier = "STANDARD"
      ssl = {
        certificate_id = "projects/ajpisco/regions/europe-west2/sslCertificates/cenas"
        private_key = file("example.com.key")
        certificate = file("example.com.csr")
      }
    },
  }

  # One backend should have default_backend as true which will route every non defined path to it
  # Type can be SERVICE (for MIGs) or BUCKET
  backends = {
    regional-http-b1 = {
      default_backend = true
      type            = "SERVICE"

      config = {
        protocol                        = "HTTP"
        target                          = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west2-c/instanceGroups/instance-group-3"
        port_name                       = "http"
        timeout_sec                     = 10
        connection_draining_timeout_sec = 300
        enable_cdn                      = false
        custom_request_headers          = []
        custom_response_headers         = []
        session_affinity                = "NONE"
        affinity_cookie_ttl_sec         = 0
        security_policy                 = ""
        balancing_mode                  = "UTILIZATION"
        capacity_scaler = 1.0
      }
    },
    regional-http-b2 = {
      default_backend = false
      type            = "SERVICE"

      config = {
        protocol       = "HTTP"
        target         = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west2-c/instanceGroups/instance-group-4"
        port_name      = "http"
        balancing_mode = "UTILIZATION"
        capacity_scaler = 1.0
      }
    },
  }
  url_maps = [
    {
      hosts = ["*", "anyot-her.host"]
      rules = [
        {
          path   = ["/hello"]
          target = "regional-http-b1"
        },
        {
          path   = ["/123.html"]
          target = "regional-http-b2"
        },
        {
          path   = ["/index.html"]
          target = "regional-http-b2"
        },
      ]
    },
  ]
}

output "regional_http_addresses" {
  value = module.regional_http_load_balancer.regional_addresses
}