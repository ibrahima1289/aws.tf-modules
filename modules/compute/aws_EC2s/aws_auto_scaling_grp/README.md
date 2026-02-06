# AWS Auto Scaling Group (ASG) Module

This module creates one or more AWS Auto Scaling Groups (ASGs) with safe defaults. It supports both Launch Templates and Mixed Instances Policy, optional target group attachments, health checks, and capacity rebalance.

## Features
- Multi-ASG via `asgs` with per-ASG config
- Supports Launch Template or Mixed Instances Policy
- Health checks, termination policies, capacity rebalance
- Optional `target_group_arns` attachments
- Propagated tags with `created_date`
- Optional lifecycle hooks per ASG
- Optional scaling policies: Simple, Step, Target Tracking, Predictive

## Inputs
Refer to `variables.tf` for full schema. Key inputs:
- Single ASG: `name`, `subnets`, `min_size`, `max_size`, `desired_capacity`, `health_check_type`, `health_check_grace_period`, `termination_policies`, `capacity_rebalance`, `target_group_arns`, `launch_template`, `mixed_instances_policy`.
- Multi-ASG: `asgs` list. Each entry mirrors the single ASG schema.
- Common: `tags` map applied to all resources.

## Outputs
- `asg_names`: Map of ASG names
- `asg_arns`: Map of ASG ARNs
- `asg_desired_capacities`: Map of desired capacities
- `asg_min_max_sizes`: Map of min/max sizes

## Example (Multi-ASG)
```hcl
module "asgs" {
  source = "../../modules/compute/aws_EC2s/aws_auto_scaling_grp"

  asgs = [
    {
      key                 = "web"
      name                = "web-asg"
      subnets             = ["subnet-123", "subnet-456"]
      min_size            = 2
      max_size            = 6
      desired_capacity    = 3
      health_check_type   = "EC2"
      termination_policies = ["OldestInstance", "ClosestToNextInstanceHour"]
      capacity_rebalance  = true
      target_group_arns   = ["arn:aws:elasticloadbalancing:...:targetgroup/web/abc"]
      launch_template = {
        id      = "lt-0123abcd"
        version = "$Latest"
      }
      lifecycle_hooks = [
        {
          name                 = "on-launch"
          lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
          default_result       = "CONTINUE"
          heartbeat_timeout    = 300
          notification_target_arn = "arn:aws:sns:us-east-1:123456789012:asg-events"
        }
      ]
    },
    {
      key              = "api"
      name             = "api-asg"
      subnets          = ["subnet-789", "subnet-012"]
      min_size         = 1
      max_size         = 4
      mixed_instances_policy = {
        launch_template = {
          id      = "lt-0feedbeef"
          version = "$Latest"
        }
        instances_distribution = {
          on_demand_percentage_above_base_capacity = 50
          spot_allocation_strategy                 = "lowest-price"
          spot_instance_pools                      = 2
        }
        overrides = [
          { instance_type = "t3.micro" },
          { instance_type = "t3.small" }
        ]
      }
      lifecycle_hooks = [
        {
          name                 = "on-terminate"
          lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
          default_result       = "ABANDON"
        }
      ]
        scaling_policies = {
          simple = [
            {
              name               = "scale-out-simple"
              adjustment_type    = "ChangeInCapacity"
              scaling_adjustment = 2
              cooldown           = 60
            }
          ]
          step = [
            {
              name                      = "scale-out-step"
              adjustment_type           = "PercentChangeInCapacity"
              metric_aggregation_type   = "Average"
              estimated_instance_warmup = 120
              step_adjustments = [
                { scaling_adjustment = 10, metric_interval_lower_bound = 0 },
                { scaling_adjustment = 20, metric_interval_lower_bound = 50 }
              ]
              alarms = [
                {
                  name                = "cpu-high"
                  comparison_operator = "GreaterThanOrEqualToThreshold"
                  evaluation_periods  = 2
                  metric_name         = "CPUUtilization"
                  namespace           = "AWS/EC2"
                  period              = 60
                  statistic           = "Average"
                  threshold           = 70
                  dimensions          = { AutoScalingGroupName = "api-asg" }
                }
              ]
            }
          ]
          target_tracking = [
            {
              name         = "tt-cpu"
              target_value = 50
              predefined_metric_specification = {
                predefined_metric_type = "ASGAverageCPUUtilization"
              }
            }
          ]
          predictive = [
            {
              name = "predictive-scale"
              mode = "ForecastAndScale"
              metric_specification = {
                target_value = 50
                predefined_scaling_metric_specification = {
                  predefined_scaling_metric_type = "ASGAverageCPUUtilization"
                }
              }
            }
          ]
        }
    }
  ]

  tags = {
    project = "my-app"
    env     = "dev"
  }
}
```

## Notes
- If both `launch_template` and `mixed_instances_policy` are provided, the module will configure both blocks, but AWS expects only one strategy per ASG. Provide only one to avoid conflicts.
- `desired_capacity` is ignored by lifecycle changes during drift to reduce noisy updates.
 - Lifecycle hooks are optional; provide `lifecycle_hooks` in each ASG entry with `name` and `lifecycle_transition`. Other fields are optional.
 - Scaling policies are optional; you can mix and match types per ASG. Step scaling can create CloudWatch alarms when provided in `alarms`, or you can reference existing `alarm_arns`.
