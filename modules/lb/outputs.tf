output "frontends" {
  value = var.frontends
}
output "backends" {
  value = var.backends
}

output "test" {
  value = var.backends[local.default_backend[0]].type
}
# output "bd_name" {
#   value = values(mso_schema_template_bd.bd).*.name
# }
