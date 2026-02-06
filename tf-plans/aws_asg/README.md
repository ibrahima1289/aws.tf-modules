# AWS Auto Scaling Group (ASG) Plan Wrapper

This plan wraps the ASG module to create one or more Auto Scaling Groups with safe defaults. Use `asgs` for multi-ASG or single variables for one ASG.

## Inputs
- `region`: AWS region
- `tags`: Common tags for all ASGs
- Single-ASG: `name`, `subnets`, `min_size`, `max_size`, `desired_capacity`, `health_check_type`, `health_check_grace_period`, `termination_policies`, `capacity_rebalance`, `target_group_arns`, `launch_template`, `mixed_instances_policy`, `lifecycle_hooks`
- Multi-ASG: `asgs` list with per-ASG entries mirroring single inputs (including optional `lifecycle_hooks`)

## Outputs
- `asg_names`, `asg_arns`, `asg_desired_capacities`, `asg_min_max_sizes`

## Example (Multi-ASG)
```hcl
provider "aws" {
  region = var.region
}

module "aws_asg" {
  source = "../../modules/compute/aws_EC2s/aws_auto_scaling_grp"

  asgs = [
    {
      key               = "web"
      name              = "web-asg"
      subnets           = ["subnet-123", "subnet-456"]
      min_size          = 2
      max_size          = 6
      desired_capacity  = 3
      health_check_type = "EC2"
      target_group_arns = ["arn:aws:elasticloadbalancing:...:targetgroup/web/abc"]
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
      key      = "api"
      name     = "api-asg"
      subnets  = ["subnet-789", "subnet-012"]
      min_size = 1
      max_size = 4
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
    }
  ]

  tags = {
    project = "my-app"
    env     = "dev"
  }
}
```
