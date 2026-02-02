# Variables: configuration for the GWLB module
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

# Single-GLB (optional) inputs; use when not providing `glbs`
variable "glb_name" {
  description = "Name for the load balancer (single mode)."
  type        = string
  default     = null
}

variable "subnets" {
  description = "List of subnet IDs for the GWLB."
  type        = list(string)
  default     = []
}

variable "internal" {
  description = "Whether the GWLB is internal (true) or internet-facing (false)."
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Protect the GWLB from accidental deletion."
  type        = bool
  default     = true
}

variable "access_logs" {
  description = "S3 access logs configuration for the GWLB."
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
  description = "Target group definitions to register behind the GWLB."
  type = list(object({
    name        = string
    vpc_id      = string
    port        = number
    protocol    = string # GENEVE (typical 6081)
    target_type = optional(string) # instance | ip
    health_check = optional(object({
      enabled             = optional(bool)
      port                = optional(number)
      protocol            = optional(string) # TCP for GWLB
      interval            = optional(number)
      timeout             = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
    }))
    tags = optional(map(string))
  }))
  default = []
}

variable "listeners" {
  description = "Listener definitions for the GWLB (ports, protocols, default actions)."
  type = list(object({
    port            = number
    protocol        = string # GENEVE
    default_forward_target_group = string  # name of a target group defined above
  }))
  default = []
}

# Optional: Create multiple GWLBs by providing a list of definitions.
# If empty, the module will do nothing unless single-GLB inputs are supplied via the wrapper.
variable "glbs" {
  description = "Optional list of GWLB configurations to create multiple load balancers."
  type = list(object({
    name                       = string
    subnets                    = list(string)
    internal                   = optional(bool)
    enable_deletion_protection = optional(bool)
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
      health_check = optional(object({
        enabled             = optional(bool)
        port                = optional(number)
        protocol            = optional(string)
        interval            = optional(number)
        timeout             = optional(number)
        healthy_threshold   = optional(number)
        unhealthy_threshold = optional(number)
      }))
      tags = optional(map(string))
    })))
    listeners = optional(list(object({
      port            = number
      protocol        = string
      default_forward_target_group = string
    })))
  }))
  default = []
}
