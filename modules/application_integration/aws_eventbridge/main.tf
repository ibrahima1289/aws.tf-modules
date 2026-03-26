# Terraform AWS EventBridge Module
# Manages EventBridge custom event buses, rules (event-pattern and scheduled),
# targets (Lambda, SQS, SNS, Step Functions, ECS, API destinations, and more),
# event archives for replay, and optional resource-based bus policies.
# Supports creating multiple buses, rules, and targets via for_each.

# ─── Step 1: Custom Event Buses ──────────────────────────────────────────────
# Create one custom event bus per entry in event_buses.
# The default AWS event bus always exists and is not managed here —
# reference it by setting bus_name = "default" in any rule.
resource "aws_cloudwatch_event_bus" "bus" {
  for_each = local.buses_map

  name = each.value.name

  # Merge global common tags with any per-bus tags.
  tags = merge(
    local.common_tags,
    each.value.tags
  )
}

# ─── Step 2: Bus Resource Policies (optional) ────────────────────────────────
# Attach a JSON resource policy to a custom bus only when policy_json is supplied.
# Use this for cross-account event publishing or org-wide access grants.
resource "aws_cloudwatch_event_bus_policy" "policy" {
  for_each = { for k, v in local.buses_map : k => v if v.policy_json != null }

  event_bus_name = aws_cloudwatch_event_bus.bus[each.key].name
  policy         = each.value.policy_json
}

# ─── Step 3: EventBridge Rules ───────────────────────────────────────────────
# Create one rule per entry in the rules list.
# Each rule routes events to its targets using either:
#   • event_pattern  — JSON filter matching specific event fields
#   • schedule_expression — cron(…) or rate(…) for time-based triggers
# Exactly one of the two must be set; validation in variables.tf enforces this.
resource "aws_cloudwatch_event_rule" "rule" {
  for_each = local.rules_map

  name           = each.value.name
  description    = each.value.description
  event_bus_name = each.value.bus_name

  # Step 3a: Event pattern — matches incoming events by source, detail-type, or any
  # field in the event JSON. Null when using a schedule expression.
  event_pattern = each.value.event_pattern

  # Step 3b: Schedule expression — triggers the rule on a fixed cadence.
  # Examples: "rate(5 minutes)", "cron(0 8 * * ? *)".
  # Null when using an event pattern.
  schedule_expression = each.value.schedule_expression

  # Step 3c: Rule state — ENABLED routes events; DISABLED pauses routing without deletion.
  state = each.value.enabled ? "ENABLED" : "DISABLED"

  # Step 3d: Optional IAM role for EventBridge to assume when delivering to
  # certain target types (e.g. Kinesis, SSM, Step Functions cross-account).
  role_arn = each.value.role_arn

  tags = merge(local.common_tags, each.value.tags)

  # Custom buses must exist before rules are associated with them.
  depends_on = [aws_cloudwatch_event_bus.bus]
}

# ─── Step 4: EventBridge Targets ─────────────────────────────────────────────
# Create targets for each rule; targets are flattened from the rules list and
# keyed as "<rule_key>_<target_key>" to ensure map uniqueness.
# One rule may have up to 5 targets.
resource "aws_cloudwatch_event_target" "target" {
  for_each = local.targets_map

  # Step 4a: Bind the target to its parent rule and event bus.
  rule           = aws_cloudwatch_event_rule.rule[each.value.rule_key].name
  event_bus_name = each.value.bus_name
  target_id      = each.value.target_id
  arn            = each.value.arn

  # Step 4b: Optional IAM role EventBridge assumes to invoke the target resource.
  role_arn = each.value.role_arn

  # Step 4c: Static JSON input — replaces the entire event before delivery.
  # Use when the target expects a fixed payload (mutually exclusive with
  # input_path and input_transformer).
  input = each.value.input

  # Step 4d: JSONPath string to extract a single sub-field from the event as input.
  # Mutually exclusive with input and input_transformer.
  input_path = each.value.input_path

  # Step 4e: Input transformer — map named event fields to a custom JSON template.
  # Useful for shaping event payloads to match what a target service expects.
  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  # Step 4f: Retry policy — control how long and how many times EventBridge retries
  # failed deliveries before sending to the dead-letter queue (if configured).
  dynamic "retry_policy" {
    for_each = each.value.retry_policy != null ? [each.value.retry_policy] : []
    content {
      maximum_event_age_in_seconds = retry_policy.value.max_event_age_in_seconds
      maximum_retry_attempts       = retry_policy.value.max_retry_attempts
    }
  }

  # Step 4g: Dead-letter queue — SQS ARN to receive events that cannot be delivered
  # after all retry attempts are exhausted. Prevents event loss.
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_arn != null ? [each.value.dead_letter_arn] : []
    content {
      arn = dead_letter_config.value
    }
  }

  # Step 4h: SQS FIFO target — required when the target queue is a FIFO queue.
  # Specifies the MessageGroupId used to group messages within the queue.
  dynamic "sqs_target" {
    for_each = each.value.sqs_message_group_id != null ? [each.value.sqs_message_group_id] : []
    content {
      message_group_id = sqs_target.value
    }
  }

  # Step 4i: ECS task target — launch ECS Fargate or EC2 tasks directly from an event.
  # Useful for event-driven batch processing or container workloads.
  dynamic "ecs_target" {
    for_each = each.value.ecs_target != null ? [each.value.ecs_target] : []
    content {
      task_definition_arn = ecs_target.value.task_definition_arn
      task_count          = ecs_target.value.task_count
      launch_type         = ecs_target.value.launch_type

      dynamic "network_configuration" {
        for_each = ecs_target.value.network_configuration != null ? [ecs_target.value.network_configuration] : []
        content {
          subnets          = network_configuration.value.subnets
          security_groups  = network_configuration.value.security_groups
          assign_public_ip = network_configuration.value.assign_public_ip
        }
      }
    }
  }
}

# ─── Step 5: Event Archives ───────────────────────────────────────────────────
# Create archives to retain events for later replay (debugging, backfilling,
# or testing new consumers against historical data).
# Set retention_days = 0 to retain events indefinitely.
resource "aws_cloudwatch_event_archive" "archive" {
  for_each = local.archives_map

  name        = each.value.name
  description = each.value.description

  # Reference a bus created in this module when bus_key is set;
  # otherwise use the supplied event_source_arn (e.g. default bus ARN).
  event_source_arn = each.value.bus_key != null ? aws_cloudwatch_event_bus.bus[each.value.bus_key].arn : each.value.event_source_arn

  # retention_days = 0 means events are retained indefinitely.
  retention_days = each.value.retention_days

  # Optional filter — archives only events matching this JSON pattern.
  # Omit (null) to archive all events flowing through the bus.
  event_pattern = each.value.event_pattern
}
