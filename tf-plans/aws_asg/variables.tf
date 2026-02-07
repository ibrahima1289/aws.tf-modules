variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# Single-ASG inputs (optional when using multi-ASG)
variable "name" {
  type    = string
  default = null
}

variable "subnets" {
  type    = list(string)
  default = null
}

variable "min_size" {
  type    = number
  default = null
}

variable "max_size" {
  type    = number
  default = null
}

variable "desired_capacity" {
  type    = number
  default = null
}

variable "health_check_type" {
  type    = string
  default = null
}

variable "health_check_grace_period" {
  type    = number
  default = null
}

variable "termination_policies" {
  type    = list(string)
  default = []
}

variable "capacity_rebalance" {
  type    = bool
  default = null
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

# Launch template (optional)
variable "launch_template" {
  type = object({
    id      = string
    version = optional(string)
  })
  default = null
}

# Mixed instances policy (optional)
variable "mixed_instances_policy" {
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

variable "lifecycle_hooks" {
  description = "Optional lifecycle hooks for single-ASG mode."
  type = list(object({
    name                    = string
    lifecycle_transition    = string
    notification_target_arn = optional(string)
    role_arn                = optional(string)
    default_result          = optional(string)
    heartbeat_timeout       = optional(number)
    notification_metadata   = optional(string)
  }))
  default = []
}

variable "scaling_policies" {
  description = "Optional scaling policies for single-ASG mode."
  type = object({
    simple = optional(list(object({
      name               = string
      adjustment_type    = optional(string)
      scaling_adjustment = number
      cooldown           = optional(number)
    })))
    step = optional(list(object({
      name                      = string
      adjustment_type           = optional(string)
      metric_aggregation_type   = optional(string)
      estimated_instance_warmup = optional(number)
      step_adjustments = list(object({
        scaling_adjustment          = number
        metric_interval_lower_bound = optional(number)
        metric_interval_upper_bound = optional(number)
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
      name             = string
      target_value     = number
      disable_scale_in = optional(bool)
      predefined_metric_specification = optional(object({
        predefined_metric_type = string
        resource_label         = optional(string)
      }))
      customized_metric_specification = optional(object({
        metric_name = string
        namespace   = string
        statistic   = string
        unit        = optional(string)
        dimensions = optional(list(object({
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
# Multi-ASG list (recommended for multi)
variable "asgs" {
  description = "List of ASG definitions; each contains key and the single-ASG inputs"
  type = list(object({
    key                       = string
    name                      = string
    subnets                   = list(string)
    min_size                  = number
    max_size                  = number
    desired_capacity          = optional(number)
    health_check_type         = optional(string)
    health_check_grace_period = optional(number)
    termination_policies      = optional(list(string))
    capacity_rebalance        = optional(bool)
    target_group_arns         = optional(list(string))
    launch_template = optional(object({
      id      = string
      version = optional(string)
    }))
    mixed_instances_policy = optional(object({
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
        name                      = string
        adjustment_type           = optional(string)
        metric_aggregation_type   = optional(string)
        estimated_instance_warmup = optional(number)
        step_adjustments = list(object({
          scaling_adjustment          = number
          metric_interval_lower_bound = optional(number)
          metric_interval_upper_bound = optional(number)
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
        name             = string
        target_value     = number
        disable_scale_in = optional(bool)
        predefined_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = optional(string)
        }))
        customized_metric_specification = optional(object({
          metric_name = string
          namespace   = string
          statistic   = string
          unit        = optional(string)
          dimensions = optional(list(object({
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
