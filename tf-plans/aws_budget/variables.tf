variable "region" {
  description = "AWS region for the provider. AWS Budgets is a global service but the provider requires a region."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all budget resources."
  type        = map(string)
  default     = {}
}

variable "budgets" {
  description = "List of budget definitions. Each entry creates one aws_budgets_budget and optional action resources."
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
  default = []
}
