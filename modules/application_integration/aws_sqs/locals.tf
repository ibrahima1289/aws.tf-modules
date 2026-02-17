// Locals for SQS module (created date, normalized settings)

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  queues = {
    for key, q in var.queues : key => merge(
      {
        fifo_queue                        = false
        content_based_deduplication       = false
        delay_seconds                     = 0
        maximum_message_size              = 262144
        message_retention_seconds         = 345600
        receive_wait_time_seconds         = 0
        visibility_timeout_seconds        = 30
        redrive_policy                    = null
        kms_master_key_id                 = null
        kms_data_key_reuse_period_seconds = null
        policy_json                       = null
        tags                              = {}
      },
      q,
      {
        // Ensure FIFO naming rule is respected when fifo_queue is true
        name = q.fifo_queue == true && !endswith(q.name, ".fifo") ? "${q.name}.fifo" : q.name
      }
    )
  }
}
