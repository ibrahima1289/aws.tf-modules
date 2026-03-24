# ─────────────────────────────────────────────────────────────────────────────
# AWS Region
# AWS Budgets is a global service but the provider still requires a region.
# ─────────────────────────────────────────────────────────────────────────────
region = "us-east-1"

# ─────────────────────────────────────────────────────────────────────────────
# Global Tags
# ─────────────────────────────────────────────────────────────────────────────
tags = {
  environment = "production"
  team        = "finops"
  project     = "cost-governance"
  managed_by  = "terraform"
}

# ─────────────────────────────────────────────────────────────────────────────
# Budget Definitions
# ─────────────────────────────────────────────────────────────────────────────
budgets = [
  # ── Budget 1: Monthly Total Account Spend ────────────────────────────────
  # Alerts at 80% actual, 100% actual, and 110% forecasted spend.
  # Sends email alerts to the FinOps team.
  {
    key               = "monthly-total"
    name              = "Monthly Total Account Spend"
    budget_type       = "COST"
    limit_amount      = 500
    limit_unit        = "USD"
    time_unit         = "MONTHLY"
    time_period_start = "2026-01-01_00:00"
    time_period_end   = "2030-12-31_00:00"

    notifications = [
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 80
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["finops@example.com"]
      },
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 100
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["finops@example.com", "cto@example.com"]
      },
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 110
        threshold_type             = "PERCENTAGE"
        notification_type          = "FORECASTED"
        subscriber_email_addresses = ["finops@example.com"]
      }
    ]

    tags = { scope = "account-wide" }
  },

  # ── Budget 2: EC2 Monthly Spend (service-scoped) ──────────────────────────
  # Scoped to EC2 only via a cost_filter on the Service dimension.
  # Alerts at 90% actual spend.
  {
    key          = "ec2-monthly"
    name         = "EC2 Monthly Spend"
    budget_type  = "COST"
    limit_amount = 200
    limit_unit   = "USD"
    time_unit    = "MONTHLY"

    cost_filters = [
      {
        name   = "Service"
        values = ["Amazon Elastic Compute Cloud - Compute"]
      }
    ]

    notifications = [
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 90
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["platform@example.com"]
        subscriber_sns_topic_arns  = ["arn:aws:sns:us-east-1:123456789012:budget-alerts"]
      }
    ]

    tags = { scope = "ec2" }
  },

  # ── Budget 3: Auto-Adjusting Historical Budget ────────────────────────────
  # Calculates the budget limit automatically from the previous 3 months
  # of historical spend. Useful when spend patterns are variable.
  {
    key                      = "auto-adjust-historical"
    name                     = "Auto-Adjusting Monthly Budget (Historical)"
    budget_type              = "COST"
    limit_amount             = 100 # initial estimate — overridden by historical data
    limit_unit               = "USD"
    time_unit                = "MONTHLY"
    auto_adjust_type         = "HISTORICAL"
    budget_adjustment_period = 3

    notifications = [
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 105
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["finops@example.com"]
      }
    ]

    tags = { scope = "auto-adjust" }
  },

  # ── Budget 4: RI Utilization — ensure Reserved Instances are being used ───
  # Alerts when RI utilization drops BELOW 80% — indicates wasted reservation spend.
  {
    key          = "ri-utilization"
    name         = "EC2 RI Utilization"
    budget_type  = "RI_UTILIZATION"
    limit_amount = 80 # alert when utilization drops below 80%
    limit_unit   = "PERCENTAGE"
    time_unit    = "MONTHLY"

    cost_filters = [
      {
        name   = "Service"
        values = ["Amazon Elastic Compute Cloud - Compute"]
      }
    ]

    notifications = [
      {
        comparison_operator        = "LESS_THAN"
        threshold                  = 80
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["finops@example.com"]
      }
    ]

    tags = { scope = "ri-governance" }
  },

  # ── Budget 5: Monthly Spend with IAM-based Auto-Remediation Action ────────
  # Attaches a deny-all IAM policy to a developer role when spend exceeds $3,000.
  # Requires an IAM role that trusts budgets.amazonaws.com with the
  # AWSBudgetsActionsWithAWSResourceControlPolicy managed policy.
  {
    key          = "monthly-with-action"
    name         = "Monthly Spend with Auto-Remediation"
    budget_type  = "COST"
    limit_amount = 300
    limit_unit   = "USD"
    time_unit    = "MONTHLY"

    notifications = [
      {
        comparison_operator        = "GREATER_THAN"
        threshold                  = 100
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["security@example.com"]
      }
    ]

    actions = [
      {
        action_key             = "deny-dev-role"
        action_type            = "APPLY_IAM_POLICY"
        approval_model         = "AUTOMATIC"
        notification_type      = "ACTUAL"
        execution_role_arn     = "arn:aws:iam::123456789012:role/BudgetActionsRole"
        action_threshold_type  = "PERCENTAGE"
        action_threshold_value = 100

        iam_action_definition = {
          policy_arn = "arn:aws:iam::aws:policy/AWSDenyAll"
          roles      = ["DeveloperRole"]
        }

        subscribers = [
          {
            address           = "security@example.com"
            subscription_type = "EMAIL"
          }
        ]
      }
    ]

    tags = { scope = "guardrails" }
  }
]
