variable "project" {
  type        = string
  description = "Name to be used by the Load Balancer"
}

variable "mode" {
  type        = string
  description = "Load Balancer mode. Can be REGIONAL or GLOBAL"
  default = "GLOBAL"

  validation {
    condition = anytrue([
      var.mode == "REGIONAL",
      var.mode == "GLOBAL"
    ])
    error_message = "Mode is not REGIONAL or GLOBAL"
  }
}

variable "scheme" {
  type        = string
  description = "Scheme of the Load Balancer"
  default = "EXTERNAL_MANAGED"

  validation {
    condition = anytrue([
      var.scheme == "EXTERNAL",
      var.scheme == "EXTERNAL_MANAGED",
      var.scheme == "INTERNAL_SELF_MANAGED"
    ])
    error_message = "Scheme is not EXTERNAL, EXTERNAL_MANAGED or INTERNAL_SELF_MANAGED"
  }
}

variable "protocol" {
  type        = string
  description = "Protocol to be used by the Load Balancer. Can be HTTP, HTTPS or TCP"
  default = "HTTP"

  validation {
    condition = anytrue([
      var.protocol == "HTTP",
      var.protocol == "HTTPS",
      var.protocol == "TCP",
    ])
    error_message = "Load Balancer protocol should be one of: HTTP, HTTPS or TCP"
  }
}

variable "frontend_ip_version" {
  type        = string
  description = "The IP Version that will be used by this frontend address. Can be IPV4 or IPV6"
  default = "IPV4"
}

variable "frontend_network_tier" {
  type        = string
  description = "The networking tier used for configuring this address. Can be PREMIUM or STANDARD"
  default = "STANDARD"
}

variable "frontend_ssl" {
  description = "Certificate definition for HTTPS frontend"
  default = null
}

variable "backend_type" {
  type        = string
  description = "Type of backend. Can be SERVICE or BUCKET"
  default = "SERVICE"
}

variable "backend_config" {
  description = "Backend configuration details"
  default = {}
}

variable "backend_health_check" {
  description = "Backend health check configuration"
  default = null
}

variable "region" {
  type        = string
  description = "Region which regional resources will be deployed"
  default     = null
}

variable "network" {
  type        = string
  description = "Network which regional resources will be deployed"
  default     = null
}

variable "subnetwork" {
  type        = string
  description = "Subnetwork which regional resources will be deployed"
  default     = null
}