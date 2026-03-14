##############################################
# Wrapper - terraform.tfvars                #
# Adjust values to match your environment.  #
##############################################

region = "us-east-1"

tags = {
  project     = "demo"
  environment = "dev"
  managed_by  = "terraform"
}

# ─── Log Groups ──────────────────────────────────────────────────────────────
# Create two log groups: one for the API layer and one for background workers.
log_groups = [
  {
    name              = "/app/demo/api"
    retention_in_days = 7 # 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, or never expire (0)
  },
  {
    name              = "/app/demo/workers"
    retention_in_days = 30 # 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, or never expire (0)
  }
]

# ─── Metric Alarms ───────────────────────────────────────────────────────────
# Example 1: simple single-metric alarm — EC2 CPU.
# Example 2: Lambda error rate alarm with Sum statistic.
metric_alarms = [
  {
    alarm_name          = "demo-ec2-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 3
    threshold           = 80
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    dimensions          = { InstanceId = "i-0123456789abcdef0" }
    alarm_description   = "EC2 CPU exceeds 80% for 15 consecutive minutes"
    alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:demo-alerts"]
    ok_actions          = ["arn:aws:sns:us-east-1:123456789012:demo-alerts"]
    treat_missing_data  = "breaching"
  },
  {
    alarm_name          = "demo-lambda-errors"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 1
    threshold           = 5
    metric_name         = "Errors"
    namespace           = "AWS/Lambda"
    period              = 60
    statistic           = "Sum"
    dimensions          = { FunctionName = "demo-function" }
    alarm_description   = "Lambda error count exceeds 5 in 1 minute"
    alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:demo-alerts"]
    datapoints_to_alarm = 1
  },
  # Example 3: expression-based alarm — anomaly detection on request count.
  # Uncomment to enable; remove or comment out metric_queries entries to disable.
  # {
  #   alarm_name          = "demo-request-anomaly"
  #   comparison_operator = "GreaterThanUpperThreshold"
  #   evaluation_periods  = 2
  #   threshold           = 2            # 2 standard deviations
  #   alarm_description   = "Request count anomaly detected"
  #   alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:demo-alerts"]
  #   metric_queries = [
  #     {
  #       id          = "m1"
  #       return_data = false
  #       metric = {
  #         metric_name = "RequestCount"
  #         namespace   = "AWS/ApplicationELB"
  #         period      = 300
  #         stat        = "Sum"
  #         dimensions  = { LoadBalancer = "app/demo-alb/abc123" }
  #       }
  #     },
  #     {
  #       id          = "ad1"
  #       expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
  #       label       = "RequestCount (expected)"
  #       return_data = true
  #     }
  #   ]
  # }
]

# ─── Composite Alarm ─────────────────────────────────────────────────────────
# Fires ALARM when either of the metric alarms above is in ALARM state.
composite_alarms = [
  {
    alarm_name        = "demo-critical-composite"
    alarm_rule        = "ALARM(\"demo-ec2-high-cpu\") OR ALARM(\"demo-lambda-errors\")"
    alarm_description = "Critical composite: CPU or Lambda errors are alarming"
    alarm_actions     = ["arn:aws:sns:us-east-1:123456789012:demo-critical"]
    ok_actions        = ["arn:aws:sns:us-east-1:123456789012:demo-critical"]
  }
]

# ─── Log Metric Filters ──────────────────────────────────────────────────────
# Extract an ErrorCount metric from the API log group whenever "ERROR" appears.
log_metric_filters = [
  {
    name             = "demo-api-error-count"
    pattern          = "ERROR"
    log_group_name   = "/app/demo/api"
    metric_name      = "ApiErrorCount"
    metric_namespace = "DemoApp"
    metric_value     = "1"
    metric_unit      = "Count"
  }
]

# ─── Dashboards ──────────────────────────────────────────────────────────────
# Minimal single-widget dashboard showing EC2 CPU.
# For complex dashboards, build the JSON with jsonencode() in a .tf file instead.
dashboards = [
  {
    name = "demo-overview"
    body = <<JSON
    {
      "widgets": [
        {
          "type": "metric",
          "x": 0,
          "y": 0,
          "width": 12,
          "height": 6,
          "properties": {
            "title": "EC2 CPU Utilization",
            "region": "us-east-1",
            "metrics": [
              [
                "AWS/EC2",
                "CPUUtilization",
                "InstanceId",
                "i-0123456789abcdef0"
              ]
            ],
            "period": 300,
            "stat": "Average",
            "view": "timeSeries",
            "stacked": false
          }
        }
      ]
    }
    JSON
  }
]

# ─── Log Subscription Filters ────────────────────────────────────────────────
# Uncomment to stream all API log events to a Lambda function for processing.
# log_subscription_filters = [
#   {
#     name            = "demo-api-to-lambda"
#     log_group_name  = "/app/demo/api"
#     filter_pattern  = ""
#     destination_arn = "arn:aws:lambda:us-east-1:123456789012:function:demo-log-processor"
#   }
# ]
log_subscription_filters = []
