# Simple HTTP Load balancer

module "simple_load_balancer" {
  source = "./modules/lb"

  project     = "simple"

  # Backend
  backend_type = "SERVICE"
  backend_config = {
    target = "https://www.googleapis.com/compute/v1/projects/ajpisco/zones/europe-west1-b/instanceGroups/instance-group-1"
  }
}

output "simple_addresses" {
  value = module.simple_load_balancer.global_addresses
}