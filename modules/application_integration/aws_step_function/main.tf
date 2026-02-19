// AWS Step Functions root module
// Creates one or more Step Functions state machines using a map input.

resource "aws_sfn_state_machine" "step_function" {
  // Create one state machine per entry in the normalized map
  for_each = local.state_machines

  // Basic state machine settings
  name       = each.value.name
  role_arn   = each.value.role_arn
  definition = each.value.definition

  // State machine type: STANDARD or EXPRESS (default STANDARD)
  type = each.value.type

  // Optional logging configuration, created only when explicitly enabled
  dynamic "logging_configuration" {
    for_each = coalesce(each.value.logging_enabled, false) ? [1] : []

    content {
      include_execution_data = coalesce(each.value.logging_include_execution_data, false)
      level                  = each.value.logging_level

      // Optional CloudWatch Logs destination if ARN is provided
      log_destination = each.value.logging_log_group_arn
    }
  }

  // Optional X-Ray tracing configuration
  tracing_configuration {
    enabled = coalesce(each.value.tracing_enabled, false)
  }

  // Optional KMS key for encryption if provided
  dynamic "encryption_configuration" {
    for_each = each.value.kms_key_arn != null && each.value.kms_key_arn != "" ? [1] : []

    content {
      kms_key_id = each.value.kms_key_arn
    }
  }

  // Merge global and per-state-machine tags and add created date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

