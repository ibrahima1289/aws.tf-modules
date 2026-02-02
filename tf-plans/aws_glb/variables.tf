# Plan Variables: pass-through to the GWLB module
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
  description = "Subnet IDs for the GWLB."
  type        = list(string)
}

variable "glb_name" {
  description = "Name of the GWLB (single mode)."
  type        = string
  default     = null
}

# Optional: define multiple GWLBs with nested target groups and listeners.
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
      port                         = number
      protocol                     = string
      default_forward_target_group = string
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

variable "target_groups" {
  description = "Target groups registered behind the GWLB."
  type = list(object({
    name        = string
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
  }))
  default = []
}

variable "listeners" {
  description = "Listeners for the GWLB."
  type = list(object({
    port                         = number
    protocol                     = string
    default_forward_target_group = string
  }))
  default = []
}
