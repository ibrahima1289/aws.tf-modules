# Example terraform.tfvars for AWS Kinesis wrapper

region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

streams = {
  # Basic provisioned stream using defaults
  example_standard_minimal = {
    name        = "example-kinesis-stream-minimal"
    stream_mode = "ON_DEMAND" # default is PROVISIONED, but using ON_DEMAND for a minimal example
    # shard_count = 1 # ignored when stream_mode is ON_DEMAND, but required when PROVISIONED
  }

  # Provisioned stream with explicit shard count, retention, metrics, and encryption
  example_standard_full = {
    name                   = "example-kinesis-stream-full"
    stream_mode            = "PROVISIONED"
    shard_count            = 2
    retention_period_hours = 72
    shard_level_metrics    = ["IncomingBytes", "OutgoingRecords"]

    encryption_enabled = true
    kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000" # replace with your KMS key ARN

    tags = {
      Purpose = "analytics-stream-full"
    }
  }

  # On-demand stream (no shard_count required)
  example_on_demand = {
    name        = "example-kinesis-stream-on-demand"
    stream_mode = "ON_DEMAND"

    retention_period_hours = 24
    shard_level_metrics    = ["IncomingRecords"]

    tags = {
      Purpose = "analytics-stream-on-demand"
    }
  }

  # On-demand stream with higher retention and multiple shard-level metrics
  example_on_demand_advanced = {
    name        = "example-kinesis-stream-on-demand-advanced"
    stream_mode = "ON_DEMAND"

    retention_period_hours = 168 # 7 days
    shard_level_metrics    = ["IncomingBytes", "IncomingRecords", "OutgoingBytes", "OutgoingRecords"]

    tags = {
      Purpose = "analytics-stream-on-demand-advanced"
    }
  }
}

firehoses = {
  # Basic Firehose delivery stream to S3
  example_firehose_s3 = {
    name        = "example-firehose-to-s3"
    destination = "extended_s3"
    role_arn    = "arn:aws:iam::123456789012:role/example-firehose-role" # replace with your role ARN

    s3_bucket_arn      = "arn:aws:s3:::my-firehose-bucket" # replace with your bucket ARN
    s3_prefix          = "firehose/"
    s3_buffer_size     = 5
    s3_buffer_interval = 300

    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-1111-1111-1111-111111111111" # optional: KMS key for Firehose encryption

    tags = {
      Purpose = "analytics-firehose-s3"
    }
  }

  # Firehose delivery stream to an HTTP endpoint
  example_firehose_http = {
    name        = "example-firehose-to-http"
    destination = "http_endpoint"
    role_arn    = "arn:aws:iam::123456789012:role/example-firehose-role" # replace with your role ARN

    # S3 configuration still required as a backup/failed delivery bucket
    s3_bucket_arn      = "arn:aws:s3:::my-firehose-backup-bucket" # replace with your bucket ARN
    s3_prefix          = "firehose-http-backup/"
    s3_buffer_size     = 5
    s3_buffer_interval = 300

    http_endpoint_url             = "https://example.com/firehose-endpoint" # replace with your endpoint URL
    http_endpoint_name            = "example-http-endpoint"
    http_endpoint_access_key      = "example-access-key" # replace with a secure value
    http_endpoint_buffer_size     = 5
    http_endpoint_buffer_interval = 300

    tags = {
      Purpose = "analytics-firehose-http"
    }
  }
}
