# Plan Variables: pass-through to the ALB module
# Short comments annotate each input.

variable "region" {
  description = "AWS region for the plan."
  type        = string
}

variable "tags" {
  description = "Global tags for all resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID used by target groups."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "Security groups attached to the ALB."
  type        = list(string)
  default     = []
}

variable "lb_name" {
  description = "Name of the ALB."
  type        = string
  default     = "ALB"
}

# Optional: define multiple ALBs with nested target groups and listeners.
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

variable "access_logs" {
  description = "S3 access logs configuration."
  type = object({
    enabled = optional(bool)
    bucket  = optional(string)
    prefix  = optional(string)
  })
  default = {
    enabled = false
  }
}
