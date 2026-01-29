# Terraform AWS S3 Module
# Creates S3 buckets with advanced configuration, tagging, encryption, versioning, lifecycle, replication, logging, and public access blocks.

# Data sources (optional)
# data "aws_caller_identity" "current" {}

locals {
  # Map bucket name -> bucket object for safe lookups
  buckets_by_name = { for b in var.buckets : b.name => b }
}

# Buckets: create S3 buckets and apply base tags
resource "aws_s3_bucket" "s3_bucket" {
  for_each = { for b in var.buckets : b.name => b }
  bucket   = each.value.name
  tags     = merge(var.tags, lookup(each.value, "tags", {}), { created_date = local.created_date, Name = each.value.name })
}

# Ownership controls: set object ownership (optional)
resource "aws_s3_bucket_ownership_controls" "ownership" {
  for_each = { for k, v in aws_s3_bucket.s3_bucket : k => v if lookup(var.bucket_defaults, "ownership_controls_enable", true) }
  bucket   = each.value.id
  rule {
    object_ownership = lookup(var.bucket_defaults, "object_ownership", "BucketOwnerPreferred")
  }
}

# Public access block: enforce private posture and block public ACLs/policies
resource "aws_s3_bucket_public_access_block" "public_access" {
  for_each                = aws_s3_bucket.s3_bucket
  bucket                  = each.value.id
  block_public_acls       = lookup(var.bucket_defaults, "block_public_acls", true)
  block_public_policy     = lookup(var.bucket_defaults, "block_public_policy", true)
  ignore_public_acls      = lookup(var.bucket_defaults, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.bucket_defaults, "restrict_public_buckets", true)
}

# Versioning: keep multiple object versions per bucket
resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.s3_bucket
  bucket   = each.value.id
  versioning_configuration {
    status = lookup(var.bucket_defaults, "versioning_status", "Disabled")
  }
}

# Encryption: server-side encryption (AES256 or KMS), configurable per-bucket or via defaults
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  # Create encryption config when either module defaults enable it or the bucket explicitly enables it,
  # excluding buckets marked for customer-provided keys (SSE-C), which cannot be set at bucket level.
  for_each = {
    for b in var.buckets : b.name => b
    if (lookup(var.bucket_defaults, "sse_enable", false) || try(b.encryption.enable, false))
    && !try(b.encryption.customer_provided, false)
  }
  bucket = aws_s3_bucket.s3_bucket[each.key].id

  # Resolve algorithm and parameters with per-bucket overrides first, then fall back to module defaults
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = coalesce(
        try(each.value.encryption.algorithm, null),
        lookup(var.bucket_defaults, "sse_algorithm", "AES256")
      )
      kms_master_key_id = (
        coalesce(
          try(each.value.encryption.algorithm, null),
          lookup(var.bucket_defaults, "sse_algorithm", "AES256")
        ) == "aws:kms"
      ) ? coalesce(
        try(each.value.encryption.kms_key_id, null),
        lookup(var.bucket_defaults, "kms_key_id", null)
      ) : null
    }
    bucket_key_enabled = coalesce(
      try(each.value.encryption.bucket_key_enabled, null),
      lookup(var.bucket_defaults, "bucket_key_enabled", false)
    )
  }
}

# Logging: write server access logs to a target bucket
resource "aws_s3_bucket_logging" "logging" {
  for_each      = { for b in var.buckets : b.name => b if try(b.logging.target_bucket, null) != null }
  bucket        = aws_s3_bucket.s3_bucket[each.key].id
  target_bucket = each.value.logging.target_bucket
  target_prefix = lookup(each.value.logging, "target_prefix", "")
}

# Lifecycle: manage object transitions/expiration and noncurrent versions
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  for_each = { for b in var.buckets : b.name => b if try(length(b.lifecycle_rules), 0) > 0 }
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
      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])
        content {
          storage_class = transition.value.storage_class
          days          = transition.value.days
        }
      }
      noncurrent_version_expiration {
        noncurrent_days = lookup(rule.value, "noncurrent_version_expiration_days", null)
      }
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transitions", [])
        content {
          storage_class   = noncurrent_version_transition.value.storage_class
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
        }
      }
    }
  }
}

# ACL: set a canned ACL on the bucket (optional)
resource "aws_s3_bucket_acl" "acl" {
  for_each = { for b in var.buckets : b.name => b if lookup(b, "acl", null) != null }
  bucket   = aws_s3_bucket.s3_bucket[each.key].id
  acl      = each.value.acl
}

# Policy: attach a bucket policy JSON (optional)
resource "aws_s3_bucket_policy" "policy" {
  for_each = { for b in var.buckets : b.name => b if lookup(b, "policy_json", null) != null }
  bucket   = aws_s3_bucket.s3_bucket[each.key].id
  policy   = each.value.policy_json
}

# Static website: optionally configure website hosting (index/error or redirects)
resource "aws_s3_bucket_website_configuration" "website" {
  for_each = { for b in var.buckets : b.name => b if try(b.website, null) != null }
  bucket   = aws_s3_bucket.s3_bucket[each.key].id

  dynamic "index_document" {
    for_each = lookup(each.value.website, "index_document", null) != null ? [1] : []
    content {
      suffix = each.value.website.index_document
    }
  }

  dynamic "error_document" {
    for_each = lookup(each.value.website, "error_document", null) != null ? [1] : []
    content {
      key = each.value.website.error_document
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = lookup(each.value.website, "redirect_all_requests_to", null) != null ? [1] : []
    content {
      host_name = each.value.website.redirect_all_requests_to.host_name
      protocol  = lookup(each.value.website.redirect_all_requests_to, "protocol", null)
    }
  }
}

# Replication: cross-bucket replication; created only when rules are provided
resource "aws_s3_bucket_replication_configuration" "replication" {
  # Only create when replication rules exist AND a role is provided (per-bucket or module-level)
  for_each = {
    for k, b in aws_s3_bucket.s3_bucket :
    k => b
    if try(length(try(local.buckets_by_name[k].replication.rules, [])), 0) > 0
    && (try(local.buckets_by_name[k].replication.role_arn, null) != null || var.replication_role_arn != null)
  }

  bucket = each.value.id
  role   = coalesce(try(local.buckets_by_name[each.key].replication.role_arn, null), var.replication_role_arn)

  dynamic "rule" {
    for_each = try(local.buckets_by_name[each.key].replication.rules, [])
    content {
      id       = lookup(rule.value, "id", null)
      priority = lookup(rule.value, "priority", null)
      status   = lookup(rule.value, "status", "Enabled")

      dynamic "delete_marker_replication" {
        for_each = [true]
        content {
          status = lookup(rule.value, "delete_marker_replication_status", "Enabled")
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
        bucket        = rules.value.destination_bucket_arn
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
