// Root module for AWS SNS topics and subscriptions
// Supports creating multiple topics with optional subscriptions and safe defaults.

resource "aws_sns_topic" "sns" {
  // Create one topic per entry in the topics map
  for_each = local.topics

  // Topic name (FIFO suffix enforced in locals when fifo_topic = true)
  name = each.value.name

  // FIFO configuration
  fifo_topic                  = each.value.fifo_topic == true
  content_based_deduplication = each.value.fifo_topic == true ? each.value.content_based_deduplication : null

  // Optional configuration
  display_name      = each.value.display_name
  kms_master_key_id = each.value.kms_master_key_id
  policy            = each.value.policy_json
  delivery_policy   = each.value.delivery_policy

  // Tags: global + per-topic + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

// Optional subscriptions for each topic, flattened across all topics
resource "aws_sns_topic_subscription" "sns" {
  for_each = { for s in local.subscriptions : s.key => s }

  topic_arn = aws_sns_topic.sns[each.value.topic_key].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  // Optional subscription settings
  raw_message_delivery = each.value.raw_message
  filter_policy        = each.value.filter_policy

  // Redrive policy for DLQ (if ARN provided)
  redrive_policy = each.value.redrive_policy_arn == null ? null : jsonencode({
    deadLetterTargetArn = each.value.redrive_policy_arn
  })
}
