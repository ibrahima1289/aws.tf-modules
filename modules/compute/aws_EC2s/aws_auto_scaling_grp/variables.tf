# Variables: configuration for the Auto Scaling Group (ASG) module
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

# Single-ASG (optional) inputs; use when not providing `asgs`
variable "asg_name" {
  description = "Name for the ASG (single mode)."
  type        = string
  default     = null
}

variable "subnets" {
  description = "List of subnet IDs for the ASG."
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "Minimum size of the ASG."
  type        = number
  default     = null
}

variable "max_size" {
  description = "Maximum size of the ASG."
  type        = number
  default     = null
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG (optional)."
  type        = number
  default     = null
}

variable "health_check_type" {
  description = "Type of health check: EC2 or ELB."
  type        = string
  default     = null
}

variable "health_check_grace_period" {
  description = "Seconds until health checks start for new instances."
  type        = number
  default     = null
}

variable "termination_policies" {
  description = "Termination policies order."
  type        = list(string)
  default     = []
}

variable "capacity_rebalance" {
  description = "Enable capacity rebalance to replace Spot instances proactively."
  type        = bool
  default     = true
}

variable "target_group_arns" {
  description = "Target group ARNs for ALB/NLB."
  type        = list(string)
  default     = []
}

variable "launch_template" {
  description = "Launch template to use for instances (single mode)."
  type = object({
    id      = string
    version = optional(string)
  })
  default = null
}

variable "mixed_instances_policy" {
  description = "Mixed instances policy configuration (single mode)."
  type = object({
    launch_template = object({
      id      = string
      version = optional(string)
    })
    instances_distribution = optional(object({
      on_demand_percentage_above_base_capacity = optional(number)
      on_demand_base_capacity                  = optional(number)
      spot_allocation_strategy                 = optional(string)
      spot_instance_pools                      = optional(number)
      spot_max_price                           = optional(string)
    }))
    overrides = optional(list(object({
      instance_type = string
    })))
  })
  default = null
}

# Optional lifecycle hooks (single-ASG mode)
variable "lifecycle_hooks" {
  description = "Optional lifecycle hooks for the single ASG."
  type = list(object({
    name                    = string
    lifecycle_transition    = string # e.g., "autoscaling:EC2_INSTANCE_LAUNCHING" or "autoscaling:EC2_INSTANCE_TERMINATING"
    notification_target_arn = optional(string)
    role_arn                = optional(string)
    default_result          = optional(string)
    heartbeat_timeout       = optional(number)
    notification_metadata   = optional(string)
  }))
  default = []
}

variable "scaling_policies" {
  description = "Optional scaling policies (single-ASG mode)."
  type = object({
    simple = optional(list(object({
      name               = string
      adjustment_type    = optional(string)
      scaling_adjustment = number
      cooldown           = optional(number)
    })))
    step = optional(list(object({
      name                       = string
      adjustment_type            = optional(string)
      metric_aggregation_type    = optional(string)
      estimated_instance_warmup  = optional(number)
      step_adjustments = list(object({
        scaling_adjustment            = number
        metric_interval_lower_bound   = optional(number)
        metric_interval_upper_bound   = optional(number)
      }))
      alarms = optional(list(object({
        name                = string
        comparison_operator = string
        evaluation_periods  = number
        metric_name         = string
        namespace           = string
        period              = number
        statistic           = optional(string)
        threshold           = number
        dimensions          = optional(map(string))
      })))
      alarm_arns = optional(list(string))
    })))
    target_tracking = optional(list(object({
      name              = string
      target_value      = number
      disable_scale_in  = optional(bool)
      predefined_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))
      customized_metric_specification = optional(object({
        metric_name = string
        namespace   = string
        statistic   = string
        unit        = optional(string)
        dimensions  = optional(list(object({
          name  = string
          value = string
        })))
      }))
    })))
    predictive = optional(list(object({
      name                         = string
      mode                         = optional(string)
      max_capacity_breach_behavior = optional(string)
      max_capacity_buffer          = optional(number)
      metric_specification = object({
        predefined_load_metric_specification = optional(object({
          predefined_load_metric_type = string
          resource_label              = optional(string)
        }))
        predefined_metric_pair_specification = optional(object({
          predefined_metric_type = string
          resource_label         = optional(string)
        }))
        predefined_scaling_metric_specification = optional(object({
          predefined_scaling_metric_type = string
          resource_label                 = optional(string)
        }))
        target_value = number
      })
    })))
  })
  default = null
}

# Optional: Create multiple ASGs by providing a list of definitions.
variable "asgs" {
  description = "Optional list of ASG configurations to create multiple auto scaling groups."
  type = list(object({
    name                  = string
    subnets               = list(string)
    min_size              = number
    max_size              = number
    desired_capacity      = optional(number)
    health_check_type     = optional(string)
    health_check_grace_period = optional(number)
    termination_policies  = optional(list(string))
    capacity_rebalance    = optional(bool)
    target_group_arns     = optional(list(string))
    launch_template = optional(object({
      id      = string
      version = optional(string)
    }))
    mixed_instances_policy = optional(object({
    lifecycle_hooks = optional(list(object({
      name                    = string
      lifecycle_transition    = string
      notification_target_arn = optional(string)
      role_arn                = optional(string)
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      notification_metadata   = optional(string)
    })))
      launch_template = object({
        id      = string
        version = optional(string)
      })
      instances_distribution = optional(object({
        on_demand_percentage_above_base_capacity = optional(number)
        on_demand_base_capacity                  = optional(number)
        spot_allocation_strategy                 = optional(string)
        spot_instance_pools                      = optional(number)
        spot_max_price                           = optional(string)
      }))
      overrides = optional(list(object({
        instance_type = string
      })))
    }))
    tags = optional(map(string))
    lifecycle_hooks = optional(list(object({
      name                    = string
      lifecycle_transition    = string
      notification_target_arn = optional(string)
      role_arn                = optional(string)
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      notification_metadata   = optional(string)
    })))
    scaling_policies = optional(object({
      simple = optional(list(object({
        name               = string
        adjustment_type    = optional(string)
        scaling_adjustment = number
        cooldown           = optional(number)
      })))
      step = optional(list(object({
        name                       = string
        adjustment_type            = optional(string)
        metric_aggregation_type    = optional(string)
        estimated_instance_warmup  = optional(number)
        step_adjustments = list(object({
          scaling_adjustment            = number
          metric_interval_lower_bound   = optional(number)
          metric_interval_upper_bound   = optional(number)
        }))
        alarms = optional(list(object({
          name                = string
          comparison_operator = string
          evaluation_periods  = number
          metric_name         = string
          namespace           = string
          period              = number
          statistic           = optional(string)
          threshold           = number
          dimensions          = optional(map(string))
        })))
        alarm_arns = optional(list(string))
      })))
      target_tracking = optional(list(object({
        name              = string
        target_value      = number
        disable_scale_in  = optional(bool)
        predefined_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = optional(string)
        }))
        customized_metric_specification = optional(object({
          metric_name = string
          namespace   = string
          statistic   = string
          unit        = optional(string)
          dimensions  = optional(list(object({
            name  = string
            value = string
          })))
        }))
      })))
      predictive = optional(list(object({
        name                         = string
        mode                         = optional(string)
        max_capacity_breach_behavior = optional(string)
        max_capacity_buffer          = optional(number)
        metric_specification = object({
          predefined_load_metric_specification = optional(object({
            predefined_load_metric_type = string
            resource_label              = optional(string)
          }))
          predefined_metric_pair_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          predefined_scaling_metric_specification = optional(object({
            predefined_scaling_metric_type = string
            resource_label                 = optional(string)
          }))
          target_value = number
        })
      })))
    }))
  }))
  default = []
}
