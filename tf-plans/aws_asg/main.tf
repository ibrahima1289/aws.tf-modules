module "aws_asg" {
  source = "../../modules/compute/aws_EC2s/aws_auto_scaling_grp"

  # Common
  tags   = var.tags
  region = var.region

  # Single-ASG passthrough (optional)
  subnets                   = try(var.subnets, null)
  min_size                  = try(var.min_size, null)
  max_size                  = try(var.max_size, null)
  desired_capacity          = try(var.desired_capacity, null)
  health_check_type         = try(var.health_check_type, null)
  health_check_grace_period = try(var.health_check_grace_period, null)
  termination_policies      = try(var.termination_policies, null)
  capacity_rebalance        = try(var.capacity_rebalance, null)
  target_group_arns         = try(var.target_group_arns, null)
  launch_template           = try(var.launch_template, null)
  mixed_instances_policy    = try(var.mixed_instances_policy, null)
  lifecycle_hooks           = try(var.lifecycle_hooks, null)
  scaling_policies          = try(var.scaling_policies, null)

  # Multi-ASG
  asgs = var.asgs
}
