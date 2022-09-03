variable "name" {
  type        = string
  description = "Name to be used by the LB"
}

variable "mode" {
  type        = string
  description = "Load Balancer mode. Can be REGIONAL or GLOBAL"

  validation {
    condition = anytrue([
      var.mode == "REGIONAL",
      var.mode == "GLOBAL"
    ])
    error_message = "Mode is not REGIONAL or GLOBAL"
  }
}

# Scheme can be "EXTERNAL", "EXTERNAL_MANAGED" or "INTERNAL_SELF_MANAGED"
# EXTERNAL - External Global Load Balancing (HTTP(S) LB, External TCP/UDP LB, SSL Proxy)
# EXTERNAL_MANAGED - Global external HTTP(S) load balancers
# INTERNAL_SELF_MANAGED - Internal Global HTTP(S) LB
variable "scheme" {
  type        = string
  description = "scheme of the load balancer"

  validation {
    condition = anytrue([
      var.scheme == "EXTERNAL",
      var.scheme == "EXTERNAL_MANAGED",
      var.scheme == "INTERNAL_SELF_MANAGED"
    ])
    error_message = "Scheme is not EXTERNAL, EXTERNAL_MANAGED or INTERNAL_SELF_MANAGED"
  }
}

variable "frontends" {
  type        = map(any)
  description = "Defines the structure of frontends (multiple can be set)"
}

variable "backends" {
  description = "Defines the structure of backends (multiple can be set)"
}

variable "url_maps" {
  type        = list(any)
  description = "Defines the url-paths to be used by the LB"
}

variable "private_key" {
  type        = string
  description = "The write-only private key in PEM format"
  default     = null
}

variable "certificate" {
  type        = string
  description = "The certificate in PEM format"
  default     = null
}