# module "global_TCP_load_balancer" {
#   source = "./modules/lb"

#   project     = "dummy-tcp"
#   scheme   = "EXTERNAL"
#   mode     = "REGIONAL"
#   protocol = "TCP"
#   region   = "europe-west1"

#   # Frontend
#   frontend_ip_version   = "IPV4"
#   frontend_network_tier = "STANDARD"

#   # Backend
#   backend_type = "SERVICE"
#   backend_config = {
#     target = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west1-b/instanceGroups/instance-group-1"
#     protocol = "TCP"
#     port_name = "http"
#   }
#   backend_health_check = {
#     port = 80
#   }
# }

# output "regional_tcp_addresses" {
#   value = module.global_TCP_load_balancer.regional_addresses
# }