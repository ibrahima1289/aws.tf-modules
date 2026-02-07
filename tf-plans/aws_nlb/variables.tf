# Plan Variables: pass-through to the NLB module
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
  description = "Subnet IDs for the NLB."
  type        = list(string)
}

variable "nlb_name" {
  description = "Name of the NLB (single mode)."
  type        = string
  default     = null
}

# Optional: define multiple NLBs with nested target groups and listeners.
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
      name                 = string
      port                 = number
      protocol             = string
      target_type          = optional(string)
      preserve_client_ip   = optional(bool)
      deregistration_delay = optional(number)
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
      port                         = number
      protocol                     = string
      ssl_policy                   = optional(string)
      certificate_arn              = optional(string)
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
  description = "Target groups registered behind the NLB."
  type = list(object({
    name                 = string
    port                 = number
    protocol             = string
    target_type          = optional(string)
    preserve_client_ip   = optional(bool)
    deregistration_delay = optional(number)
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
  }))
  default = []
}

variable "listeners" {
  description = "Listeners for the NLB."
  type = list(object({
    port                         = number
    protocol                     = string
    ssl_policy                   = optional(string)
    certificate_arn              = optional(string)
    default_forward_target_group = string
  }))
  default = []
}
