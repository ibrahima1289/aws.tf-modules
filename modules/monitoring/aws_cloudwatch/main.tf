#############################################
# AWS CloudWatch Module - Main              #
# Manages: log groups, metric alarms,       #
# composite alarms, dashboards, log metric  #
# filters, and log subscription filters.    #
# Multi-resource via list variables;        #
# locals convert them to keyed maps for     #
# safe for_each iteration.                  #
#############################################

# ─── Log Groups ──────────────────────────────────────────────────────────────
# Creates one CloudWatch log group per entry in var.log_groups.
# Controls retention period and optional KMS encryption at rest.
resource "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups_map

  name = each.value.name

  # 0 = never expire; positive integer = days to retain; defaults to 30
  retention_in_days = try(each.value.retention_in_days, 30)

  # Optional customer-managed KMS key ARN for server-side encryption
  kms_key_id = try(each.value.kms_key_id, null)

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name         = each.value.name
    created_date = local.created_date
  })
}

# ─── Metric Alarms ───────────────────────────────────────────────────────────
# Creates one CloudWatch metric alarm per entry in var.metric_alarms.
# Supports both simple single-metric alarms and expression-based alarms
# (anomaly detection, math expressions) via metric_query blocks.
resource "aws_cloudwatch_metric_alarm" "this" {
  for_each = local.metric_alarms_map

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold

  # Standard single-metric attributes — only emitted when no metric_queries exist
  metric_name = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.metric_name, null) : null
  namespace   = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.namespace, null) : null
  period      = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.period, 60) : null

  # Use statistic unless an extended_statistic (e.g., p99) is specified
  statistic          = length(try(each.value.metric_queries, [])) == 0 && try(each.value.extended_statistic, null) == null ? try(each.value.statistic, "Average") : null
  extended_statistic = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.extended_statistic, null) : null

  unit = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.unit, null) : null

  # Dimensions as key/value map (e.g., { InstanceId = "i-abc123" })
  dimensions = length(try(each.value.metric_queries, [])) == 0 ? try(each.value.dimensions, {}) : null

  # Human-readable description shown in the CloudWatch console
  alarm_description = try(each.value.alarm_description, "${each.value.alarm_name} alarm")

  # SNS topic ARNs (or other action ARNs) triggered per alarm state transition
  alarm_actions             = try(each.value.alarm_actions, [])
  ok_actions                = try(each.value.ok_actions, [])
  insufficient_data_actions = try(each.value.insufficient_data_actions, [])

  # How to evaluate periods with missing data: missing | ignore | breaching | notBreaching
  treat_missing_data = try(each.value.treat_missing_data, "missing")

  # Require N out of M periods to breach before the alarm fires
  datapoints_to_alarm = try(each.value.datapoints_to_alarm, null)

  # Expression-based metric queries — math alarms, anomaly detection bands, cross-account metrics
  dynamic "metric_query" {
    for_each = try(each.value.metric_queries, [])
    content {
      id         = metric_query.value.id
      expression = try(metric_query.value.expression, null)
      label      = try(metric_query.value.label, null)
      period     = try(metric_query.value.period, null)

      # Exactly one metric_query must have return_data = true — that is the final evaluated value
      return_data = try(metric_query.value.return_data, false)

      # Nested metric block — omit when an expression is provided instead
      dynamic "metric" {
        for_each = try(metric_query.value.metric, null) != null ? [metric_query.value.metric] : []
        content {
          metric_name = metric.value.metric_name
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = try(metric.value.unit, null)
          dimensions  = try(metric.value.dimensions, {})
        }
      }
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name         = each.value.alarm_name
    created_date = local.created_date
  })
}

# ─── Composite Alarms ────────────────────────────────────────────────────────
# Combines multiple metric or composite alarms using a boolean alarm_rule string.
# Example rule: ALARM("cpu-high") OR ALARM("error-rate-high")
resource "aws_cloudwatch_composite_alarm" "this" {
  for_each = local.composite_alarms_map

  alarm_name = each.value.alarm_name

  # Boolean expression using ALARM(), OK(), INSUFFICIENT_DATA() on child alarm names
  alarm_rule        = each.value.alarm_rule
  alarm_description = try(each.value.alarm_description, "${each.value.alarm_name} composite alarm")

  alarm_actions             = try(each.value.alarm_actions, [])
  ok_actions                = try(each.value.ok_actions, [])
  insufficient_data_actions = try(each.value.insufficient_data_actions, [])

  # Optional actions suppressor — silences actions while a maintenance alarm is active
  dynamic "actions_suppressor" {
    for_each = try(each.value.actions_suppressor, null) != null ? [each.value.actions_suppressor] : []
    content {
      alarm            = actions_suppressor.value.alarm
      extension_period = try(actions_suppressor.value.extension_period, 60)
      wait_period      = try(actions_suppressor.value.wait_period, 120)
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name         = each.value.alarm_name
    created_date = local.created_date
  })
}

# ─── Dashboards ──────────────────────────────────────────────────────────────
# Creates a CloudWatch dashboard from a JSON body string.
# Build the body JSON with jsonencode() in your module caller or pass a raw string.
# Note: AWS does not support resource tags on CloudWatch dashboards.
resource "aws_cloudwatch_dashboard" "this" {
  for_each = local.dashboards_map

  dashboard_name = each.value.name

  # JSON string — see https://docs.aws.amazon.com/AmazonCloudWatch/latest/APIReference/CloudWatch-Dashboard-Body-Structure.html
  dashboard_body = each.value.body
}

# ─── Log Metric Filters ──────────────────────────────────────────────────────
# Extracts a numeric metric from log events matching a filter pattern.
# Useful for turning log-based events (e.g., ERROR counts) into CloudWatch metrics
# that can then feed into metric alarms defined above.
resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = local.log_metric_filters_map

  name = each.value.name

  # CloudWatch Logs filter pattern syntax, e.g., "ERROR", "[ts, level=ERROR, msg]"
  pattern        = each.value.pattern
  log_group_name = each.value.log_group_name

  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace

    # Numeric string published when the pattern matches (typically "1" for counts)
    value = try(each.value.metric_value, "1")

    # Value published when no events match in a period; omit to publish no data
    default_value = try(each.value.metric_default_value, null)

    unit = try(each.value.metric_unit, "None")

    # Optional map of log field names to dimension values extracted from log events
    dimensions = try(each.value.metric_dimensions, {})
  }
}

# ─── Log Subscription Filters ────────────────────────────────────────────────
# Streams log events matching a filter pattern to a destination in real time.
# Supported destinations: Lambda function, Kinesis Data Stream, Kinesis Firehose.
resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = local.log_subscription_filters_map

  name           = each.value.name
  log_group_name = each.value.log_group_name

  # Empty string matches all log events; use a filter pattern to restrict
  filter_pattern  = each.value.filter_pattern
  destination_arn = each.value.destination_arn

  # ByLogStream (default) — deterministic shard assignment; Random — for high-fan-out
  distribution = try(each.value.distribution, "ByLogStream")

  # IAM role ARN required when destination is Kinesis or Firehose (not Lambda)
  role_arn = try(each.value.role_arn, null)
}
