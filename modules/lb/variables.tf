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

variable "protocol" {
  type        = string
  description = "Protocol to be used by the Load Balancer. Can be HTTP or TCP"

  validation {
    condition = anytrue([
      var.protocol == "HTTP",
      var.protocol == "TCP",
    ])
    error_message = "Load Balancer protocol should be one of: HTTP or TCP"
  }
}

variable "frontends" {
  description = "Defines the structure of frontends (multiple can be set)"

  #   validation {
  #     condition = anytrue([
  #       var.frontends.*.protocol == "HTTP",
  #       var.frontends.*.protocol == "HTTPS",
  #       var.frontends.*.protocol == "TCP",
  #     ])
  #     error_message = "Frontends protocol should be one of: HTTP, HTTPS or TCP"
  #   }

  #   validation {
  #     condition = anytrue([
  #       for k in var.frontends : k.*.protocol == "HTTsP"
  #     ])
  #     error_message = "Load Balancer protocol should be one of: HTTP or TCP"
  #   }
}

variable "backends" {
  description = "Defines the structure of backends (multiple can be set)"
}

variable "url_maps" {
  type        = list(any)
  description = "Defines the url-paths to be used by the LB"
  default = []
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