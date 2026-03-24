# AWS Budget Module

> 📖 **Service Guide:** [aws-budget.md](aws-budget.md) | **Wrapper:** [tf-plans/aws_budget](../../../tf-plans/aws_budget/README.md) | **Pricing:** [AWS Budgets Pricing](https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/)

Terraform module for managing [AWS Budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/) — cost, usage, RI, and Savings Plans budgets with SNS/email notifications and optional automated remediation actions.

---

## Architecture

```
modules/cloud_financial_management/aws_budget/
├── providers.tf   ← Terraform >= 1.3, AWS >= 5.0
├── variables.tf   ← Input variable declarations
├── locals.tf      ← created_date, common_tags, budgets_map, budget_actions_map
├── main.tf        ← aws_budgets_budget + aws_budgets_budget_action (for_each)
├── outputs.tf     ← budget_ids, budget_names, budget_types, budget_limits, budget_action_ids
├── aws-budget.md  ← Service overview, architecture, pricing
└── README.md      ← This file
```

---

## Resources

| Resource | Purpose |
|----------|---------|
| [`aws_budgets_budget`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | Cost/usage/RI/Savings Plans budget with notifications |
| [`aws_budgets_budget_action`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget_action) | Automated remediation: IAM policy, SCP, or SSM document |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3` |
| AWS Provider | `>= 5.0` |

---

## Usage

```hcl
module "budget" {
  source = "../../modules/cloud_financial_management/aws_budget"

  region = "us-east-1"

  tags = {
    environment = "production"
    team        = "finops"
    managed_by  = "terraform"
  }

  budgets = [
    {
      key          = "monthly-total"
      name         = "Monthly Total Account Spend"
      budget_type  = "COST"
      limit_amount = 5000
      limit_unit   = "USD"
      time_unit    = "MONTHLY"

      notifications = [
        {
          comparison_operator        = "GREATER_THAN"
          threshold                  = 80
          threshold_type             = "PERCENTAGE"
          notification_type          = "ACTUAL"
          subscriber_email_addresses = ["finops@example.com"]
        }
      ]
    }
  ]
}
```

---

## Inputs

### Top-Level Variables

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `region` | `string` | — | ✅ | AWS provider region |
| `tags` | `map(string)` | `{}` | — | Global tags applied to all resources |
| `budgets` | `list(object)` | `[]` | — | List of budget definitions — see object fields below |

### `budgets` Object Fields

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Unique stable key used as `for_each` index |
| `name` | `string` | — | ✅ | Display name in the AWS Budgets console |
| `budget_type` | `string` | — | ✅ | `COST` \| `USAGE` \| `RI_UTILIZATION` \| `RI_COVERAGE` \| `SAVINGS_PLANS_UTILIZATION` \| `SAVINGS_PLANS_COVERAGE` |
| `limit_amount` | `number` | — | ✅ | Budget threshold value (USD for COST; PERCENTAGE for RI/SP types) |
| `limit_unit` | `string` | — | ✅ | `USD` for cost; `PERCENTAGE` for RI/SP; service unit for USAGE |
| `time_unit` | `string` | `"MONTHLY"` | — | `DAILY` \| `MONTHLY` \| `QUARTERLY` \| `ANNUALLY` |
| `time_period_start` | `string` | `"2024-01-01_00:00"` | — | Budget tracking start date (`YYYY-MM-DD_HH:MM`) |
| `time_period_end` | `string` | `"2087-06-15_00:00"` | — | Budget tracking end date (default = effectively never) |
| `auto_adjust_type` | `string` | `null` | — | `HISTORICAL` or `FORECAST` — auto-recalculate the limit |
| `budget_adjustment_period` | `number` | `3` | — | Lookback months for `HISTORICAL` auto-adjust (1–12) |
| `cost_filters` | `list(object)` | `null` | — | Scope filters — see cost_filters fields below |
| `cost_types` | `object` | `null` | — | Charge-type inclusion flags — see cost_types fields below |
| `notifications` | `list(object)` | `null` | — | Alert thresholds — see notifications fields below |
| `actions` | `list(object)` | `null` | — | Automated remediation — see actions fields below |
| `tags` | `map(string)` | `null` | — | Per-budget tags merged with global tags |

### `cost_filters` Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | ✅ | Filter dimension: `Service`, `Region`, `LinkedAccount`, `InstanceType`, `TagKeyValue`, etc. |
| `values` | `list(string)` | ✅ | One or more filter values |

### `cost_types` Object Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `include_credit` | `bool` | `false` | Include AWS credits |
| `include_discount` | `bool` | `true` | Include EDP/volume discounts |
| `include_other_subscription` | `bool` | `true` | Include Marketplace subscriptions |
| `include_recurring` | `bool` | `true` | Include recurring reservation charges |
| `include_refund` | `bool` | `false` | Include refunds |
| `include_subscription` | `bool` | `true` | Include subscription charges |
| `include_support` | `bool` | `false` | Include AWS Support charges |
| `include_tax` | `bool` | `false` | Include sales tax |
| `include_upfront` | `bool` | `true` | Include upfront RI/Savings Plan payments |
| `use_amortized` | `bool` | `false` | Amortize upfront costs over reservation term |
| `use_blended` | `bool` | `false` | Use blended rates |

### `notifications` Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `comparison_operator` | `string` | ✅ | `GREATER_THAN` \| `LESS_THAN` \| `EQUAL_TO` |
| `threshold` | `number` | ✅ | Numeric threshold value |
| `threshold_type` | `string` | ✅ | `PERCENTAGE` or `ABSOLUTE_VALUE` |
| `notification_type` | `string` | ✅ | `ACTUAL` or `FORECASTED` |
| `subscriber_email_addresses` | `list(string)` | — | Email recipients |
| `subscriber_sns_topic_arns` | `list(string)` | — | SNS topic ARNs |

### `actions` Object Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `action_key` | `string` | ✅ | Unique key within the parent budget |
| `action_type` | `string` | ✅ | `APPLY_IAM_POLICY` \| `APPLY_SCP` \| `RUN_SSM_DOCUMENTS` |
| `approval_model` | `string` | ✅ | `AUTOMATIC` or `MANUAL` |
| `notification_type` | `string` | ✅ | `ACTUAL` or `FORECASTED` |
| `execution_role_arn` | `string` | ✅ | IAM role ARN trusting `budgets.amazonaws.com` |
| `action_threshold_type` | `string` | ✅ | `PERCENTAGE` or `ABSOLUTE_VALUE` |
| `action_threshold_value` | `number` | ✅ | Trigger threshold value |
| `iam_action_definition` | `object` | — | IAM policy attachment definition |
| `scp_action_definition` | `object` | — | SCP application definition |
| `ssm_action_definition` | `object` | — | SSM document execution definition |
| `subscribers` | `list(object)` | — | Notification subscribers on action execution |

---

## Outputs

| Name | Description |
|------|-------------|
| `budget_ids` | Map of budget key → resource ID |
| `budget_names` | Map of budget key → display name |
| `budget_types` | Map of budget key → budget type |
| `budget_limits` | Map of budget key → limit amount |
| `budget_action_ids` | Map of `<budget_key>_<action_key>` → action ID |

---

## Notes

- **Free tier:** The first 2 budgets per AWS account are free. Each additional budget costs $0.10/month. Budget actions cost $0.10/month each.
- **Global service:** AWS Budgets is not region-specific. The `region` variable only sets the provider endpoint.
- **Action IAM role:** `execution_role_arn` must have the `AWSBudgetsActionsWithAWSResourceControlPolicy` managed policy and trust `budgets.amazonaws.com`.
- **RI/SP budgets:** `limit_unit` must be `"PERCENTAGE"` for utilization/coverage budget types.
- **Management account:** `LinkedAccount` cost filters are only available from the Organizations management account.
