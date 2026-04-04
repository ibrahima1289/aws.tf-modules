# ── Top-level variables ───────────────────────────────────────────────────────

variable "region" {
  description = "AWS region where Athena resources are deployed."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Common tags applied to all taggable Athena resources."
  type        = map(string)
  default     = {}
}

# ── Workgroups ────────────────────────────────────────────────────────────────

variable "workgroups" {
  description = <<-EOT
    List of Athena workgroups to create.  Each entry maps to one
    aws_athena_workgroup resource.  Unique keys are used as for_each identifiers.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Workgroup display name (must be unique within the AWS account/region).
    name = string

    # Human-readable description shown in the console.
    description = optional(string, "")

    # ENABLED or DISABLED.
    state = optional(string, "ENABLED")

    # Destroy the workgroup even if it contains named queries.
    force_destroy = optional(bool, false)

    # Required S3 URI prefix where query results are written (e.g. "s3://bucket/prefix/").
    result_s3_location = string

    # Encryption option for query results: SSE_S3, SSE_KMS, or CSE_KMS.
    # Set to null to omit the encryption_configuration block entirely.
    result_encryption_option = optional(string, "SSE_S3")

    # KMS key ARN — required only for SSE_KMS and CSE_KMS.
    kms_key_arn = optional(string, null)

    # S3 ACL applied to query result objects: BUCKET_OWNER_FULL_CONTROL or BUCKET_OWNER_READ.
    # Set to null to omit the acl_configuration block.
    s3_acl_option = optional(string, null)

    # Restrict query result delivery to a specific AWS account ID.
    expected_bucket_owner = optional(string, null)

    # Query engine version: AUTO, Athena engine version 2, Athena engine version 3.
    engine_version = optional(string, "AUTO")

    # Maximum bytes scanned per query.  Queries exceeding this limit are cancelled.
    # Set to null for no limit (only minimum 10 MB if set).
    bytes_scanned_cutoff_per_query = optional(number, null)

    # When true, workgroup settings override per-query client-side overrides.
    enforce_workgroup_configuration = optional(bool, true)

    # Publish per-query CloudWatch metrics (BytesScanned, DataScanned, etc.).
    publish_cloudwatch_metrics = optional(bool, true)

    # When true, the query requester bears the S3 request costs.
    requester_pays = optional(bool, false)

    # Per-workgroup tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── Databases ─────────────────────────────────────────────────────────────────

variable "databases" {
  description = <<-EOT
    List of Athena (Glue-backed) databases to create.  Each entry maps to one
    aws_athena_database resource.  Note: aws_athena_database does not support
    native resource tags.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Database name (lowercase alphanumeric and underscores).
    name = string

    # S3 bucket used for DDL operations (CREATE TABLE output, etc.).
    bucket = string

    # Optional database comment.
    comment = optional(string, "")

    # Encryption option for DDL results: SSE_S3, SSE_KMS, or CSE_KMS.
    # Set to null to omit the encryption_configuration block.
    encryption_option = optional(string, null)

    # KMS key ARN for SSE_KMS / CSE_KMS encryption.
    kms_key_arn = optional(string, null)

    # Restrict S3 access to a specific AWS account ID.
    expected_bucket_owner = optional(string, null)

    # Drop the database in Glue even if it contains tables.
    force_destroy = optional(bool, false)
  }))
  default = []
}

# ── Named Queries ─────────────────────────────────────────────────────────────

variable "named_queries" {
  description = <<-EOT
    List of Athena named (saved) queries.  Each entry maps to one
    aws_athena_named_query resource.  Query strings may be loaded from
    external SQL files via file() in the calling wrapper's locals.tf.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Display name for the saved query.
    name = string

    # Key of the workgroup that owns this query (must match a workgroups[*].key).
    workgroup_key = string

    # Key of the database this query targets (must match a databases[*].key).
    database_key = string

    # Optional description shown in the console.
    description = optional(string, "")

    # SQL query string.  Load from a file() call in locals.tf for large queries.
    query = string
  }))
  default = []
}

# ── Data Catalogs ─────────────────────────────────────────────────────────────

variable "data_catalogs" {
  description = <<-EOT
    List of Athena federated data catalogs.  Each entry maps to one
    aws_athena_data_catalog resource.  Supported types: LAMBDA, GLUE, HIVE.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Catalog name (unique within the AWS account).
    name = string

    # Human-readable description.
    description = optional(string, "")

    # Catalog type: LAMBDA, GLUE, or HIVE.
    type = string

    # Type-specific parameters:
    # GLUE  → { "catalog-id" = "<aws_account_id>" }
    # LAMBDA → { "metadata-function" = "<arn>", "record-function" = "<arn>" }
    # HIVE  → { "metadata-function" = "<arn>", "sdk-version" = "1.0" }
    parameters = map(string)

    # Per-catalog tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}
