# Variables for AWS Budgets Module

variable "region" {
  description = "AWS region for the provider. AWS Budgets is a global service but the provider still requires a region."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all budget resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

# Budget definition list.
# Each object represents one aws_budgets_budget with optional notifications and actions.
#
# Required per entry:
#   key          - Stable unique string key used as the for_each index (e.g. "monthly-total").
#   name         - Display name in the AWS console (e.g. "Monthly Total Spend").
#   budget_type  - COST | USAGE | RI_UTILIZATION | RI_COVERAGE | SAVINGS_PLANS_UTILIZATION | SAVINGS_PLANS_COVERAGE.
#   limit_amount - Numeric threshold value. For COST budgets: dollar amount. For USAGE: service units.
#   limit_unit   - "USD" for cost budgets; service-specific unit for usage budgets (e.g. "Hrs").
#
# Optional per entry:
#   time_unit           - DAILY | MONTHLY | QUARTERLY | ANNUALLY. Default: MONTHLY.
#   time_period_start   - First day of tracking in "YYYY-MM-DD_HH:MM". Default: "2024-01-01_00:00".
#   time_period_end     - Last day of tracking. Default: "2087-06-15_00:00" (effectively forever).
#   cost_filters        - List of { name, values } to scope the budget (service, region, tag, etc.).
#   cost_types          - Object controlling which charge types are included.
#   notifications       - List of alert thresholds with subscriber_email_addresses or subscriber_sns_topic_arns.
#   auto_adjust_type    - HISTORICAL or FORECAST — auto-adjust the limit_amount from spend history.
#   budget_adjustment_period - Lookback months for HISTORICAL auto-adjust (1-12). Default: 3.
#   actions             - List of automated remediation actions triggered at a threshold.
#   tags                - Per-budget tags merged with global tags.
variable "budgets" {
  description = "List of budget definitions. Each entry creates one aws_budgets_budget and optional aws_budgets_budget_action resources."
  type = list(object({
    key          = string
    name         = string
    budget_type  = string
    limit_amount = number
    limit_unit   = string

    time_unit                = optional(string, "MONTHLY")
    time_period_start        = optional(string, "2024-01-01_00:00")
    time_period_end          = optional(string, "2087-06-15_00:00")
    auto_adjust_type         = optional(string)
    budget_adjustment_period = optional(number, 3)

    cost_filters = optional(list(object({
      name   = string
      values = list(string)
    })))

    cost_types = optional(object({
      include_credit             = optional(bool, false)
      include_discount           = optional(bool, true)
      include_other_subscription = optional(bool, true)
      include_recurring          = optional(bool, true)
      include_refund             = optional(bool, false)
      include_subscription       = optional(bool, true)
      include_support            = optional(bool, false)
      include_tax                = optional(bool, false)
      include_upfront            = optional(bool, true)
      use_amortized              = optional(bool, false)
      use_blended                = optional(bool, false)
    }))

    notifications = optional(list(object({
      comparison_operator        = string
      threshold                  = number
      threshold_type             = string
      notification_type          = string
      subscriber_email_addresses = optional(list(string))
      subscriber_sns_topic_arns  = optional(list(string))
    })))

    actions = optional(list(object({
      action_key             = string
      action_type            = string
      approval_model         = string
      notification_type      = string
      execution_role_arn     = string
      action_threshold_type  = string
      action_threshold_value = number

      iam_action_definition = optional(object({
        policy_arn = string
        roles      = optional(list(string))
        groups     = optional(list(string))
        users      = optional(list(string))
      }))

      scp_action_definition = optional(object({
        policy_id  = string
        target_ids = list(string)
      }))

      ssm_action_definition = optional(object({
        action_sub_type = string
        instance_ids    = list(string)
        region          = string
      }))

      subscribers = optional(list(object({
        address           = string
        subscription_type = string
      })))
    })))

    tags = optional(map(string))
  }))

  validation {
    condition     = length([for b in var.budgets : b.key]) == length(toset([for b in var.budgets : b.key]))
    error_message = "Each budget must have a unique 'key'."
  }

  validation {
    condition = alltrue([
      for b in var.budgets : contains(
        ["COST", "USAGE", "RI_UTILIZATION", "RI_COVERAGE", "SAVINGS_PLANS_UTILIZATION", "SAVINGS_PLANS_COVERAGE"],
        b.budget_type
      )
    ])
    error_message = "budget_type must be one of: COST, USAGE, RI_UTILIZATION, RI_COVERAGE, SAVINGS_PLANS_UTILIZATION, SAVINGS_PLANS_COVERAGE."
  }

  validation {
    condition = alltrue([
      for b in var.budgets : contains(["DAILY", "MONTHLY", "QUARTERLY", "ANNUALLY"], b.time_unit)
    ])
    error_message = "time_unit must be one of: DAILY, MONTHLY, QUARTERLY, ANNUALLY."
  }

  validation {
    condition = alltrue([
      for b in var.budgets :
      b.auto_adjust_type == null || contains(["HISTORICAL", "FORECAST"], b.auto_adjust_type)
    ])
    error_message = "auto_adjust_type must be HISTORICAL, FORECAST, or null (disabled)."
  }

  validation {
    condition = alltrue([
      for b in var.budgets :
      b.notifications != null && length(b.notifications) > 0
    ])
    error_message = "Each budget must define at least one notification threshold. Budgets without notifications provide no cost governance alerts."
  }

  default = []
}
