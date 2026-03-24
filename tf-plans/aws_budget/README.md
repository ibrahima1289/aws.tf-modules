# tf-plans/aws\_budget

Terraform wrapper for the [AWS Budget module](../../modules/cloud_financial_management/aws_budget/README.md).  
Deploy multiple cost, usage, RI, and Savings Plans budgets with notifications and automated actions in a single plan.

---

## Architecture

```
tf-plans/aws_budget/
├── provider.tf        ← Terraform + AWS provider constraints
├── variables.tf       ← Input declarations (mirrors module types)
├── locals.tf          ← created_date tag
├── main.tf            ← Module call
├── outputs.tf         ← Pass-through of module outputs
├── terraform.tfvars   ← Example budgets: total spend, EC2, RI, auto-adjust, action
└── README.md          ← This file

modules/cloud_financial_management/aws_budget/
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf            ← aws_budgets_budget + aws_budgets_budget_action
└── outputs.tf
```

---

## Files

| File | Purpose |
|------|---------|
| `provider.tf` | Terraform `>= 1.3` + AWS `>= 5.0` constraints, `provider "aws"` |
| `variables.tf` | Input variable declarations |
| `locals.tf` | `created_date` tag |
| `main.tf` | Calls `aws_budget` module |
| `outputs.tf` | Exposes budget IDs, names, types, limits, action IDs |
| `terraform.tfvars` | Worked example — 5 budget patterns |

---

## Usage

```bash
cd tf-plans/aws_budget
terraform init
terraform plan
terraform apply
```

---

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `region` | `string` | — | AWS provider region (Budgets is a global service) |
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `budgets` | `list(object)` | `[]` | Budget definitions — see module README for full object schema |

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

## `terraform.tfvars` Patterns

| Budget Key | Type | Pattern |
|------------|------|---------|
| `monthly-total` | `COST` | Account-wide monthly spend; 3-tier alerts (80% actual, 100% actual, 110% forecast) |
| `ec2-monthly` | `COST` | EC2-scoped via `Service` cost filter; SNS + email alert at 90% |
| `auto-adjust-historical` | `COST` | Auto-adjusting limit from 3-month historical average |
| `ri-utilization` | `RI_UTILIZATION` | Alert when RI utilization drops below 80% (`LESS_THAN`) |
| `monthly-with-action` | `COST` | Auto-attach deny-all IAM policy when spend exceeds 100% |

---

## Notes

- **Free tier:** First 2 budgets per account are free; $0.10/budget/month after that.
- **Actions:** Budget actions require an IAM execution role trusting `budgets.amazonaws.com`. See the [module README](../../modules/cloud_financial_management/aws_budget/README.md#notes) for policy details.
- **RI/SP budgets:** Set `limit_unit = "PERCENTAGE"` and use `LESS_THAN` comparison for utilization alerts.
