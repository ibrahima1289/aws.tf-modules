# Locals: central metadata
# - created_date: YYYY-MM-DD used for tagging across resources
# - asgs_list/map: unified multi-ASG configuration
locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Support single-ASG mode by synthesizing an entry when provided
  asgs_list = length(var.asgs) > 0 ? var.asgs : (
    var.asg_name != null ? [
      {
        name                      = var.asg_name
        subnets                   = var.subnets
        min_size                  = var.min_size
        max_size                  = var.max_size
        desired_capacity          = var.desired_capacity
        health_check_type         = var.health_check_type
        health_check_grace_period = var.health_check_grace_period
        termination_policies      = var.termination_policies
        capacity_rebalance        = var.capacity_rebalance
        target_group_arns         = var.target_group_arns
        launch_template           = var.launch_template
        mixed_instances_policy    = var.mixed_instances_policy
        tags                      = var.tags
        lifecycle_hooks           = var.lifecycle_hooks
        scaling_policies          = var.scaling_policies
      }
    ] : []
  )
  asgs_map = { for a in local.asgs_list : a.name => a }

  # Flatten lifecycle hooks across ASGs and key by "<asg_name>:<hook_name>"
  lifecycle_hooks_flat = flatten([
    for asg_key, asg in local.asgs_map : [
      for h in coalesce(try(asg.lifecycle_hooks, []), []) : {
        asg_key                 = asg_key
        asg_name                = asg.name
        hook_name               = h.name
        lifecycle_transition    = h.lifecycle_transition
        notification_target_arn = try(h.notification_target_arn, null)
        role_arn                = try(h.role_arn, null)
        default_result          = try(h.default_result, "CONTINUE")
        heartbeat_timeout       = try(h.heartbeat_timeout, null)
        notification_metadata   = try(h.notification_metadata, null)
      }
    ]
  ])

  lifecycle_hooks_map = {
    for lh in local.lifecycle_hooks_flat : "${lh.asg_key}:${lh.hook_name}" => lh
  }

  # Flatten scaling policies per type
  simple_policies_flat = flatten([
    for asg_key, asg in local.asgs_map : [
      for p in coalesce(try(asg.scaling_policies.simple, []), []) : merge(p, { asg_key = asg_key })
    ]
  ])
  simple_policies_map = {
    for p in local.simple_policies_flat : "${p.asg_key}:${p.name}" => p
  }

  step_policies_flat = flatten([
    for asg_key, asg in local.asgs_map : [
      for p in coalesce(try(asg.scaling_policies.step, []), []) : merge(p, { asg_key = asg_key })
    ]
  ])
  step_policies_map = {
    for p in local.step_policies_flat : "${p.asg_key}:${p.name}" => p
  }

  # Flatten alarms for step scaling policies
  step_alarms_flat = flatten([
    for p_key, p in local.step_policies_map : [
      for a in coalesce(try(p.alarms, []), []) : merge(a, { policy_key = p_key })
    ]
  ])
  step_alarms_map = {
    for a in local.step_alarms_flat : "${a.policy_key}:${a.name}" => a
  }

  target_tracking_policies_flat = flatten([
    for asg_key, asg in local.asgs_map : [
      for p in coalesce(try(asg.scaling_policies.target_tracking, []), []) : merge(p, { asg_key = asg_key })
    ]
  ])
  target_tracking_policies_map = {
    for p in local.target_tracking_policies_flat : "${p.asg_key}:${p.name}" => p
  }

  predictive_policies_flat = flatten([
    for asg_key, asg in local.asgs_map : [
      for p in coalesce(try(asg.scaling_policies.predictive, []), []) : merge(p, { asg_key = asg_key })
    ]
  ])
  predictive_policies_map = {
    for p in local.predictive_policies_flat : "${p.asg_key}:${p.name}" => p
  }
}
