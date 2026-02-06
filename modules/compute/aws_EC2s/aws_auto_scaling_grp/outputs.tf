output "asg_names" {
  description = "Map of ASG names keyed by ASG key"
  value = {
    for k, v in aws_autoscaling_group.asg : k => v.name
  }
}

output "asg_arns" {
  description = "Map of ASG ARNs keyed by ASG key"
  value = {
    for k, v in aws_autoscaling_group.asg : k => v.arn
  }
}

output "asg_desired_capacities" {
  description = "Map of desired capacities keyed by ASG key"
  value = {
    for k, v in aws_autoscaling_group.asg : k => v.desired_capacity
  }
}

output "asg_min_max_sizes" {
  description = "Map of min/max sizes keyed by ASG key"
  value = {
    for k, v in aws_autoscaling_group.asg : k => {
      min = v.min_size
      max = v.max_size
    }
  }
}

output "lifecycle_hook_names" {
  description = "Lifecycle hook names keyed by '<asg_name>:<hook_name>'"
  value = {
    for k, v in aws_autoscaling_lifecycle_hook.hook : k => v.name
  }
}

output "simple_policy_arns" {
  description = "SimpleScaling policy ARNs keyed by '<asg_name>:<policy_name>'"
  value = {
    for k, v in aws_autoscaling_policy.simple : k => v.arn
  }
}

output "step_policy_arns" {
  description = "StepScaling policy ARNs keyed by '<asg_name>:<policy_name>'"
  value = {
    for k, v in aws_autoscaling_policy.step : k => v.arn
  }
}

output "target_tracking_policy_arns" {
  description = "TargetTracking policy ARNs keyed by '<asg_name>:<policy_name>'"
  value = {
    for k, v in aws_autoscaling_policy.target_tracking : k => v.arn
  }
}

output "predictive_policy_arns" {
  description = "PredictiveScaling policy ARNs keyed by '<asg_name>:<policy_name>'"
  value = {
    for k, v in aws_autoscaling_policy.predictive : k => v.arn
  }
}

output "step_alarm_arns" {
  description = "CloudWatch alarm ARNs for step scaling keyed by '<asg_name>:<policy_name>:<alarm_name>'"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.step_alarm : k => v.arn
  }
}
