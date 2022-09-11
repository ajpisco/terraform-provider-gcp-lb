# module "regional_http_load_balancer" {
#   source = "./modules/lb"

#   project     = "dummy-regional-http"
#   scheme   = "EXTERNAL_MANAGED"
#   mode     = "REGIONAL"
#   protocol = "HTTPS"
#   region   = "europe-west1"
# #   network  = "default"

#   # Frontend
#   frontend_ip_version   = "IPV4"
#   frontend_network_tier = "STANDARD"
#   frontend_ssl = {
#     private_key        = file("example.com.key")
#     certificate        = file("example.com.csr")
#   }

#   # Backend
#   backend_type = "SERVICE"
#   backend_config = {
#     target = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west1-b/instanceGroups/instance-group-1"
#     protocol = "HTTP"
#     port_name = "http"
#   }
#   backend_health_check = {
#     port = 80
#   }
# }

# output "regional_http_addresses" {
#   value = module.regional_http_load_balancer.regional_addresses
# }