# AWS Budgets

> 🔧 **Terraform Module:** [AWS Budget Module](README.md) | **Wrapper:** [tf-plans/aws_budget](../../../../../tf-plans/aws_budget/README.md) | **Pricing:** [AWS Budgets Pricing](https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/)

AWS Budgets is a cost management service that lets you set custom budgets for cost and usage, track actual and forecasted spend against those budgets, and trigger SNS/email notifications or automated remediation actions when thresholds are crossed.

---

## Core Concepts

- **Budget Types:** Monitor spend (COST), resource consumption (USAGE), Reserved Instance efficiency (RI_UTILIZATION / RI_COVERAGE), or Savings Plans efficiency (SAVINGS_PLANS_UTILIZATION / SAVINGS_PLANS_COVERAGE).
- **Budget Limit:** A numeric threshold — in USD for cost budgets or service units for usage budgets. Can be fixed or auto-adjusted from historical/forecasted data.
- **Time Period:** DAILY, MONTHLY, QUARTERLY, or ANNUALLY. Monthly budgets reset on the first of each month.
- **Cost Filters:** Narrow a budget's scope to specific services, linked accounts, regions, instance types, usage types, or tag key-value pairs.
- **Cost Types:** Control which charge categories count toward the budget (blended vs. unblended, credits, refunds, support, taxes, etc.).
- **Notifications:** Alert subscribers (email addresses or SNS topics) when actual or forecasted spend crosses a threshold.
- **Budget Actions:** Automatically apply an IAM policy, SCP, or SSM action when a threshold is breached — without human intervention.
- **Auto-Adjust:** Dynamically recalculate the budget limit from historical spend (lookback period) or AWS forecast data.

---

## Budget Types

| Budget Type | Monitors | Unit | Typical Use |
|-------------|----------|------|-------------|
| `COST` | Dollar spend | USD | Total account, service, or team spend alerts |
| `USAGE` | Service consumption | Service-specific (Hrs, GB, etc.) | EC2 hours, S3 storage, data transfer limits |
| `RI_UTILIZATION` | % of RI hours used | PERCENTAGE | Detect underutilised Reserved Instances |
| `RI_COVERAGE` | % of on-demand hours covered by RIs | PERCENTAGE | Track RI coverage progress |
| `SAVINGS_PLANS_UTILIZATION` | % of Savings Plan commitment used | PERCENTAGE | Detect underutilised Savings Plans |
| `SAVINGS_PLANS_COVERAGE` | % of eligible spend covered by Savings Plans | PERCENTAGE | Track Savings Plans coverage progress |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        AWS Account                               │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                    aws_budgets_budget                    │    │
│  │  ┌────────────┐   ┌────────────┐   ┌──────────────────┐  │    │
│  │  │ Time Period│   │Cost Filters│   │   Cost Types     │  │    │
│  │  │ DAILY /    │   │ Service    │   │ include_credit   │  │    │
│  │  │ MONTHLY /  │   │ Region     │   │ include_tax      │  │    │
│  │  │ QUARTERLY  │   │ Account    │   │ use_amortized    │  │    │
│  │  │ ANNUALLY   │   │ Tag        │   │ ...              │  │    │
│  │  └────────────┘   └────────────┘   └──────────────────┘  │    │
│  │                                                          │    │
│  │  ┌──────────────────────────────────────────────────────┐│    │
│  │  │              Notifications (0..n)                    ││    │
│  │  │  threshold=80% ACTUAL  → Email / SNS                 ││    │
│  │  │  threshold=100% ACTUAL → Email / SNS                 ││    │
│  │  │  threshold=110% FORECAST → Email / SNS               ││    │
│  │  └──────────────────────────────────────────────────────┘│    │
│  └──────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │             aws_budgets_budget_action (optional)         │    │
│  │  APPLY_IAM_POLICY  → attaches policy to roles/users      │    │
│  │  APPLY_SCP         → applies SCP to OU/account           │    │
│  │  RUN_SSM_DOCUMENTS → targets EC2/RDS instances           │    │
│  └──────────────────────────────────────────────────────────┘    │
│         │                    │                                   │
│         ▼                    ▼                                   │
│  ┌────────────┐    ┌──────────────────┐                          │
│  │ SNS Topic  │    │   Email Address  │                          │
│  └────────────┘    └──────────────────┘                          │
└──────────────────────────────────────────────────────────────────┘
```

---

## Budget Actions

Budget actions provide automated, policy-driven cost control. Three action types are supported:

| Action Type | Definition | Effect |
|-------------|------------|--------|
| `APPLY_IAM_POLICY` | `iam_action_definition` | Attaches a managed or inline IAM policy to roles, groups, or users |
| `APPLY_SCP` | `scp_action_definition` | Applies an Organizations Service Control Policy to target account or OU |
| `RUN_SSM_DOCUMENTS` | `ssm_action_definition` | Runs an SSM Automation document to stop/isolate EC2 or RDS instances |

> **Execution role:** The `execution_role_arn` must trust `budgets.amazonaws.com` and carry the `AWSBudgetsActionsWithAWSResourceControlPolicy` managed policy.

---

## Auto-Adjust Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `HISTORICAL` | Recalculates the limit from average spend over `budget_adjustment_period` months | Variable/seasonal spend where a fixed threshold causes false alerts |
| `FORECAST` | Uses AWS Cost Explorer ML forecast to project the budget limit | Forward-looking budgeting for growing workloads |

---

## Cost Types Reference

| Field | Default | Description |
|-------|---------|-------------|
| `include_credit` | `false` | Include AWS credits in budget calculations |
| `include_discount` | `true` | Include EDP or volume discounts |
| `include_other_subscription` | `true` | Include AWS Marketplace subscriptions |
| `include_recurring` | `true` | Include recurring reservation charges |
| `include_refund` | `false` | Include refunds |
| `include_subscription` | `true` | Include subscription charges |
| `include_support` | `false` | Include AWS Support plan charges |
| `include_tax` | `false` | Include sales tax |
| `include_upfront` | `true` | Include upfront RI/Savings Plan payments |
| `use_amortized` | `false` | Amortize upfront costs over the reservation term |
| `use_blended` | `false` | Use blended rates (averaged across all instances) |

---

## Cost Filters Reference

| Filter Name | Example Values | Description |
|-------------|---------------|-------------|
| `Service` | `Amazon Elastic Compute Cloud - Compute` | Scope to a specific AWS service |
| `Region` | `us-east-1`, `eu-west-1` | Scope to one or more regions |
| `LinkedAccount` | `123456789012` | Scope to a specific linked account (management account only) |
| `InstanceType` | `m5.large`, `t3.medium` | Scope to specific EC2 instance types |
| `UsageType` | `BoxUsage:m5.large` | Fine-grained usage dimension |
| `TagKeyValue` | `Key$Value` | Scope to resources with a specific tag value |

---

## Pricing

| Tier | Free budgets | Paid budgets |
|------|-------------|-------------|
| **Free tier (always)** | First 2 budgets per account | — |
| **Per budget/month** | $0.00 | $0.10 |
| **Budget actions** | — | $0.10 per action/month |

> **Example:** 10 COST budgets + 5 actions = (8 × $0.10) + (5 × $0.10) = **$1.30/month**

---

## Real-Life Examples

### 1. Team-level cost allocation
Create one COST budget per team tag, alerting at 80% and 100% to keep teams within their allocated cloud spend.

### 2. RI governance
Create RI_UTILIZATION budgets for EC2, RDS, and ElastiCache — alert when utilization drops below 70% to trigger RI right-sizing review.

### 3. Dev environment guardrail
Use a budget action to auto-attach a deny-all IAM policy to a developer role when the dev account exceeds its monthly budget, preventing further resource creation until reviewed.

### 4. Auto-adjusting seasonal budget
Use `auto_adjust_type = "HISTORICAL"` with a 3-month lookback so the budget limit automatically reflects seasonal traffic spikes without manual updates.
