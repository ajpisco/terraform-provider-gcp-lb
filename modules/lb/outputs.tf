output "global_addresses" {
  value = google_compute_global_address.global_address
}

output "regional_addresses" {
  value = google_compute_address.regional_address
}