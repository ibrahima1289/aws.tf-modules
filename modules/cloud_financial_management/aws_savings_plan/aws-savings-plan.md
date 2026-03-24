# AWS Savings Plans

> 💰 **Pricing:** [AWS Savings Plans Pricing](https://aws.amazon.com/savingsplans/pricing/) | **FAQ:** [Savings Plans FAQ](https://aws.amazon.com/savingsplans/faq/) | **User Guide:** [Savings Plans User Guide](https://docs.aws.amazon.com/savingsplans/latest/userguide/)

AWS Savings Plans is a flexible pricing model that offers up to **72% savings** on AWS compute usage in exchange for a 1- or 3-year commitment to a consistent hourly spend (in USD). Unlike Reserved Instances, Savings Plans apply automatically across eligible usage without instance-type or region lock-in, making them the recommended first choice for compute cost optimisation.

---

## Core Concepts

- **Commitment:** A fixed hourly dollar amount (e.g., `$5.00/hour`) you commit to for 1 or 3 years.
- **On-Demand Fallback:** Any usage above the committed amount is charged at standard On-Demand rates.
- **Automatic Application:** AWS applies Savings Plans automatically to your highest-discount eligible usage each hour — no manual assignment needed.
- **Payment Options:** All Upfront, Partial Upfront, or No Upfront. Greater upfront payment = larger discount.
- **Savings Plans vs. RIs:** Savings Plans are more flexible (no instance family/size/region lock for Compute SP); RIs may offer slightly higher discounts for very stable, predictable workloads.

---

## Savings Plans Types

| Type | Applies To | Flexibility | Max Discount |
|------|-----------|-------------|-------------|
| **Compute Savings Plans** | EC2 (any family, size, region, OS, tenancy), Lambda, Fargate | Highest — no restrictions | Up to 66% vs On-Demand |
| **EC2 Instance Savings Plans** | EC2 in a specific instance family + region | Must stay within family/region; any size/OS/tenancy | Up to 72% vs On-Demand |
| **SageMaker Savings Plans** | SageMaker ML instances (training, hosting, notebooks, Studio) | Instance family + region committed | Up to 64% vs On-Demand |

> **Best practice:** Start with **Compute Savings Plans** for maximum flexibility. Use **EC2 Instance Savings Plans** only when a workload is stable in a known instance family and region to capture the extra ~6% discount.

---

## Architecture

```
┌───────────────────────────────────────────────────────────────────────────┐
│                           AWS Account / Payer Account                     │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                  Savings Plans Commitment                           │  │
│  │                                                                     │  │
│  │   Type: Compute / EC2 Instance / SageMaker                          │  │
│  │   Term: 1-year | 3-year                                             │  │
│  │   Payment: All Upfront | Partial Upfront | No Upfront               │  │
│  │   Hourly Commitment: $X.XX/hr                                       │  │
│  └───────────────────────────┬─────────────────────────────────────────┘  │
│                              │ Auto-applied each hour                     │
│              ┌───────────────┼───────────────────┐                        │
│              ▼               ▼                   ▼                        │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐                │
│   │  EC2 Usage   │  │ Fargate/ECS  │  │  Lambda / EKS    │                │
│   │  (any family)│  │  (Fargate)   │  │  (duration-based)│                │
│   └──────────────┘  └──────────────┘  └──────────────────┘                │
│                                                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐ │
│   │  Usage beyond commitment  →  On-Demand rates (no penalty)           │ │
│   └─────────────────────────────────────────────────────────────────────┘ │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                  AWS Cost Explorer Integration                      │  │
│  │  • Savings Plans recommendations (coverage %, utilisation %)        │  │
│  │  • Hourly coverage and utilisation reports                          │  │
│  │  • Savings Plans Inventory (active, queued, retired plans)          │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## Plan Types Comparison

| Feature | Compute SP | EC2 Instance SP | SageMaker SP |
|---------|-----------|-----------------|-------------|
| EC2 — any region | ✅ | ❌ Region-locked | ❌ |
| EC2 — any family | ✅ | ❌ Family-locked | ❌ |
| EC2 — any size | ✅ | ✅ | ❌ |
| EC2 — any OS | ✅ | ✅ | ❌ |
| EC2 — any tenancy | ✅ | ✅ | ❌ |
| AWS Fargate | ✅ | ❌ | ❌ |
| AWS Lambda | ✅ | ❌ | ❌ |
| SageMaker | ❌ | ❌ | ✅ |
| Max discount | ~66% | ~72% | ~64% |

---

## Term & Payment Options

### Term

| Term | Discount vs No Upfront 1-year | Best For |
|------|-------------------------------|----------|
| **1-year** | Baseline | Moderate savings; shorter commitment |
| **3-year** | Up to ~15% additional savings | Long-lived workloads, infrastructure foundations |

### Payment

| Payment Option | How It Works | Best For |
|----------------|-------------|----------|
| **All Upfront** | Pay entire commitment at purchase | Maximum discount; available cash |
| **Partial Upfront** | ~50% upfront + rest in monthly bills | Balance discount with cash flow |
| **No Upfront** | Monthly bill only; no initial payment | Minimal upfront cost; lower discount |

---

## Savings Plans vs. Reserved Instances

| Dimension | Savings Plans | Reserved Instances |
|-----------|--------------|-------------------|
| Commitment currency | Hourly USD spend | Instance count |
| Instance flexibility | High (Compute SP) | Low (except Convertible RI) |
| Region flexibility | Yes (Compute SP) | No (except Convertible RI) |
| Purchase mechanism | Cost Explorer console / API | EC2/RDS/etc. console |
| Applies to Fargate | Yes (Compute SP) | No |
| Applies to Lambda | Yes (Compute SP) | No |
| Convertible exchange | N/A | Convertible RI only |
| Modification | Cannot modify after purchase | Standard RI: size/AZ modification allowed |
| Marketplace resale | Not supported | Supported (Standard RI) |
| Max discount | Up to 72% (EC2 Instance SP) | Up to 72% (Standard RI) |

---

## Utilisation & Coverage Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| **Utilisation (%)** | % of your hourly commitment that was applied to eligible usage | ≥ 90% (avoid waste) |
| **Coverage (%)** | % of eligible On-Demand spend covered by Savings Plans | ≥ 70–80% (cost goal) |

> Track both in **AWS Cost Explorer → Savings Plans → Utilisation** and **Coverage** reports. Set [AWS Budgets](../aws_budget/aws-budget.md) (`SAVINGS_PLANS_UTILIZATION` / `SAVINGS_PLANS_COVERAGE`) to alert when either metric drifts out of target range.

---

## How AWS Applies Savings Plans (Hourly Algorithm)

Each hour, the billing engine:

1. Collects all eligible On-Demand usage (EC2, Fargate, Lambda, SageMaker).
2. Sorts usage by **highest discount rate first** to maximise savings.
3. Applies your hourly commitment against that usage until the commitment is exhausted.
4. Charges remaining usage at standard On-Demand rates.

> **Multi-account (AWS Organizations):** By default, Savings Plans purchased in the management (payer) account are shared across all linked accounts. You can restrict sharing via the Savings Plans console.

---

## Purchasing via AWS CLI / API

Savings Plans cannot be directly managed by Terraform (no Terraform resource exists for purchasing). They are purchased through:

```bash
# 1. Get a purchase recommendation
aws savingsplans describe-savings-plans-offering-rates \
  --savings-plans-offering-ids <offering-id>

# 2. Create a Savings Plan
aws savingsplans create-savings-plan \
  --savings-plan-offering-id <offering-id> \
  --commitment 5.00 \
  --tags Key=Team,Value=platform
```

> **Terraform note:** The `aws_savingsplans_plan` data source can be used to look up existing plans for tagging or reporting. Actual purchases must be initiated outside Terraform via Console, CLI, or SDK.

---

## Recommendations Workflow

```
┌──────────────────────────────────────────────────────┐
│         AWS Cost Explorer Recommendations            │
│                                                      │
│  Input: 7, 30, or 60 days of historical usage        │
│  Output: Recommended commitment $/hr per plan type   │
│                                                      │
│  ┌────────────────────────────────────────────────┐  │
│  │ 1. Review recommendation (estimated savings)   │  │
│  │ 2. Choose term (1yr / 3yr)                     │  │
│  │ 3. Choose payment (All / Partial / No Upfront) │  │
│  │ 4. Set hourly commitment                       │  │
│  │ 5. Confirm purchase → Active within minutes    │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## Integration with AWS Budgets

Use [AWS Budgets](../aws_budget/aws-budget.md) to govern Savings Plans efficiency:

| Budget Type | What It Monitors | Alert When |
|-------------|-----------------|-----------|
| `SAVINGS_PLANS_UTILIZATION` | % of your commitment actually used | Drops below 80% → potential over-commitment |
| `SAVINGS_PLANS_COVERAGE` | % of eligible spend covered by Savings Plans | Drops below 70% → coverage gap, consider buying more |

```hcl
# Example budget snippet (in aws_budget module terraform.tfvars)
budgets = [
  {
    key         = "sp-utilization"
    name        = "savings-plans-utilization-check"
    budget_type = "SAVINGS_PLANS_UTILIZATION"
    limit_amount = "100"        # 100% target utilisation
    limit_unit   = "PERCENTAGE"
    time_unit    = "MONTHLY"
    notifications = [
      {
        key                        = "low-utilization"
        comparison_operator        = "LESS_THAN"
        threshold                  = 80
        threshold_type             = "PERCENTAGE"
        notification_type          = "ACTUAL"
        subscriber_email_addresses = ["finops@example.com"]
        subscriber_sns_topic_arns  = []
      }
    ]
  }
]
```

---

## Pricing

| Plan Type | Term | Payment | Typical Discount vs On-Demand |
|-----------|------|---------|-------------------------------|
| Compute SP | 1-year | No Upfront | ~40–50% |
| Compute SP | 1-year | All Upfront | ~48–55% |
| Compute SP | 3-year | All Upfront | ~60–66% |
| EC2 Instance SP | 1-year | No Upfront | ~50–60% |
| EC2 Instance SP | 1-year | All Upfront | ~58–66% |
| EC2 Instance SP | 3-year | All Upfront | ~65–72% |
| SageMaker SP | 1-year | No Upfront | ~35–50% |
| SageMaker SP | 3-year | All Upfront | ~55–64% |

> **Exact rates vary by instance family, region, and OS.** Always verify in the [Savings Plans Pricing page](https://aws.amazon.com/savingsplans/pricing/) or via `aws savingsplans describe-savings-plans-offering-rates` before purchasing.

---

## Cost Optimisation Tips

1. **Start with Compute Savings Plans** — maximum flexibility means you can shift workloads to new instance families, regions, or Fargate without losing your discount.
2. **Cover your stable baseline only** — buy for your lowest consistent hourly usage over the past 30–60 days. Leave variable/peak usage on On-Demand or Spot.
3. **Layer Spot Instances on top** — use Spot for interruptible batch/stateless workloads on top of your Savings Plan baseline to maximise savings.
4. **Monitor utilisation weekly** — a plan below 80% utilisation means you committed more than you use; consider rightsizing instances to fill the gap rather than buying less.
5. **Set utilisation and coverage Budgets** — use `SAVINGS_PLANS_UTILIZATION` and `SAVINGS_PLANS_COVERAGE` budget types with SNS alerts to catch drift early.
6. **3-year for foundations** — for long-lived infrastructure (NAT Gateways, bastion hosts, core services), a 3-year All Upfront plan yields the deepest discounts.
7. **Use Cost Explorer recommendations** — AWS analyses your last 7/30/60 days and recommends the optimal commitment amount to reach a target coverage percentage.

---

## Real-Life Examples

### 1. Platform team baseline coverage
A platform team runs 20 × m5.large EC2 instances continuously. Using a **Compute Savings Plan (1-year, No Upfront)** at `$2.50/hr` covers the baseline at ~50% discount, while auto-scaling peaks remain On-Demand.

### 2. Mixed compute modernisation
A team migrates workloads from EC2 to Fargate over 12 months. A **Compute Savings Plan** commitment continues to apply to both EC2 and Fargate usage throughout the migration — no plan changes needed.

### 3. SageMaker ML training cost control
A data science team runs daily training jobs on `ml.m5.xlarge`. A **SageMaker Savings Plan (1-year, Partial Upfront)** targeting their average daily GPU/CPU spend saves ~50% versus On-Demand training costs.

### 4. Multi-account organisation coverage
The finance team purchases a `$10/hr` **Compute Savings Plan** in the management account. It automatically covers EC2 + Fargate + Lambda usage across all linked developer and production accounts, providing org-wide cost governance with a single purchase.

### 5. Over-commitment recovery
A team notices their Savings Plans utilisation is 60% after downsizing. Rather than letting the commitment waste, they shift remaining On-Demand workloads to covered instance families and regions to bring utilisation back above 90% — recovering the lost value without purchasing anything new.

---

## Sources & References

- [AWS Savings Plans User Guide](https://docs.aws.amazon.com/savingsplans/latest/userguide/)
- [Savings Plans Pricing](https://aws.amazon.com/savingsplans/pricing/)
- [Savings Plans FAQ](https://aws.amazon.com/savingsplans/faq/)
- [Cost Explorer Savings Plans Recommendations](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-sp-recommendations.html)
- [Savings Plans vs Reserved Instances](https://docs.aws.amazon.com/savingsplans/latest/userguide/sp-compared-to-ri.html)
- [AWS Budgets – SAVINGS_PLANS_UTILIZATION](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html)
- [Terraform: aws_savingsplans_plan (data source)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/savingsplans_plan)
