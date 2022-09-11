# Global HTTP Load balancer

module "global_http_load_balancer" {
  source = "./modules/lb"

  project     = "global"
  scheme   = "EXTERNAL_MANAGED"
  mode     = "GLOBAL"
  protocol = "HTTPS"

  # Frontend
  frontend_ip_version   = "IPV4"
  frontend_network_tier = "STANDARD"
  frontend_ssl = {
    domains        = ["example2.com"]
  }

  # Backend
  backend_type = "SERVICE"
  backend_config = {
    target = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west1-b/instanceGroups/instance-group-1"
    protocol = "HTTPS"
    port_name = "https"
  }
  backend_health_check = {
    port = 443
  }
  # backend_type = "BUCKET"
  # backend_config = {
  #   bucket_name = "ajpisco-html"
  # }
}

output "global_http_addresses" {
  value = module.global_http_load_balancer.global_addresses
}