# Global HTTP Load balancer

variable "global_http_frontends" {
  default = {
    global-f1 = {
      region = null
      # For GLOBAL LB ip_version can be IPV4 or IP6
      ip_version = "IPV4"
    },
    # global-f2 = {
    #   region        = null
    #   ip_version    = "IPV6"
    # }

  }
}

# One backend should have default_backend as true which will route every non defined path to it
# Type can be SERVICE (for MIGs) or BUCKET
variable "global_http_backends" {
  default = {
    global-b1 = {
      default_backend = true
      type            = "SERVICE"

      config = {
        protocol                        = "HTTP"
        target                          = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west1-b/instanceGroups/instance-group-1"
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
        max_rate                        = 1
        max_utilization                 = 0
      }
    },
    global-b2 = {
      default_backend = false
      type            = "SERVICE"

      config = {
        protocol       = "HTTP"
        target         = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west1-b/instanceGroups/instance-group-hostname"
        port_name      = "http"
        balancing_mode = "UTILIZATION"
      }
    },
    global-b3 = {
      default_backend = false
      type            = "BUCKET"
      config = {
        enable_cdn  = false
        bucket_name = "ajpisco-html"
      }

    },
  }
}

variable "url_maps" {
  default = [
    {
      hosts = ["*", "anyot-her.host"]
      rules = [
        {
          path   = ["/hello"]
          target = "global-b1"
        },
        {
          path   = ["/123.html"]
          target = "global-b2"
        },
        {
          path   = ["/index.html"]
          target = "global-b2"
        },
        {
          path   = ["/bucket.html"]
          target = "global-b3"
        },
      ]
    },
  ]
}

module "global_http_load_balancer" {
  source = "./modules/lb"

  name      = "dummy"
  scheme    = "EXTERNAL_MANAGED"
  mode      = "GLOBAL"
  frontends = var.global_http_frontends
  backends  = var.global_http_backends
  url_maps  = var.url_maps
}

output "frontends" {
  value = module.global_http_load_balancer.frontends
}
output "backends" {
  value = module.global_http_load_balancer.backends
}
output "test" {
  value = module.global_http_load_balancer.test
}