# Variables: configuration for the ALB module
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

variable "lb_name" {
  description = "Name for the load balancer."
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs attached to the ALB."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type for the ALB (ipv4 or dualstack)."
  type        = string
  default     = "ipv4"
}

variable "enable_deletion_protection" {
  description = "Protect the ALB from accidental deletion."
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2 support."
  type        = bool
  default     = true
}

variable "drop_invalid_header_fields" {
  description = "Drop invalid HTTP headers at the ALB."
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "Idle timeout in seconds."
  type        = number
  default     = 60
}

variable "access_logs" {
  description = "S3 access logs configuration for the ALB."
  type = object({
    enabled = optional(bool)
    bucket  = optional(string)
    prefix  = optional(string)
  })
  default = {
    enabled = false
  }
}

# Optional: Create multiple ALBs by providing a list of definitions.
variable "albs" {
  description = "Optional list of ALB configurations to create multiple load balancers."
  type = list(object({
    name                       = string
    subnets                    = list(string)
    security_groups            = optional(list(string))
    internal                   = optional(bool)
    ip_address_type            = optional(string)
    enable_deletion_protection = optional(bool)
    enable_http2               = optional(bool)
    drop_invalid_header_fields = optional(bool)
    idle_timeout               = optional(number)
    access_logs = optional(object({
      enabled = optional(bool)
      bucket  = optional(string)
      prefix  = optional(string)
    }))
    tags = optional(map(string))
    target_groups = optional(list(object({
      name                 = string
      vpc_id               = string
      port                 = number
      protocol             = string
      target_type          = optional(string)
      deregistration_delay = optional(number)
      health_check = optional(object({
        enabled             = optional(bool)
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
      port                         = number
      protocol                     = string
      ssl_policy                   = optional(string)
      certificate_arn              = optional(string)
      default_forward_target_group = string
      additional_rules = optional(list(object({
        priority = number
        conditions = object({
          host_headers  = optional(list(string))
          path_patterns = optional(list(string))
        })
        action_forward_target_group = string
      })))
    })))
  }))
  default = []
}
