#############################################
# Wrapper - AWS CloudWatch Plan             #
# Calls the CloudWatch module and wires all #
# list variables through. Required: region. #
# Optional resource lists default to [].    #
#############################################

module "cloudwatch" {
  source = "../../modules/monitoring/aws_cloudwatch"

  region = var.region

  # Common tags merged with the wrapper-level created_date stamp
  tags = merge(var.tags, { created_date = local.created_date })

  # ── Log Groups ──────────────────────────────────────────────────────────────
  log_groups = var.log_groups

  # ── Metric Alarms ───────────────────────────────────────────────────────────
  metric_alarms = var.metric_alarms

  # ── Composite Alarms ────────────────────────────────────────────────────────
  composite_alarms = var.composite_alarms

  # ── Dashboards ──────────────────────────────────────────────────────────────
  dashboards = var.dashboards

  # ── Log Metric Filters ──────────────────────────────────────────────────────
  log_metric_filters = var.log_metric_filters

  # ── Log Subscription Filters ────────────────────────────────────────────────
  log_subscription_filters = var.log_subscription_filters
}
