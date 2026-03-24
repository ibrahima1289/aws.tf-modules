# tf-plans/aws\_eventbridge

Terraform wrapper for the [AWS EventBridge module](../../modules/application_integration/aws_eventbridge/README.md).  
Deploy custom event buses, event-pattern and scheduled rules, multi-target routing, and event archives in a single plan.

---

## Architecture

```
tf-plans/aws_eventbridge/
├── provider.tf        ← Terraform + AWS provider constraints
├── variables.tf       ← Input declarations (mirrors module types)
├── locals.tf          ← created_date tag
├── main.tf            ← Module call
├── outputs.tf         ← Pass-through of module outputs
├── terraform.tfvars   ← 4 rule patterns + custom bus + archive
└── README.md          ← This file

modules/application_integration/aws_eventbridge/
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf            ← aws_cloudwatch_event_bus / _rule / _target / _archive
└── outputs.tf
```

```
terraform.tfvars
      │
      ├─ event_buses[]  ──► Custom event bus  ──► Bus resource policy (if policy_json)
      │
      └─ rules[]
            ├─ schedule_expression  ──► Scheduled rule  ──► Lambda (daily-report)
            ├─ event_pattern        ──► EC2 state-change rule  ──► SQS + Lambda (with DLQ)
            ├─ event_pattern        ──► OrderPlaced rule  ──► Step Functions
            └─ event_pattern        ──► S3 upload rule (DISABLED)  ──► Lambda

      archives[] ──► ecommerce bus archive (90-day retention)
```

---

## Files

| File | Purpose |
|------|---------|
| `provider.tf` | Terraform `>= 1.3` + AWS `>= 5.0` constraints, `provider "aws"` |
| `variables.tf` | Input variable declarations |
| `locals.tf` | `created_date` tag |
| `main.tf` | Calls `aws_eventbridge` module |
| `outputs.tf` | Exposes bus ARNs, rule ARNs, rule states, target IDs, archive ARNs |
| `terraform.tfvars` | Worked example — 4 rule patterns, 1 custom bus, 1 archive |

---

## Usage

```bash
cd tf-plans/aws_eventbridge
terraform init
terraform plan
terraform apply
```

---

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `region` | `string` | — | AWS provider region |
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `event_buses` | `list(object)` | `[]` | Custom event bus definitions |
| `rules` | `list(object)` | `[]` | Rule definitions with inline targets |
| `archives` | `list(object)` | `[]` | Event archive definitions |

See the [module README](../../modules/application_integration/aws_eventbridge/README.md) for the full nested object schema.

---

## Outputs

| Name | Description |
|------|-------------|
| `event_bus_arns` | Map of bus key → event bus ARN |
| `event_bus_names` | Map of bus key → event bus name |
| `rule_arns` | Map of rule key → rule ARN |
| `rule_names` | Map of rule key → rule name |
| `rule_states` | Map of rule key → `ENABLED` or `DISABLED` |
| `target_ids` | Map of `<rule_key>_<target_key>` → target ID |
| `archive_arns` | Map of archive key → archive ARN |

---

## `terraform.tfvars` Patterns

| Rule Key | Bus | Pattern | Targets |
|----------|-----|---------|---------|
| `daily-report` | `default` | Scheduled — `cron(0 8 * * ? *)` | Lambda — daily cost report; retry 3×/1hr |
| `ec2-state-change` | `default` | Event pattern — EC2 stopped/terminated | SQS (with DLQ) + Lambda (input transformer) |
| `order-placed` | `ecommerce-events` | Event pattern — `OrderPlaced` (CONFIRMED) | Step Functions state machine |
| `s3-upload` | `default` | Event pattern — S3 Object Created (DISABLED) | Lambda image processor |
| `ecommerce-archive` | `ecommerce-events` | Archive — all events, 90-day retention | — |
