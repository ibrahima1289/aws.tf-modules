# Terraform AWS S3 Module
# Creates S3 buckets with advanced configuration, tagging, encryption, versioning, lifecycle, replication, logging, and public access blocks.

# Data sources (optional)
# data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "s3_bucket" {
  for_each = { for b in var.buckets : b.name => b }
  bucket   = each.value.name
  tags     = merge(var.tags, lookup(each.value, "tags", {}), { created_date = local.created_date, Name = each.value.name })
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  for_each = aws_s3_bucket.s3_bucket
  bucket   = each.value.id
  rule {
    object_ownership = lookup(var.bucket_defaults, "object_ownership", "BucketOwnerPreferred")
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  for_each                = aws_s3_bucket.s3_bucket
  bucket                  = each.value.id
  block_public_acls       = lookup(var.bucket_defaults, "block_public_acls", true)
  block_public_policy     = lookup(var.bucket_defaults, "block_public_policy", true)
  ignore_public_acls      = lookup(var.bucket_defaults, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.bucket_defaults, "restrict_public_buckets", true)
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.s3_bucket
  bucket   = each.value.id
  versioning_configuration {
    status = lookup(var.bucket_defaults, "versioning_status", "Disabled")
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = { for k, v in aws_s3_bucket.s3_bucket : k => v if lookup(var.bucket_defaults, "sse_enable", true) }
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = lookup(var.bucket_defaults, "sse_algorithm", "AES256")
      kms_master_key_id = lookup(var.bucket_defaults, "kms_key_id", null)
    }
    bucket_key_enabled = lookup(var.bucket_defaults, "bucket_key_enabled", false)
  }
}

resource "aws_s3_bucket_logging" "logging" {
  for_each      = { for b in var.buckets : b.name => b if try(b.logging.target_bucket, null) != null }
  bucket        = aws_s3_bucket.s3_bucket[each.key].id
  target_bucket = each.value.logging.target_bucket
  target_prefix = lookup(each.value.logging, "target_prefix", "")
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = { for b in var.buckets : b.name => b if length(lookup(b, "lifecycle_rules", [])) > 0 }
  bucket   = aws_s3_bucket.s3_bucket[each.key].id
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status
      filter {
        prefix = lookup(rule.value, "prefix", null)
      }
      expiration {
        days = lookup(rule.value, "expiration_days", null)
      }
      noncurrent_version_expiration {
        noncurrent_days = lookup(rule.value, "noncurrent_version_expiration_days", null)
      }
    }
  }
}

# Bucket ACL (optional)
resource "aws_s3_bucket_acl" "acl" {
  for_each = { for b in var.buckets : b.name => b if lookup(b, "acl", null) != null }
  bucket   = aws_s3_bucket.s3_bucket[each.key].id
  acl      = each.value.acl
}

# Bucket policy (optional)
resource "aws_s3_bucket_policy" "policy" {
  for_each = { for b in var.buckets : b.name => b if lookup(b, "policy_json", null) != null }
  bucket   = aws_s3_bucket.s3_bucket[each.key].id
  policy   = each.value.policy_json
}

# Replication (created only when rules are provided)
resource "aws_s3_bucket_replication_configuration" "replication" {
  # Only create for buckets that have a non-null, non-empty replication.rules
  for_each = {
    for k, b in aws_s3_bucket.s3_bucket :
    k => b
    if try(length(lookup(var.buckets[index(keys(aws_s3_bucket.s3_bucket), k)], "replication", null).rules), 0) > 0
  }

  bucket = each.value.id
  role   = lookup(
    lookup(var.buckets[index(keys(aws_s3_bucket.s3_bucket), each.key)], "replication", {}),
    "role_arn",
    null
  )

  dynamic "rule" {
    for_each = lookup(
      lookup(var.buckets[index(keys(aws_s3_bucket.s3_bucket), each.key)], "replication", {}),
      "rules",
      []
    )
    content {
      id       = lookup(rule.value, "id", null)
      priority = lookup(rule.value, "priority", null)
      status   = lookup(rule.value, "status", "Enabled")

      dynamic "delete_marker_replication" {
        for_each = [true]
        content {
          status = lookup(rule.value, "delete_marker_replication_status", "Disabled")
        }
      }

      dynamic "filter" {
        # Only emit filter if a non-empty prefix is provided
        for_each = length(lookup(rule.value, "prefix", "")) > 0 ? [1] : []
        content {
          prefix = rule.value.prefix
        }
      }

      destination {
        bucket        = rule.value.destination_bucket_arn
        storage_class = lookup(rule.value, "storage_class", "STANDARD")

        dynamic "replication_time" {
          # Create only when both status and minutes provided
          for_each = (lookup(rule.value, "replication_time_status", null) != null
            && lookup(rule.value, "replication_time_minutes", null) != null) ? [1] : []
          content {
            status = rule.value.replication_time_status
            time {
              minutes = rule.value.replication_time_minutes
            }
          }
        }

        dynamic "metrics" {
          # Create only when both status and minutes provided
          for_each = (lookup(rule.value, "metrics_status", null) != null
            && lookup(rule.value, "metrics_minutes", null) != null) ? [1] : []
          content {
            status = rule.value.metrics_status
            event_threshold {
              minutes = rule.value.metrics_minutes
            }
          }
        }
      }
    }
  }
  depends_on = [aws_s3_bucket_versioning.versioning]
}
