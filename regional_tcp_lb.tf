module "global_TCP_load_balancer" {
  source = "./modules/lb"

  name     = "dummy-tcp"
  scheme   = "EXTERNAL"
  mode     = "REGIONAL"
  protocol = "TCP"
  region   = "europe-west2"

  frontends = {
    regional-tcp-f1 = {
      ip_version = "IPV4"
      protocol   = "TCP"
      region     = "europe-west2"
    },
  }
  backends = {
    regional-tcp-b1 = {
      default_backend = true
      type            = "SERVICE"

      config = {
        protocol                        = "TCP"
        target                          = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west2-c/instanceGroups/instance-group-2"
        port_name                       = "http"
        timeout_sec                     = 10
        connection_draining_timeout_sec = 300
        enable_cdn                      = false
        custom_request_headers          = []
        custom_response_headers         = []
        session_affinity                = "NONE"
        affinity_cookie_ttl_sec         = 0
        security_policy                 = ""
        balancing_mode                  = "CONNECTION"
      }
    },
  }
  url_maps = [
    {
      rules = [
        {
          target = "regional-tcp-b1"
        },
      ]
    },
  ]
}

output "regional_tcp_addresses" {
  value = module.global_TCP_load_balancer.regional_addresses
}