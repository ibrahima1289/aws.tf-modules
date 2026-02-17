// Locals for SNS module (created date, normalized topic settings)

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  topics = {
    for key, t in var.topics : key => merge(
      {
        fifo_topic                  = false
        content_based_deduplication = false
        display_name                = null
        kms_master_key_id           = null
        policy_json                 = null
        delivery_policy             = null
        tags                        = {}
        subscriptions               = []
      },
      t,
      {
        // Ensure FIFO naming rule is respected when fifo_topic is true
        name = t.fifo_topic == true && !endswith(t.name, ".fifo") ? "${t.name}.fifo" : t.name
      }
    )
  }

  // Flatten subscriptions across topics for subscription resources
  subscriptions = flatten([
    for topic_key, t in local.topics : [
      for idx, s in(t.subscriptions == null ? [] : t.subscriptions) : {
        key                = "${topic_key}-${idx}"
        topic_key          = topic_key
        protocol           = s.protocol
        endpoint           = s.endpoint
        raw_message        = try(s.raw_message_delivery, null)
        filter_policy      = try(s.filter_policy, null)
        redrive_policy_arn = try(s.redrive_policy_arn, null)
      }
    ]
  ])
}
