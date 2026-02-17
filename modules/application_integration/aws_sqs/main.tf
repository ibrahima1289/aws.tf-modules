// Root module for AWS SQS queues
// Supports creating multiple queues with safe defaults and no null values.

resource "aws_sqs_queue" "sqs" {
  // Create one queue per entry in the queues map
  for_each = local.queues

  // Queue name (FIFO suffix enforced in locals when fifo_queue = true)
  name = each.value.name

  // Core settings for reliability and behavior
  // Coerce fifo flag to a real boolean to avoid null conditions
  fifo_queue = each.value.fifo_queue == true

  // Only enable content-based deduplication when FIFO is enabled; otherwise omit
  content_based_deduplication = each.value.fifo_queue == true ? each.value.content_based_deduplication : null
  delay_seconds               = each.value.delay_seconds
  max_message_size            = each.value.maximum_message_size
  message_retention_seconds   = each.value.message_retention_seconds
  receive_wait_time_seconds   = each.value.receive_wait_time_seconds
  visibility_timeout_seconds  = each.value.visibility_timeout_seconds

  // Dead-letter queue policy (only when provided)
  // AWS expects a JSON-encoded string for redrive_policy, not a nested block.
  redrive_policy = each.value.redrive_policy == null ? null : jsonencode({
    deadLetterTargetArn = each.value.redrive_policy.dead_letter_target_arn
    maxReceiveCount     = each.value.redrive_policy.max_receive_count
  })

  // Server-side encryption (only when KMS key is set)
  kms_master_key_id                 = each.value.kms_master_key_id
  kms_data_key_reuse_period_seconds = each.value.kms_data_key_reuse_period_seconds

  // Tags: global + per-queue + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

// Optional queue policies applied when policy_json is provided
resource "aws_sqs_queue_policy" "sqs" {
  for_each = {
    for key, q in local.queues : key => q if q.policy_json != null
  }

  queue_url = aws_sqs_queue.sqs[each.key].id
  policy    = each.value.policy_json
}
