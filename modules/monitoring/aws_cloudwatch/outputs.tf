#############################################
# AWS CloudWatch Module - Outputs           #
# Exposes maps keyed by resource name for   #
# easy cross-module referencing.            #
#############################################

# ─── Log Groups ──────────────────────────────────────────────────────────────
output "log_group_names" {
  description = "Map of log group key to name"
  value       = { for k, lg in aws_cloudwatch_log_group.this : k => lg.name }
}

output "log_group_arns" {
  description = "Map of log group key to ARN"
  value       = { for k, lg in aws_cloudwatch_log_group.this : k => lg.arn }
}

# ─── Metric Alarms ───────────────────────────────────────────────────────────
output "metric_alarm_arns" {
  description = "Map of metric alarm name to ARN"
  value       = { for k, a in aws_cloudwatch_metric_alarm.this : k => a.arn }
}

output "metric_alarm_ids" {
  description = "Map of metric alarm name to resource ID"
  value       = { for k, a in aws_cloudwatch_metric_alarm.this : k => a.id }
}

# ─── Composite Alarms ────────────────────────────────────────────────────────
output "composite_alarm_arns" {
  description = "Map of composite alarm name to ARN"
  value       = { for k, a in aws_cloudwatch_composite_alarm.this : k => a.arn }
}

output "composite_alarm_ids" {
  description = "Map of composite alarm name to resource ID"
  value       = { for k, a in aws_cloudwatch_composite_alarm.this : k => a.id }
}

# ─── Dashboards ──────────────────────────────────────────────────────────────
output "dashboard_arns" {
  description = "Map of dashboard name to ARN"
  value       = { for k, d in aws_cloudwatch_dashboard.this : k => d.dashboard_arn }
}

# ─── Log Metric Filters ──────────────────────────────────────────────────────
output "log_metric_filter_ids" {
  description = "Map of log metric filter name to resource ID"
  value       = { for k, f in aws_cloudwatch_log_metric_filter.this : k => f.id }
}

# ─── Log Subscription Filters ────────────────────────────────────────────────
output "log_subscription_filter_ids" {
  description = "Map of log subscription filter name to resource ID"
  value       = { for k, f in aws_cloudwatch_log_subscription_filter.this : k => f.id }
}
