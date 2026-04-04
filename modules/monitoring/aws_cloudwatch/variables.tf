#############################################
# AWS CloudWatch Module - Variables         #
# Defines required and optional inputs for  #
# log groups, metric alarms, composite      #
# alarms, dashboards, log metric filters,   #
# and log subscription filters.             #
#############################################

variable "region" {
  description = "AWS region to deploy CloudWatch resources (e.g., us-east-1)"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Common tags applied to all CloudWatch resources"
  type        = map(string)
  default     = {}
}

# ─── Log Groups ──────────────────────────────────────────────────────────────
variable "log_groups" {
  description = "List of CloudWatch log groups to create. Each group can specify retention and optional KMS encryption."
  type = list(object({
    name              = string               # Log group name, e.g., /aws/lambda/my-function
    retention_in_days = optional(number, 30) # Days to retain logs (0 = never expire)
    kms_key_id        = optional(string)     # ARN of KMS key for encryption at rest
    tags              = optional(map(string), {})
  }))
  default = []
}

# ─── Metric Alarms ───────────────────────────────────────────────────────────
variable "metric_alarms" {
  description = "List of CloudWatch metric alarms. Supports simple single-metric alarms and expression-based (metric_queries) alarms."
  type = list(object({
    alarm_name          = string # Unique alarm name
    comparison_operator = string # e.g., GreaterThanThreshold, LessThanThreshold
    evaluation_periods  = number # Number of periods to evaluate
    threshold           = number # Numeric threshold value

    # Single-metric fields — omit when using metric_queries
    metric_name        = optional(string)            # CloudWatch metric name
    namespace          = optional(string)            # CloudWatch namespace, e.g., AWS/EC2
    period             = optional(number, 60)        # Period in seconds (60, 300, etc.)
    statistic          = optional(string, "Average") # Average | Sum | Min | Max | SampleCount
    extended_statistic = optional(string)            # Percentile, e.g., p99 (overrides statistic)
    unit               = optional(string)            # Metric unit, e.g., Percent, Count, Bytes
    dimensions         = optional(map(string), {})   # Dimension key/value pairs

    # Alarm behaviour
    alarm_description         = optional(string)
    alarm_actions             = optional(list(string), []) # SNS ARNs or other action ARNs
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    treat_missing_data        = optional(string, "missing") # missing | ignore | breaching | notBreaching
    datapoints_to_alarm       = optional(number)            # N out of M periods must breach

    # Expression-based alarm queries (math / anomaly detection)
    metric_queries = optional(list(object({
      id          = string                # Unique ID within this alarm, e.g., m1
      expression  = optional(string)      # Math expression, e.g., "m1+m2"
      label       = optional(string)      # Human-readable label
      period      = optional(number)      # Override period for this query
      return_data = optional(bool, false) # true on the query whose result is compared to threshold
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string # e.g., Sum, Average
        unit        = optional(string)
        dimensions  = optional(map(string), {})
      }))
    })), [])

    tags = optional(map(string), {})
  }))
  default = []
}

# ─── Composite Alarms ────────────────────────────────────────────────────────
variable "composite_alarms" {
  description = "List of CloudWatch composite alarms combining metric alarms via boolean expressions."
  type = list(object({
    alarm_name                = string # Unique composite alarm name
    alarm_rule                = string # Boolean expression, e.g., ALARM(\"cpu-high\") OR ALARM(\"errors\")
    alarm_description         = optional(string)
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])

    # Suppressor alarm silences actions while a maintenance/suppressor alarm is active
    actions_suppressor = optional(object({
      alarm            = string                # Name of the suppressor alarm
      extension_period = optional(number, 60)  # Seconds to continue suppressing after OK
      wait_period      = optional(number, 120) # Seconds before suppression takes effect
    }))

    tags = optional(map(string), {})
  }))
  default = []
}

# ─── Dashboards ──────────────────────────────────────────────────────────────
variable "dashboards" {
  description = "List of CloudWatch dashboards. Supply a dashboard name and a JSON body string."
  type = list(object({
    name = string # Dashboard name (unique per account/region)
    body = string # JSON string — use jsonencode() in the caller or pass a raw JSON string
    # Note: AWS does not support tags on CloudWatch dashboards
  }))
  default = []
}

# ─── Log Metric Filters ──────────────────────────────────────────────────────
variable "log_metric_filters" {
  description = "List of CloudWatch log metric filters that extract custom metrics from log events."
  type = list(object({
    name           = string # Filter name
    pattern        = string # CloudWatch Logs filter pattern, e.g., "ERROR"
    log_group_name = string # Target log group name

    # Metric transformation
    metric_name          = string                    # Name of the CloudWatch metric to publish
    metric_namespace     = string                    # Namespace for the metric, e.g., MyApp/Errors
    metric_value         = optional(string, "1")     # Value published per match (numeric string)
    metric_default_value = optional(number)          # Value when no events match; omit to not publish
    metric_unit          = optional(string, "None")  # Metric unit
    metric_dimensions    = optional(map(string), {}) # Dimensions extracted from log fields
  }))
  default = []
}

# ─── Log Subscription Filters ────────────────────────────────────────────────
variable "log_subscription_filters" {
  description = "List of CloudWatch log subscription filters that stream log events to a destination."
  type = list(object({
    name            = string # Filter name
    log_group_name  = string # Source log group
    filter_pattern  = string # Filter pattern (empty string = all events)
    destination_arn = string # ARN of Lambda, Kinesis Stream, or Kinesis Firehose

    # ByLogStream — deterministic; Random — spread events across shards (Kinesis only)
    distribution = optional(string, "ByLogStream")

    # IAM role ARN required for Kinesis/Firehose destinations; not needed for Lambda
    role_arn = optional(string)
  }))
  default = []
}
