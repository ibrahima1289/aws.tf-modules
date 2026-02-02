# Variables: configuration for the NLB module
# Short comments explain each variable.

variable "region" {
  description = "AWS region for resources."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all resources."
  type        = map(string)
  default     = {}
}

# Single-NLB (optional) inputs; use when not providing `nlbs`
variable "nlb_name" {
  description = "Name for the load balancer (single mode)."
  type        = string
  default     = null
}

variable "subnets" {
  description = "List of subnet IDs for the NLB."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether the NLB is internal (true) or internet-facing (false)."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type for the NLB (ipv4 or dualstack)."
  type        = string
  default     = "ipv4"
}

variable "enable_deletion_protection" {
  description = "Protect the NLB from accidental deletion."
  type        = bool
  default     = true
}

variable "cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing."
  type        = bool
  default     = true
}

variable "access_logs" {
  description = "S3 access logs configuration for the NLB."
  type = object({
    enabled = optional(bool)
    bucket  = optional(string)
    prefix  = optional(string)
  })
  default = {
    enabled = false
  }
}

variable "target_groups" {
  description = "Target group definitions to register behind the NLB."
  type = list(object({
    name        = string
    vpc_id      = string
    port        = number
    protocol    = string # TCP | TLS | UDP | TCP_UDP
    target_type = optional(string) # instance | ip | lambda
    preserve_client_ip = optional(bool) # only valid for target_type = "ip"
    deregistration_delay = optional(number) # seconds
    health_check = optional(object({
      enabled             = optional(bool)
      port                = optional(number)
      protocol            = optional(string) # TCP | HTTP | HTTPS
      path                = optional(string) # only for HTTP/HTTPS
      interval            = optional(number)
      timeout             = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
      matcher             = optional(string) # only for HTTP/HTTPS
    }))
    stickiness = optional(object({
      enabled  = optional(bool)
      type     = optional(string) # "source_ip" for NLB TCP/UDP
      duration = optional(number) # seconds
    }))
    tags = optional(map(string))
  }))
  default = []
}

variable "listeners" {
  description = "Listener definitions for the NLB (ports, protocols, default actions)."
  type = list(object({
    port            = number
    protocol        = string # TCP | TLS | UDP | TCP_UDP
    ssl_policy      = optional(string)     # only for TLS
    certificate_arn = optional(string)     # required for TLS
    default_forward_target_group = string  # name of a target group defined above
  }))
  default = []
}

# Optional: Create multiple NLBs by providing a list of definitions.
# If empty, the module will do nothing unless single-NLB inputs are supplied via the wrapper.
variable "nlbs" {
  description = "Optional list of NLB configurations to create multiple load balancers."
  type = list(object({
    name                       = string
    subnets                    = list(string)
    internal                   = optional(bool)
    ip_address_type            = optional(string)
    enable_deletion_protection = optional(bool)
    cross_zone_load_balancing  = optional(bool)
    access_logs = optional(object({
      enabled = optional(bool)
      bucket  = optional(string)
      prefix  = optional(string)
    }))
    tags = optional(map(string))
    target_groups = optional(list(object({
      name        = string
      vpc_id      = string
      port        = number
      protocol    = string
      target_type = optional(string)
      preserve_client_ip    = optional(bool)
      deregistration_delay  = optional(number)
      health_check = optional(object({
        enabled             = optional(bool)
        port                = optional(number)
        protocol            = optional(string)
        path                = optional(string)
        interval            = optional(number)
        timeout             = optional(number)
        healthy_threshold   = optional(number)
        unhealthy_threshold = optional(number)
        matcher             = optional(string)
      }))
      stickiness = optional(object({
        enabled  = optional(bool)
        type     = optional(string)
        duration = optional(number)
      }))
      tags = optional(map(string))
    })))
    listeners = optional(list(object({
      port            = number
      protocol        = string
      ssl_policy      = optional(string)
      certificate_arn = optional(string)
      default_forward_target_group = string
    })))
  }))
  default = []
}
