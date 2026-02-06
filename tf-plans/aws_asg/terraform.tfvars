region = "us-east-1" # AWS region for all resources

# Example: Multi-ASG configuration (define one or more ASGs)
asgs = [
  {
    key               = "web"                 # logical key for outputs
    name              = "web-asg"             # ASG name
    subnets           = ["subnet-123", "subnet-456"] # target subnets
    min_size          = 2                     # minimum instances
    max_size          = 6                     # maximum instances
    desired_capacity  = 3                     # initial desired count
    health_check_type = "EC2"                # EC2 or ELB
    termination_policies = ["OldestInstance", "ClosestToNextInstanceHour"] # instance termination order
    capacity_rebalance = true                 # proactively replace Spot
    target_group_arns = ["arn:aws:elasticloadbalancing:...:targetgroup/web/abc"] # attach to ALB/NLB
    launch_template = {
      id      = "lt-0123abcd"               # existing Launch Template ID
      version = "$Latest"                   # use latest version
    }
    lifecycle_hooks = [
      {
        name                 = "on-launch"   # hook identifier
        lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING" # trigger point
        default_result       = "CONTINUE"    # when timeout occurs
        heartbeat_timeout    = 300           # seconds until timeout
        notification_target_arn = "arn:aws:sns:us-east-1:123456789012:asg-events" # optional SNS
      }
    ]
  },
  {
    key      = "api"                        # logical key for outputs
    name     = "api-asg"                    # ASG name
    subnets  = ["subnet-789", "subnet-012"] # target subnets
    min_size = 1
    max_size = 4
    mixed_instances_policy = {
      launch_template = {
        id      = "lt-0feedbeef"            # base LT for mixed policy
        version = "$Latest"
      }
      instances_distribution = {
        on_demand_percentage_above_base_capacity = 50  # on-demand share
        spot_allocation_strategy                 = "lowest-price" # spot strategy
        spot_instance_pools                      = 2   # diversify spot pools
      }
      overrides = [
        { instance_type = "t3.micro" },      # additional instance types
        { instance_type = "t3.small" }
      ]
    }
    scaling_policies = {
      simple = [ # Simple Scaling: change capacity by fixed amount
        {
          name               = "scale-out-simple"
          adjustment_type    = "ChangeInCapacity"
          scaling_adjustment = 2
          cooldown           = 60
        }
      ]
      step = [   # Step Scaling: scale in steps based on metrics
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
              dimensions          = { AutoScalingGroupName = "api-asg" } # target ASG
            }
          ]
        }
      ]
      target_tracking = [ # Target Tracking: maintain target metric value
        {
          name         = "tt-cpu"
          target_value = 50
          predefined_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
          }
        }
      ]
      predictive = [ # Predictive Scaling: forecast & scale proactively
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

tags = { # common tags applied to all resources
  project = "my-app"
  env     = "dev"
}
