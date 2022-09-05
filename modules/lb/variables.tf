variable "name" {
  type        = string
  description = "Name to be used by the Load Balancer"
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
  description = "Scheme of the Load Balancer"

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

  validation {
    condition = alltrue([
      for f in var.frontends : contains(["HTTP", "HTTPS", "TCP"], f.protocol)
    ])
    error_message = "Frontends protocol should be one of: HTTP, HTTPS or TCP"
  }

  validation {
    condition = alltrue([
      for f in var.frontends : contains(["IPV4", "IPV6"], f.ip_version)
    ])
    error_message = "Frontends ip_version should be one of: IPV4 or IPV6"
  }

  validation {
    condition = alltrue([
      for f in var.frontends : (
        (
          can(f.ssl) &&
          f.protocol == "HTTPS" &&
          (
            can(f.ssl.certificate_id) ||
            can(f.ssl.domains) ||
            (can(f.ssl.private_key) && can(f.ssl.certificate))
          )
      ) || f.protocol != "HTTPS")
    ])
    error_message = "Frontends ssl configuration must be present for HTTPS protocol and should have either at least one of the following: certificate_id, domains list or private_key/certificate keys"
  }

  validation {
    condition = alltrue([
      for f in var.frontends : ((can(f.ssl) && f.protocol == "HTTPS") || f.protocol != "HTTPS")
    ])
    error_message = "Frontends ssl configuration must be present for HTTPS protocol"
  }

  validation {
    condition = alltrue([
      for f in var.frontends : (
        can(f.ssl.private_key) ?
        (
          (length(regexall("BEGIN PRIVATE KEY", f.ssl.private_key)) > 0)
        ) : true
      )
    ])
    error_message = "Frontend private key should have the BEGIN PRIVATE KEY statement"
  }

  validation {
    condition = alltrue([
      for f in var.frontends : (
        can(f.ssl.certificate) ?
        (
          (length(regexall("BEGIN CERTIFICATE", f.ssl.certificate)) > 0)
        ) : true
      )
    ])
    error_message = "Frontend certificate should have the BEGIN CERTIFICATE statement"
  }
}

variable "backends" {
  description = "Defines the structure of backends (multiple can be set)"

  validation {
    condition = alltrue([
      for b in var.backends : contains(["SERVICE", "BUCKET"], b.type)
    ])
    error_message = "Backends type should be one of: SERVICE or BUCKET"
  }

  validation {
    condition = anytrue([
      for b in var.backends : b.default_backend == true
    ])
    error_message = "At least one backend should have default_backend = true"
  }

  validation {
    condition = alltrue([
      for b in var.backends : (
        can(b.config) && b.type == "SERVICE" ?
        (
          (contains(["UTILIZATION", "RATE", "CONNECTION"], b.config.balancing_mode))
        ) : true
      )
    ])
    error_message = "Backends balancing_mode should be one of: UTILIZATION, RATE or CONNECTION"
  }

  validation {
    condition = alltrue([
      for b in var.backends : (
        can(b.config) && b.type == "SERVICE" ?
        (
          (contains(["HTTP", "HTTP/2", "HTTPS", "TCP"], b.config.protocol))
        ) : true
      )
    ])
    error_message = "Backends service protocol must be TCP, HTTP, HTTP/2 or HTTPS"
  }

  validation {
    condition = alltrue([
      for b in var.backends : (
        can(b.config) && b.type == "SERVICE" ?
        (
          (can(b.config.target))
        ) : true
      )
    ])
    error_message = "Service backend should have a config.target"
  }

  validation {
    condition = alltrue([
      for b in var.backends : (
        can(b.config) && b.type == "SERVICE" ?
        (
          (can(b.config.port_name))
        ) : true
      )
    ])
    error_message = "Service backend should have a config.port_name"
  }

  validation {
    condition = alltrue([
      for b in var.backends : (
        can(b.config) && b.type == "BUCKET" ?
        (
          (can(b.config.bucket_name))
        ) : true
      )
    ])
    error_message = "Bucket backend should have a config.bucket_name"
  }
}

variable "url_maps" {
  description = "Defines the url-paths to be used by the Load Balancer"

  validation {
    condition = alltrue([
      for u in var.url_maps : can(u.rules) ? alltrue(
        [for r in u.rules : can(r.target)]
      ) : false

    ])
    error_message = "All url_maps rules should have the target set"
  }
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