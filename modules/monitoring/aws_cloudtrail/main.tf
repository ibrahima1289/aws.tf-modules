# ─── CloudTrail Trails ───────────────────────────────────────────────────────
# Creates one CloudTrail trail per entry in var.trails.
resource "aws_cloudtrail" "trail" {
  for_each = local.trails_map

  # Trail name — must be unique within an AWS account/region
  name           = each.value.name
  s3_bucket_name = each.value.s3_bucket_name

  # Optional S3 key prefix for log file delivery (e.g., "cloudtrail/")
  s3_key_prefix = try(each.value.s3_key_prefix, null)

  # Optional SNS topic ARN/name for near-real-time delivery notifications
  sns_topic_name = try(each.value.sns_topic_name, null)

  # SHA-256 digest files allow post-hoc log file integrity validation
  enable_log_file_validation = try(each.value.enable_log_file_validation, true)

  # Multi-region trail captures events from every AWS region into one trail
  is_multi_region_trail = try(each.value.is_multi_region_trail, false)

  # Include IAM, STS, and other global service events (always recommended)
  include_global_service_events = try(each.value.include_global_service_events, true)

  # Organisation trail applies to all member accounts in AWS Organizations
  is_organization_trail = try(each.value.is_organization_trail, false)

  # Toggle logging on/off without deleting the trail (useful for maintenance)
  enable_logging = try(each.value.enable_logging, true)

  # Customer-managed KMS key ARN for SSE encryption of log files
  kms_key_id = try(each.value.kms_key_id, null)

  # ── CloudWatch Logs integration ─────────────────────────────────────────────
  # Both ARNs are required together; ARN must end in ":*" (e.g., log-group-arn:*)
  cloud_watch_logs_group_arn = try(each.value.cloud_watch_logs_group_arn, null)
  cloud_watch_logs_role_arn  = try(each.value.cloud_watch_logs_role_arn, null)

  # ── Standard event selectors ────────────────────────────────────────────────
  # Only rendered when no advanced_event_selectors are defined for this trail.
  # Use event_selectors for simple management + data event configuration.
  dynamic "event_selector" {
    for_each = length(try(each.value.advanced_event_selectors, [])) == 0 ? try(each.value.event_selectors, []) : []
    content {
      # All | ReadOnly | WriteOnly — controls which API call directions are logged
      read_write_type = try(event_selector.value.read_write_type, "All")

      # Always capture management events (CreateBucket, RunInstances, etc.)
      include_management_events = try(event_selector.value.include_management_events, true)

      # Suppress high-volume management events from noisy services (e.g., kms.amazonaws.com)
      exclude_management_event_sources = try(event_selector.value.exclude_management_event_sources, [])

      # Zero or more data resource blocks — one per resource type
      dynamic "data_resource" {
        for_each = try(event_selector.value.data_resources, [])
        content {
          # AWS::S3::Object | AWS::Lambda::Function | AWS::DynamoDB::Table
          type = data_resource.value.type

          # ARN prefixes; use ["arn:aws:s3:::"] for all S3 objects in the account
          values = data_resource.value.values
        }
      }
    }
  }

  # ── Advanced event selectors ────────────────────────────────────────────────
  # Preferred over standard event_selectors for fine-grained filtering.
  # Rendered only when advanced_event_selectors is non-empty.
  dynamic "advanced_event_selector" {
    for_each = try(each.value.advanced_event_selectors, [])
    content {
      # Human-readable label shown in the console
      name = try(advanced_event_selector.value.name, null)

      # One or more field_selector blocks narrow which events are captured
      dynamic "field_selector" {
        for_each = advanced_event_selector.value.field_selectors
        content {
          # Available fields: eventCategory, resources.type, resources.ARN, readOnly, etc.
          field = field_selector.value.field

          # Equality / inequality / prefix conditions — supply only those needed
          equals          = try(field_selector.value.equals, null)
          not_equals      = try(field_selector.value.not_equals, null)
          starts_with     = try(field_selector.value.starts_with, null)
          not_starts_with = try(field_selector.value.not_starts_with, null)
          ends_with       = try(field_selector.value.ends_with, null)
          not_ends_with   = try(field_selector.value.not_ends_with, null)
        }
      }
    }
  }

  # ── Insight selectors ───────────────────────────────────────────────────────
  # Detect unusual write API call rates or error rates automatically.
  dynamic "insight_selector" {
    for_each = try(each.value.insight_selectors, [])
    content {
      # ApiCallRateInsight | ApiErrorRateInsight
      insight_type = insight_selector.value.insight_type
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}), {
    Name         = each.value.name
    created_date = local.created_date
  })
}
