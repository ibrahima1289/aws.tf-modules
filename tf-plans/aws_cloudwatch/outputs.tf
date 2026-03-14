#############################################
# Wrapper - Outputs                         #
#############################################

# ─── Log Groups ──────────────────────────────────────────────────────────────
output "log_group_names" {
  description = "Map of log group key to name"
  value       = module.cloudwatch.log_group_names
}

output "log_group_arns" {
  description = "Map of log group key to ARN"
  value       = module.cloudwatch.log_group_arns
}

# ─── Metric Alarms ───────────────────────────────────────────────────────────
output "metric_alarm_arns" {
  description = "Map of metric alarm name to ARN"
  value       = module.cloudwatch.metric_alarm_arns
}

output "metric_alarm_ids" {
  description = "Map of metric alarm name to ID"
  value       = module.cloudwatch.metric_alarm_ids
}

# ─── Composite Alarms ────────────────────────────────────────────────────────
output "composite_alarm_arns" {
  description = "Map of composite alarm name to ARN"
  value       = module.cloudwatch.composite_alarm_arns
}

output "composite_alarm_ids" {
  description = "Map of composite alarm name to ID"
  value       = module.cloudwatch.composite_alarm_ids
}

# ─── Dashboards ──────────────────────────────────────────────────────────────
output "dashboard_arns" {
  description = "Map of dashboard name to ARN"
  value       = module.cloudwatch.dashboard_arns
}

# ─── Log Metric Filters ──────────────────────────────────────────────────────
output "log_metric_filter_ids" {
  description = "Map of log metric filter name to ID"
  value       = module.cloudwatch.log_metric_filter_ids
}

# ─── Log Subscription Filters ────────────────────────────────────────────────
output "log_subscription_filter_ids" {
  description = "Map of log subscription filter name to ID"
  value       = module.cloudwatch.log_subscription_filter_ids
}
