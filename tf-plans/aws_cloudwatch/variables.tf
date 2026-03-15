#############################################
# Wrapper - Variables                       #
#############################################

variable "region" {
  description = "AWS region (e.g., us-east-1)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources (e.g., { project = \"demo\", environment = \"dev\" })"
  type        = map(string)
  default     = {}
}

# ─── Log Groups ──────────────────────────────────────────────────────────────
variable "log_groups" {
  description = "List of log groups to create"
  type = list(object({
    name              = string
    retention_in_days = optional(number, 30)
    kms_key_id        = optional(string)
    tags              = optional(map(string), {})
  }))
  default = []
}

# ─── Metric Alarms ───────────────────────────────────────────────────────────
variable "metric_alarms" {
  description = "List of metric alarms to create"
  type = list(object({
    alarm_name                = string
    comparison_operator       = string
    evaluation_periods        = number
    threshold                 = number
    metric_name               = optional(string)
    namespace                 = optional(string)
    period                    = optional(number, 60)
    statistic                 = optional(string, "Average")
    extended_statistic        = optional(string)
    unit                      = optional(string)
    dimensions                = optional(map(string), {})
    alarm_description         = optional(string)
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    treat_missing_data        = optional(string, "missing")
    datapoints_to_alarm       = optional(number)
    metric_queries = optional(list(object({
      id          = string
      expression  = optional(string)
      label       = optional(string)
      period      = optional(number)
      return_data = optional(bool, false)
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
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
  description = "List of composite alarms to create"
  type = list(object({
    alarm_name                = string
    alarm_rule                = string
    alarm_description         = optional(string)
    alarm_actions             = optional(list(string), [])
    ok_actions                = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    actions_suppressor = optional(object({
      alarm            = string
      extension_period = optional(number, 60)
      wait_period      = optional(number, 120)
    }))
    tags = optional(map(string), {})
  }))
  default = []
}

# ─── Dashboards ──────────────────────────────────────────────────────────────
variable "dashboards" {
  description = "List of dashboards to create (name + JSON body string)"
  type = list(object({
    name = string
    body = string
  }))
  default = []
}

# ─── Log Metric Filters ──────────────────────────────────────────────────────
variable "log_metric_filters" {
  description = "List of log metric filters to create"
  type = list(object({
    name                 = string
    pattern              = string
    log_group_name       = string
    metric_name          = string
    metric_namespace     = string
    metric_value         = optional(string, "1")
    metric_default_value = optional(number)
    metric_unit          = optional(string, "None")
    metric_dimensions    = optional(map(string), {})
  }))
  default = []
}

# ─── Log Subscription Filters ────────────────────────────────────────────────
variable "log_subscription_filters" {
  description = "List of log subscription filters to create"
  type = list(object({
    name            = string
    log_group_name  = string
    filter_pattern  = string
    destination_arn = string
    distribution    = optional(string, "ByLogStream")
    role_arn        = optional(string)
  }))
  default = []
}
