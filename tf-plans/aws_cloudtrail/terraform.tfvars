region = "us-east-1"

tags = {
  project     = "demo"
  environment = "dev"
  managed_by  = "terraform"
}

# ─── Trails ──────────────────────────────────────────────────────────────────
# Each object creates one aws_cloudtrail resource.
# The S3 bucket must already exist and have a bucket policy that grants
# CloudTrail permission to call s3:PutObject and s3:GetBucketAcl.
trails = [

  # ── Trail 1: Management events only ──────────────────────────────────────
  # Recommended baseline for all AWS accounts. Captures every control-plane
  # API call (CreateBucket, RunInstances, AttachRolePolicy, etc.) globally.
  {
    name                          = "demo-management-trail"
    s3_bucket_name                = "my-cloudtrail-logs-bucket"
    s3_key_prefix                 = "management"
    enable_log_file_validation    = true # Creates SHA-256 digests for tamper detection
    is_multi_region_trail         = true # Capture events from every AWS region
    include_global_service_events = true # Include IAM, STS, CloudFront events

    # Suppress high-volume KMS and RDS Data API management events to reduce cost
    event_selectors = [
      {
        read_write_type                  = "All"
        include_management_events        = true
        exclude_management_event_sources = ["kms.amazonaws.com", "rdsdata.amazonaws.com"]
      }
    ]

    # Detect unusual spikes in API call volume or error rates
    insight_selectors = [
      { insight_type = "ApiCallRateInsight" },
      { insight_type = "ApiErrorRateInsight" }
    ]
  },

  # ── Trail 2: Data events for S3 and Lambda ────────────────────────────────
  # Captures object-level S3 activity and Lambda invocations.
  # Also streams events to CloudWatch Logs for real-time alerting.
  # NOTE: Data events can generate high volume — scope the values ARNs tightly
  # in production (e.g., "arn:aws:s3:::my-sensitive-bucket/") to control cost.
  {
    name                       = "demo-data-events-trail"
    s3_bucket_name             = "my-cloudtrail-logs-bucket"
    s3_key_prefix              = "data-events"
    enable_log_file_validation = true

    # CloudWatch Logs delivery — enables real-time metric filters and alarms.
    # The log group ARN must end with ":*"; the IAM role must allow
    # logs:CreateLogStream and logs:PutLogEvents on the target log group.
    cloud_watch_logs_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/cloudtrail/demo:*"
    cloud_watch_logs_role_arn  = "arn:aws:iam::123456789012:role/CloudTrailCWLogsRole"

    event_selectors = [
      {
        read_write_type           = "All"
        include_management_events = true
        data_resources = [
          # All S3 object-level activity across the entire account
          {
            type   = "AWS::S3::Object"
            values = ["arn:aws:s3:::"]
          },
          # All Lambda invocations in this region
          {
            type   = "AWS::Lambda::Function"
            values = ["arn:aws:lambda:us-east-1:123456789012:function:"]
          }
        ]
      }
    ]
  }

  # ── Trail 3 (advanced selectors example — uncomment to enable) ────────────
  # Advanced event selectors give field-level filtering precision.
  # This example captures only S3 data events (not management events) for a
  # specific bucket, excluding read-only access.
  # {
  #   name           = "demo-advanced-selector-trail"
  #   s3_bucket_name = "my-cloudtrail-logs-bucket"
  #   s3_key_prefix  = "advanced"
  #
  #   advanced_event_selectors = [
  #     {
  #       name = "S3-sensitive-bucket-writes-only"
  #       field_selectors = [
  #         { field = "eventCategory",   equals = ["Data"] },
  #         { field = "resources.type",  equals = ["AWS::S3::Object"] },
  #         { field = "resources.ARN",   starts_with = ["arn:aws:s3:::my-sensitive-bucket/"] },
  #         { field = "readOnly",        equals = ["false"] }
  #       ]
  #     }
  #   ]
  # }
]
