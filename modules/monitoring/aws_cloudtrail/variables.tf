
variable "region" {
  description = "AWS region to deploy CloudTrail resources (e.g., us-east-1)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all CloudTrail resources"
  type        = map(string)
  default     = {}
}

# ─── Trails ──────────────────────────────────────────────────────────────────
variable "trails" {
  description = "List of CloudTrail trails to create. Supports management events, data events (S3/Lambda/DynamoDB), advanced event selectors, CloudWatch Logs delivery, and Insights."
  type = list(object({
    name           = string # Trail name — unique per account/region
    s3_bucket_name = string # S3 bucket for log file delivery (must have correct bucket policy)

    # ── Delivery options ────────────────────────────────────────────────────
    s3_key_prefix  = optional(string) # S3 prefix for log files (e.g., "cloudtrail/")
    sns_topic_name = optional(string) # SNS topic name or ARN for delivery notifications

    # ── Trail scope ─────────────────────────────────────────────────────────
    is_multi_region_trail         = optional(bool, false) # Capture events from all AWS regions
    include_global_service_events = optional(bool, true)  # Include IAM, STS, CloudFront events
    is_organization_trail         = optional(bool, false) # Apply to all accounts in AWS Org

    # ── Logging controls ────────────────────────────────────────────────────
    enable_logging             = optional(bool, true) # Start/stop logging without deleting trail
    enable_log_file_validation = optional(bool, true) # Create SHA-256 digest files for integrity

    # ── Encryption ──────────────────────────────────────────────────────────
    kms_key_id = optional(string) # Customer-managed KMS key ARN for SSE encryption

    # ── CloudWatch Logs integration ─────────────────────────────────────────
    # Both fields must be provided together to enable CWL delivery.
    # The log group ARN must end with ":*" (e.g., "arn:aws:logs:...:log-group:/trail/name:*")
    cloud_watch_logs_group_arn = optional(string) # CloudWatch Logs log group ARN
    cloud_watch_logs_role_arn  = optional(string) # IAM role ARN allowing CloudTrail to write logs

    # ── Standard event selectors ────────────────────────────────────────────
    # Mutually exclusive with advanced_event_selectors.
    # Omit both to default to management-events-only logging.
    event_selectors = optional(list(object({
      read_write_type                  = optional(string, "All") # All | ReadOnly | WriteOnly
      include_management_events        = optional(bool, true)
      exclude_management_event_sources = optional(list(string), []) # e.g., ["kms.amazonaws.com"]

      # Data event resources — one block per resource type
      data_resources = optional(list(object({
        type   = string       # AWS::S3::Object | AWS::Lambda::Function | AWS::DynamoDB::Table
        values = list(string) # ARN prefixes; ["arn:aws:s3:::"] for all S3 objects
      })), [])
    })), [])

    # ── Advanced event selectors ─────────────────────────────────────────────
    # Preferred for fine-grained filtering; mutually exclusive with event_selectors.
    advanced_event_selectors = optional(list(object({
      name = optional(string) # Human-readable label for this selector set

      # One or more field_selector blocks
      field_selectors = list(object({
        field           = string # eventCategory | resources.type | resources.ARN | readOnly | eventSource | eventName
        equals          = optional(list(string))
        not_equals      = optional(list(string))
        starts_with     = optional(list(string))
        not_starts_with = optional(list(string))
        ends_with       = optional(list(string))
        not_ends_with   = optional(list(string))
      }))
    })), [])

    # ── Insight selectors ───────────────────────────────────────────────────
    insight_selectors = optional(list(object({
      insight_type = string # ApiCallRateInsight | ApiErrorRateInsight
    })), [])

    tags = optional(map(string), {})
  }))
  default = []
}
