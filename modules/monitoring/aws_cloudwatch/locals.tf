#############################################
# AWS CloudWatch Module - Locals            #
# Centralises metadata and converts list    #
# variables into keyed maps for for_each.   #
#############################################

locals {
  # Stamp every resource with the calendar date it was first created
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Convert log_groups list → map keyed by log group name
  log_groups_map = { for lg in var.log_groups : lg.name => lg }

  # Convert metric_alarms list → map keyed by alarm_name
  metric_alarms_map = { for a in var.metric_alarms : a.alarm_name => a }

  # Convert composite_alarms list → map keyed by alarm_name
  composite_alarms_map = { for a in var.composite_alarms : a.alarm_name => a }

  # Convert dashboards list → map keyed by dashboard name
  dashboards_map = { for d in var.dashboards : d.name => d }

  # Convert log_metric_filters list → map keyed by filter name
  log_metric_filters_map = { for f in var.log_metric_filters : f.name => f }

  # Convert log_subscription_filters list → map keyed by filter name
  log_subscription_filters_map = { for f in var.log_subscription_filters : f.name => f }
}
