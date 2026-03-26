# AWS EventBridge Module

> 📖 **Service Guide:** [aws-eventbridge.md](aws-eventbridge.md) | **Wrapper:** [tf-plans/aws_eventbridge](../../../tf-plans/aws_eventbridge/README.md) | **Pricing:** [EventBridge Pricing](https://aws.amazon.com/eventbridge/pricing/)

Terraform module for [Amazon EventBridge](https://aws.amazon.com/eventbridge/) — custom event buses, event-pattern and scheduled rules, multi-target routing (Lambda, SQS, SNS, Step Functions, ECS, API destinations), event archives, and optional bus resource policies. Supports creating all resources at once via `for_each`-keyed maps.

---

## Architecture

```
modules/application_integration/aws_eventbridge/
├── providers.tf    ← Terraform >= 1.3, AWS >= 5.0
├── variables.tf    ← event_buses, rules (+ targets), archives, region, tags
├── locals.tf       ← created_date, common_tags, buses_map, rules_map, targets_map, archives_map
├── main.tf         ← aws_cloudwatch_event_bus / _bus_policy / _rule / _target / _archive
├── outputs.tf      ← event_bus_arns, rule_arns, rule_states, target_ids, archive_arns
├── aws-eventbridge.md  ← Service overview, concepts, use cases
└── README.md           ← This file
```

```
┌──────────────────────────────────────────────────────────────────────┐
│                       EventBridge Module                             │
│                                                                      │
│  event_buses[] ──► aws_cloudwatch_event_bus                          │
│                    aws_cloudwatch_event_bus_policy (if policy_json)  │
│                                                                      │
│  rules[] ────────► aws_cloudwatch_event_rule                         │
│    bus_name           (event_pattern OR schedule_expression)         │
│    targets[] ───────► aws_cloudwatch_event_target ──► Lambda         │
│                          input / input_path                    ──► SQS
│                          input_transformer                     ──► SNS
│                          retry_policy                          ──► Step Functions
│                          dead_letter_config (DLQ)              ──► ECS Task
│                          sqs_target (FIFO)                     ──► API Destination
│                          ecs_target                                  │
│                                                                      │
│  archives[] ─────► aws_cloudwatch_event_archive                      │
│                    (bus_key → created bus ARN,                       │
│                     or event_source_arn for default/external bus)    │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Resources

| Resource | Purpose |
|----------|---------|
| [`aws_cloudwatch_event_bus`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | Custom event bus |
| [`aws_cloudwatch_event_bus_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | Resource policy for cross-account / org access |
| [`aws_cloudwatch_event_rule`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | Event-pattern or scheduled routing rule |
| [`aws_cloudwatch_event_target`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | Target bound to a rule (Lambda, SQS, SNS, SFN, ECS, …) |
| [`aws_cloudwatch_event_archive`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_archive) | Event archive for retention and replay |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3` |
| AWS Provider | `>= 5.0` |

---

## Usage

```hcl
module "eventbridge" {
  source = "../../modules/application_integration/aws_eventbridge"

  region = "us-east-1"

  tags = {
    environment = "production"
    team        = "platform"
    managed_by  = "terraform"
  }

  event_buses = [
    {
      key  = "ecommerce"
      name = "ecommerce-events"
    }
  ]

  rules = [
    {
      key                 = "daily-report"
      name                = "daily-cost-report"
      description         = "Daily cost report at 08:00 UTC"
      bus_name            = "default"
      schedule_expression = "cron(0 8 * * ? *)"

      targets = [
        {
          target_key = "report-lambda"
          target_id  = "DailyCostReportLambda"
          arn        = "arn:aws:lambda:us-east-1:123456789012:function:daily-cost-report"
        }
      ]
    },
    {
      key      = "order-placed"
      name     = "order-placed-fulfillment"
      bus_name = "ecommerce-events"
      event_pattern = jsonencode({
        source      = ["com.myapp.orders"]
        detail-type = ["OrderPlaced"]
      })

      targets = [
        {
          target_key = "order-sfn"
          target_id  = "OrderFulfillmentStateMachine"
          arn        = "arn:aws:states:us-east-1:123456789012:stateMachine:order-fulfillment"
          role_arn   = "arn:aws:iam::123456789012:role/EventBridgeStepFunctionsRole"
        }
      ]
    }
  ]

  archives = [
    {
      key            = "ecommerce-archive"
      name           = "ecommerce-events-archive"
      bus_key        = "ecommerce"
      retention_days = 90
    }
  ]
}
```

---

## Inputs

### Top-level

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `region` | `string` | — | ✅ | AWS region for the provider |
| `tags` | `map(string)` | `{}` | ❌ | Global tags applied to all resources |
| `event_buses` | `list(object)` | `[]` | ❌ | Custom event bus definitions |
| `rules` | `list(object)` | `[]` | ❌ | Rule definitions (event-pattern or scheduled) |
| `archives` | `list(object)` | `[]` | ❌ | Event archive definitions |

### `event_buses[]` object

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key for `for_each` |
| `name` | `string` | — | ✅ | Event bus name |
| `policy_json` | `string` | `null` | ❌ | JSON resource policy for cross-account access |
| `tags` | `map(string)` | `{}` | ❌ | Per-bus tags |

### `rules[]` object

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key for `for_each` |
| `name` | `string` | — | ✅ | Rule name |
| `description` | `string` | `""` | ❌ | Rule description |
| `bus_name` | `string` | `"default"` | ❌ | Event bus name to attach the rule to |
| `event_pattern` | `string` | `null` | ❌ ¹ | JSON event filter pattern |
| `schedule_expression` | `string` | `null` | ❌ ¹ | `rate(…)` or `cron(…)` expression |
| `enabled` | `bool` | `true` | ❌ | `true` → ENABLED; `false` → DISABLED |
| `role_arn` | `string` | `null` | ❌ | IAM role for EventBridge to assume |
| `tags` | `map(string)` | `{}` | ❌ | Per-rule tags |
| `targets` | `list(object)` | `[]` | ❌ | Target definitions (see below) |

> ¹ Exactly one of `event_pattern` or `schedule_expression` must be set per rule.

### `rules[*].targets[]` object

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `target_key` | `string` | — | ✅ | Unique key scoped to parent rule |
| `target_id` | `string` | — | ✅ | Logical target ID shown in console |
| `arn` | `string` | — | ✅ | Target resource ARN |
| `role_arn` | `string` | `null` | ❌ | IAM role for EventBridge to invoke target |
| `input` | `string` | `null` | ❌ | Static JSON replacing the event |
| `input_path` | `string` | `null` | ❌ | JSONPath to extract a sub-field |
| `input_transformer` | `object` | `null` | ❌ | Map event fields to a custom template |
| `retry_policy` | `object` | `null` | ❌ | `{ max_event_age_in_seconds, max_retry_attempts }` |
| `dead_letter_arn` | `string` | `null` | ❌ | SQS ARN for undeliverable events |
| `sqs_message_group_id` | `string` | `null` | ❌ | MessageGroupId for FIFO SQS targets |
| `ecs_target` | `object` | `null` | ❌ | ECS task launch config (see below) |

### `rules[*].targets[*].ecs_target` object

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `task_definition_arn` | `string` | — | ✅ | ECS task definition ARN |
| `task_count` | `number` | `1` | ❌ | Number of task instances to launch |
| `launch_type` | `string` | `"FARGATE"` | ❌ | `FARGATE` or `EC2` |
| `network_configuration` | `object` | `null` | ❌ | `{ subnets, security_groups, assign_public_ip }` |

### `archives[]` object

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key for `for_each` |
| `name` | `string` | — | ✅ | Archive name |
| `description` | `string` | `""` | ❌ | Archive description |
| `bus_key` | `string` | `null` | ❌ | Key of a bus created in this module |
| `event_source_arn` | `string` | `null` | ❌ | Direct bus ARN (use when `bus_key` is null) |
| `retention_days` | `number` | `0` | ❌ | Days to retain events; `0` = indefinite |
| `event_pattern` | `string` | `null` | ❌ | JSON filter; null archives all events |

---

## Outputs

| Name | Description |
|------|-------------|
| `event_bus_arns` | Map of bus key → custom event bus ARN |
| `event_bus_names` | Map of bus key → custom event bus name |
| `rule_arns` | Map of rule key → rule ARN |
| `rule_names` | Map of rule key → rule name |
| `rule_states` | Map of rule key → `ENABLED` or `DISABLED` |
| `target_ids` | Map of `<rule_key>_<target_key>` → target ID |
| `archive_arns` | Map of archive key → archive ARN |
