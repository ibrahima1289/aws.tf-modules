// Locals for Kinesis module (created date, normalized stream and Firehose settings)

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  streams = {
    for key, s in var.streams : key => merge(
      {
        stream_mode            = "PROVISIONED" # default to provisioned mode for better cost control, but allow on-demand when specified
        shard_count            = 1             # default shard count for provisioned streams
        retention_period_hours = 24            # default retention of 24 hours (can be increased up to 8760 hours / 365 days)
        shard_level_metrics    = []
        encryption_enabled     = false
        kms_key_arn            = null
        tags                   = {}
      },
      s
    )
  }

  firehoses = {
    for key, f in var.firehoses : key => merge(
      {
        s3_prefix                     = null
        s3_buffer_size                = 5
        s3_buffer_interval            = 300
        kms_key_arn                   = null
        http_endpoint_url             = null
        http_endpoint_name            = null
        http_endpoint_access_key      = null
        http_endpoint_buffer_size     = 5
        http_endpoint_buffer_interval = 300
        tags                          = {}
      },
      f
    )
  }
}
