# Module: AWS Auto Scaling Group (ASG)
# - Creates ASGs with optional launch template or mixed instances policy
# - Applies safe defaults and avoids null values using guards and dynamic blocks

# Auto Scaling Group resource(s)
resource "aws_autoscaling_group" "asg" {
  # Create one ASG per entry in `asgs_map`
  for_each = local.asgs_map

  name                  = each.value.name
  vpc_zone_identifier   = each.value.subnets
  min_size              = each.value.min_size
  max_size              = each.value.max_size
  desired_capacity      = try(each.value.desired_capacity, null)

  # Health checks
  health_check_type         = try(each.value.health_check_type, null)
  health_check_grace_period = try(each.value.health_check_grace_period, null)

  # Balancing & termination
  capacity_rebalance   = try(each.value.capacity_rebalance, true)
  termination_policies = try(each.value.termination_policies, [])

  # Target groups (optional)
  target_group_arns = try(each.value.target_group_arns, [])

  # Launch Template (optional)
  dynamic "launch_template" {
    for_each = try(each.value.launch_template, null) != null ? [1] : []
    content {
      id      = each.value.launch_template.id
      version = try(each.value.launch_template.version, "$Latest")
    }
  }

  # Mixed Instances Policy (optional)
  dynamic "mixed_instances_policy" {
    for_each = try(each.value.mixed_instances_policy, null) != null ? [1] : []
    content {
      launch_template {
        launch_template_specification {
          launch_template_id = each.value.mixed_instances_policy.launch_template.id
          version            = try(each.value.mixed_instances_policy.launch_template.version, "$Latest")
        }

        # Instance type overrides (nested under launch_template)
        dynamic "override" {
          for_each = coalesce(try(each.value.mixed_instances_policy.overrides, []), [])
          content {
            instance_type = override.value.instance_type
          }
        }
      }

      dynamic "instances_distribution" {
        for_each = try(each.value.mixed_instances_policy.instances_distribution, null) != null ? [1] : []
        content {
          on_demand_percentage_above_base_capacity = try(each.value.mixed_instances_policy.instances_distribution.on_demand_percentage_above_base_capacity, null)
          on_demand_base_capacity                  = try(each.value.mixed_instances_policy.instances_distribution.on_demand_base_capacity, null)
          spot_allocation_strategy                 = try(each.value.mixed_instances_policy.instances_distribution.spot_allocation_strategy, null)
          spot_instance_pools                      = try(each.value.mixed_instances_policy.instances_distribution.spot_instance_pools, null)
          spot_max_price                           = try(each.value.mixed_instances_policy.instances_distribution.spot_max_price, null)
        }
      }
    }
  }

  # Tags using dynamic blocks; propagate to instances
  dynamic "tag" {
    for_each = [
      for k, v in merge(var.tags, try(each.value.tags, {}), {
        Name         = each.value.name,
        created_date = local.created_date
      }) : {
        key   = k,
        value = v
      }
    ]
    iterator = t
    content {
      key                 = t.value.key
      value               = t.value.value
      propagate_at_launch = true
    }
  }

  # Ensure rolling updates are safe (optional), ignored when not set
  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

# Optional lifecycle hooks per ASG
resource "aws_autoscaling_lifecycle_hook" "hook" {
  for_each = local.lifecycle_hooks_map

  name                   = each.value.hook_name
  autoscaling_group_name = aws_autoscaling_group.asg[each.value.asg_key].name
  lifecycle_transition   = each.value.lifecycle_transition
  default_result         = try(each.value.default_result, null)
  heartbeat_timeout      = try(each.value.heartbeat_timeout, null)
  notification_target_arn = try(each.value.notification_target_arn, null)
  role_arn               = try(each.value.role_arn, null)
  notification_metadata  = try(each.value.notification_metadata, null)
}

# Simple Scaling policies
resource "aws_autoscaling_policy" "simple" {
  for_each = local.simple_policies_map

  name                   = each.value.name
  autoscaling_group_name = aws_autoscaling_group.asg[each.value.asg_key].name
  policy_type            = "SimpleScaling"
  adjustment_type        = try(each.value.adjustment_type, null)
  scaling_adjustment     = each.value.scaling_adjustment
  cooldown               = try(each.value.cooldown, null)
}

# Step Scaling policies
resource "aws_autoscaling_policy" "step" {
  for_each = local.step_policies_map

  name                   = each.value.name
  autoscaling_group_name = aws_autoscaling_group.asg[each.value.asg_key].name
  policy_type            = "StepScaling"
  adjustment_type        = try(each.value.adjustment_type, null)
  metric_aggregation_type = try(each.value.metric_aggregation_type, null)
  estimated_instance_warmup = try(each.value.estimated_instance_warmup, null)

  dynamic "step_adjustment" {
    for_each = coalesce(try(each.value.step_adjustments, []), [])
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = try(step_adjustment.value.metric_interval_lower_bound, null)
      metric_interval_upper_bound = try(step_adjustment.value.metric_interval_upper_bound, null)
    }
  }
}

# Optional CloudWatch alarms for Step Scaling
resource "aws_cloudwatch_metric_alarm" "step_alarm" {
  for_each = local.step_alarms_map

  alarm_name          = each.value.name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = try(each.value.statistic, "Average")
  threshold           = each.value.threshold
  alarm_actions       = [aws_autoscaling_policy.step[each.value.policy_key].arn]

  dynamic "dimensions" {
    for_each = coalesce(try(each.value.dimensions, {}), {})
    iterator = d
    content {
      name  = d.key
      value = d.value
    }
  }
}

# Target Tracking Scaling policies
resource "aws_autoscaling_policy" "target_tracking" {
  for_each = local.target_tracking_policies_map

  name                   = each.value.name
  autoscaling_group_name = aws_autoscaling_group.asg[each.value.asg_key].name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value     = each.value.target_value
    disable_scale_in = try(each.value.disable_scale_in, null)

    dynamic "predefined_metric_specification" {
      for_each = try(each.value.predefined_metric_specification, null) != null ? [each.value.predefined_metric_specification] : []
      content {
        predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
        resource_label         = try(predefined_metric_specification.value.resource_label, null)
      }
    }

    dynamic "customized_metric_specification" {
      for_each = try(each.value.customized_metric_specification, null) != null ? [each.value.customized_metric_specification] : []
      content {
        metric_name = customized_metric_specification.value.metric_name
        namespace   = customized_metric_specification.value.namespace
        statistic   = customized_metric_specification.value.statistic
        unit        = try(customized_metric_specification.value.unit, null)

        dynamic "dimensions" {
          for_each = coalesce(try(customized_metric_specification.value.dimensions, []), [])
          content {
            name  = dimensions.value.name
            value = dimensions.value.value
          }
        }
      }
    }
  }
}

# Predictive Scaling policies
resource "aws_autoscaling_policy" "predictive" {
  for_each = local.predictive_policies_map

  name                   = each.value.name
  autoscaling_group_name = aws_autoscaling_group.asg[each.value.asg_key].name
  policy_type            = "PredictiveScaling"

  dynamic "predictive_scaling_configuration" {
    for_each = [1]
    content {
      mode                          = try(each.value.mode, null)
      max_capacity_breach_behavior  = try(each.value.max_capacity_breach_behavior, null)
      max_capacity_buffer           = try(each.value.max_capacity_buffer, null)

      metric_specification {
        target_value = each.value.metric_specification.target_value

        dynamic "predefined_load_metric_specification" {
          for_each = try(each.value.metric_specification.predefined_load_metric_specification, null) != null ? [each.value.metric_specification.predefined_load_metric_specification] : []
          content {
            predefined_metric_type = predefined_load_metric_specification.value.predefined_metric_type
            resource_label         = try(predefined_load_metric_specification.value.resource_label, null)
          }
        }

        dynamic "predefined_metric_pair_specification" {
          for_each = try(each.value.metric_specification.predefined_metric_pair_specification, null) != null ? [each.value.metric_specification.predefined_metric_pair_specification] : []
          content {
            predefined_metric_type = predefined_metric_pair_specification.value.predefined_metric_type
            resource_label         = try(predefined_metric_pair_specification.value.resource_label, null)
          }
        }

        dynamic "predefined_scaling_metric_specification" {
          for_each = try(each.value.metric_specification.predefined_scaling_metric_specification, null) != null ? [each.value.metric_specification.predefined_scaling_metric_specification] : []
          content {
            predefined_metric_type = predefined_scaling_metric_specification.value.predefined_metric_type
            resource_label         = try(predefined_scaling_metric_specification.value.resource_label, null)
          }
        }
      }
    }
  }
}
