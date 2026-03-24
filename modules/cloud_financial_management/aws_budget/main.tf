# Terraform AWS Budgets Module
# Manages AWS Budget resources including cost, usage, RI utilization/coverage,
# and Savings Plans utilization/coverage budgets with optional SNS/email notifications
# and optional auto-remediation actions (IAM policy / SCP / target-group isolation).
# Supports creating multiple budgets in a single module call via for_each.

# Step 1: Create one or more budgets from the budgets input list.
# Each budget monitors a specific dimension (cost, usage, RI, Savings Plans)
# and publishes alerts when actual or forecasted spend crosses defined thresholds.
resource "aws_budgets_budget" "budget" {
  for_each = local.budgets_map

  # Step 2: Core identity fields.
  name         = each.value.name
  budget_type  = each.value.budget_type
  limit_amount = tostring(each.value.limit_amount)
  limit_unit   = each.value.limit_unit

  # Step 3: Time configuration.
  # time_period_start must be the first day of a month in "YYYY-MM-DD_HH:MM" format.
  time_unit         = each.value.time_unit
  time_period_start = each.value.time_period_start
  time_period_end   = each.value.time_period_end

  # Step 4: Optional cost filters — narrow the budget scope to specific services,
  # linked accounts, regions, instance types, usage types, or tag key/values.
  dynamic "cost_filter" {
    for_each = each.value.cost_filters != null ? each.value.cost_filters : []
    content {
      name   = cost_filter.value.name
      values = cost_filter.value.values
    }
  }

  # Step 5: Optional cost types control which charges are included in the budget total.
  # Defaults omit credits, refunds, support, taxes, and include blended/unblended costs.
  dynamic "cost_types" {
    for_each = each.value.cost_types != null ? [each.value.cost_types] : []
    content {
      include_credit             = cost_types.value.include_credit
      include_discount           = cost_types.value.include_discount
      include_other_subscription = cost_types.value.include_other_subscription
      include_recurring          = cost_types.value.include_recurring
      include_refund             = cost_types.value.include_refund
      include_subscription       = cost_types.value.include_subscription
      include_support            = cost_types.value.include_support
      include_tax                = cost_types.value.include_tax
      include_upfront            = cost_types.value.include_upfront
      use_amortized              = cost_types.value.use_amortized
      use_blended                = cost_types.value.use_blended
    }
  }

  # Step 6: Optional SNS and email notification thresholds.
  # Multiple notifications can be set — e.g. alert at 80%, 100%, and 110% (forecasted).
  # threshold_type PERCENTAGE is relative to limit_amount; ABSOLUTE_VALUE is in limit_unit.
  # comparison_operator: GREATER_THAN | LESS_THAN | EQUAL_TO.
  # notification_type: ACTUAL | FORECASTED.
  dynamic "notification" {
    for_each = each.value.notifications != null ? each.value.notifications : []
    content {
      comparison_operator        = notification.value.comparison_operator
      threshold                  = notification.value.threshold
      threshold_type             = notification.value.threshold_type
      notification_type          = notification.value.notification_type
      subscriber_email_addresses = notification.value.subscriber_email_addresses != null ? notification.value.subscriber_email_addresses : []
      subscriber_sns_topic_arns  = notification.value.subscriber_sns_topic_arns != null ? notification.value.subscriber_sns_topic_arns : []
    }
  }

  # Step 7: Optional automated budget actions — trigger IAM policy attachment,
  # SCP application, or EC2/RDS targeting when spend crosses a threshold.
  # Each action requires an execution_role_arn with budgets.amazonaws.com trust.
  dynamic "auto_adjust_data" {
    for_each = each.value.auto_adjust_type != null ? [each.value.auto_adjust_type] : []
    content {
      auto_adjust_type = auto_adjust_data.value
      # Historical auto-adjust calculates the budget limit from spend history.
      dynamic "historical_options" {
        for_each = auto_adjust_data.value == "HISTORICAL" ? [each.value.budget_adjustment_period] : []
        content {
          budget_adjustment_period = historical_options.value
        }
      }
    }
  }

  # Step 8: Apply common + per-budget tags plus a Name tag for console identification.
  tags = merge(local.common_tags, each.value.tags != null ? each.value.tags : {}, {
    Name = each.value.name
  })
}

# Step 9: Optionally create budget actions for automated remediation.
# Actions execute an IAM, SCP, or SSM document when an alert threshold is crossed.
# One action resource is created per entry in the budget's actions list.
resource "aws_budgets_budget_action" "action" {
  for_each = local.budget_actions_map

  budget_name        = aws_budgets_budget.budget[each.value.budget_key].name
  action_type        = each.value.action_type
  approval_model     = each.value.approval_model
  notification_type  = each.value.notification_type
  execution_role_arn = each.value.execution_role_arn

  # Step 10: Action threshold — the percentage of the budget limit that triggers the action.
  action_threshold {
    action_threshold_type  = each.value.action_threshold_type
    action_threshold_value = each.value.action_threshold_value
  }

  # Step 11: Define the action definition — IAM policy, SCP, or SSM target.
  definition {
    dynamic "iam_action_definition" {
      for_each = each.value.iam_action_definition != null ? [each.value.iam_action_definition] : []
      content {
        policy_arn = iam_action_definition.value.policy_arn
        # Attach the policy to the listed roles, groups, or users when triggered.
        roles  = iam_action_definition.value.roles
        groups = iam_action_definition.value.groups
        users  = iam_action_definition.value.users
      }
    }

    dynamic "scp_action_definition" {
      for_each = each.value.scp_action_definition != null ? [each.value.scp_action_definition] : []
      content {
        policy_id  = scp_action_definition.value.policy_id
        target_ids = scp_action_definition.value.target_ids
      }
    }

    dynamic "ssm_action_definition" {
      for_each = each.value.ssm_action_definition != null ? [each.value.ssm_action_definition] : []
      content {
        action_sub_type = ssm_action_definition.value.action_sub_type
        instance_ids    = ssm_action_definition.value.instance_ids
        region          = ssm_action_definition.value.region
      }
    }
  }

  # Step 12: Subscribers notified when the action executes.
  dynamic "subscriber" {
    for_each = each.value.subscribers != null ? each.value.subscribers : []
    content {
      address           = subscriber.value.address
      subscription_type = subscriber.value.subscription_type
    }
  }

  depends_on = [aws_budgets_budget.budget]
}
