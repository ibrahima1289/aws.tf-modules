# Variables for AWS EventBridge Module

variable "region" {
  description = "AWS region where EventBridge resources are deployed."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all EventBridge resources created by this module."
  type        = map(string)
  default     = {}
}

# ─── Event Buses ──────────────────────────────────────────────────────────────
# List of custom event bus definitions.
# The default AWS event bus is not managed here — reference it by name "default" in rules.
#
# Required per entry:
#   key   — Stable unique string key used as the for_each index (e.g. "ecommerce").
#   name  — Event bus name in the AWS console (e.g. "ecommerce-events").
#
# Optional per entry:
#   policy_json — JSON resource policy to attach (cross-account publishing, org-wide access).
#   tags        — Per-bus tags merged with global tags.
variable "event_buses" {
  description = "List of custom event bus definitions. Each entry creates one aws_cloudwatch_event_bus resource."
  type = list(object({
    key         = string
    name        = string
    policy_json = optional(string)
    tags        = optional(map(string), {})
  }))
  default = []
}

# ─── Rules ────────────────────────────────────────────────────────────────────
# List of EventBridge rule definitions.
# Each entry creates one aws_cloudwatch_event_rule and its associated targets.
#
# Required per entry:
#   key  — Stable unique string key used as the for_each index.
#   name — Rule name displayed in the AWS console.
#
# Optional per entry:
#   description         — Human-readable description of the rule's purpose.
#   bus_name            — Target event bus name. Defaults to "default" (AWS default bus).
#   event_pattern       — JSON string filter. Mutually exclusive with schedule_expression.
#   schedule_expression — cron(…) or rate(…) expression. Mutually exclusive with event_pattern.
#   enabled             — Whether the rule is active. Defaults to true.
#   role_arn            — IAM role for EventBridge to assume when invoking certain targets.
#   tags                — Per-rule tags merged with global tags.
#   targets             — List of target definitions (see nested type below).
#
# Constraint: Exactly one of event_pattern or schedule_expression must be set per rule.
variable "rules" {
  description = "List of EventBridge rule definitions. Each entry creates one aws_cloudwatch_event_rule and its aws_cloudwatch_event_target resources."
  type = list(object({
    key                 = string
    name                = string
    description         = optional(string, "")
    bus_name            = optional(string, "default")
    event_pattern       = optional(string)
    schedule_expression = optional(string)
    enabled             = optional(bool, true)
    role_arn            = optional(string)
    tags                = optional(map(string), {})

    # Targets — each entry creates one aws_cloudwatch_event_target bound to this rule.
    #
    # Required per target:
    #   target_key — Stable unique key scoped to the parent rule.
    #   target_id  — Logical identifier for the target within the rule (displayed in console).
    #   arn        — ARN of the target resource (Lambda, SQS, SNS, Step Functions, etc.).
    #
    # Optional per target:
    #   role_arn             — IAM role ARN for EventBridge to assume to invoke the target.
    #   input                — Static JSON string to send instead of the matched event.
    #   input_path           — JSONPath to extract a sub-field of the event as input.
    #   input_transformer    — Map event fields to a custom JSON template.
    #   retry_policy         — Max retry attempts and max event age for failed deliveries.
    #   dead_letter_arn      — SQS ARN for undeliverable events after retries are exhausted.
    #   sqs_message_group_id — MessageGroupId for FIFO SQS targets.
    #   ecs_target           — ECS task launch configuration (Fargate or EC2).
    targets = optional(list(object({
      target_key           = string
      target_id            = string
      arn                  = string
      role_arn             = optional(string)
      input                = optional(string)
      input_path           = optional(string)
      sqs_message_group_id = optional(string)
      dead_letter_arn      = optional(string)

      # Input transformer: extract named fields from the event and inject them
      # into a custom template before delivery to the target.
      input_transformer = optional(object({
        input_paths    = map(string) # JSONPath expressions keyed by variable name
        input_template = string      # Template string using <variable_name> placeholders
      }))

      # Retry policy: controls delivery retry behaviour for failed events.
      retry_policy = optional(object({
        max_event_age_in_seconds = optional(number, 86400) # Default: 24 hours
        max_retry_attempts       = optional(number, 185)   # Default: AWS maximum
      }))

      # ECS task target: launch ECS tasks (Fargate or EC2) in response to events.
      ecs_target = optional(object({
        task_definition_arn = string
        task_count          = optional(number, 1)
        launch_type         = optional(string, "FARGATE")
        network_configuration = optional(object({
          subnets          = list(string)
          security_groups  = optional(list(string), [])
          assign_public_ip = optional(bool, false)
        }))
      }))
    })), [])
  }))

  default = []

  validation {
    condition = alltrue([
      for r in var.rules :
      (r.event_pattern != null) != (r.schedule_expression != null)
    ])
    error_message = "Each rule must have exactly one of 'event_pattern' or 'schedule_expression' — not both, not neither."
  }

  validation {
    condition     = length(var.rules) == length(distinct([for r in var.rules : r.key]))
    error_message = "Each rule 'key' must be unique across all rules."
  }
}

# ─── Archives ─────────────────────────────────────────────────────────────────
# List of event archive definitions.
# Archives retain events from an event bus for a defined retention period
# so they can be replayed for debugging, backfilling, or testing new consumers.
#
# Required per entry:
#   key  — Stable unique string key used as the for_each index.
#   name — Archive name (e.g. "ecommerce-events-archive").
#
# Optional per entry:
#   description      — Human-readable description of the archive.
#   bus_key          — Key of a bus created in this module. Mutually exclusive with event_source_arn.
#   event_source_arn — ARN of a pre-existing bus (e.g. the default bus). Use when bus_key is not set.
#   retention_days   — Days to retain events. 0 means indefinite retention.
#   event_pattern    — JSON filter to archive only matching events. Null archives all events.
variable "archives" {
  description = "List of event archive definitions. Each entry creates one aws_cloudwatch_event_archive resource."
  type = list(object({
    key              = string
    name             = string
    description      = optional(string, "")
    bus_key          = optional(string)
    event_source_arn = optional(string)
    retention_days   = optional(number, 0)
    event_pattern    = optional(string)
  }))
  default = []
}
