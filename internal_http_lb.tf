# module "internal_http_load_balancer" {
#   source = "./modules/lb"

#   project     = "dummy-internal-http"
#   scheme   = "INTERNAL_SELF_MANAGED"
#   mode     = "REGIONAL"
#   protocol = "HTTP"
#   region     = "europe-west1"
# #   network    = "default"
# #   subnetwork = "default"

#   # Frontend
#   frontend_ip_version   = "IPV4"
#   frontend_network_tier = "PREMIUM"
# #   frontend_ssl = {
# #     domains        = ["example2.com"]
# #   }

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

# output "internal_http_addresses" {
#   value = module.internal_http_load_balancer.regional_addresses
# }