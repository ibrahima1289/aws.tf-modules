# ── AWS Athena module ─────────────────────────────────────────────────────────
# Creates Athena workgroups, databases, named queries, and federated data
# catalogs.  All resource types support multiple instances via for_each;
# keys are provided by the caller in each list entry's .key field.

# ── Step 1: Workgroups ────────────────────────────────────────────────────────
# Each workgroup isolates query execution: result location, encryption, engine
# version, byte-scan limits, and CloudWatch metrics are all per-workgroup.
resource "aws_athena_workgroup" "wg" {
  for_each = local.workgroups_map

  name          = each.value.name
  description   = each.value.description
  state         = each.value.state
  force_destroy = each.value.force_destroy

  configuration {
    # ── Result destination ────────────────────────────────────────────────────
    result_configuration {
      # S3 URI where query output files (CSV + metadata) are stored.
      output_location = each.value.result_s3_location

      # Restrict result delivery to the specified bucket-owner account.
      expected_bucket_owner = each.value.expected_bucket_owner

      # Server-side encryption for query result objects.
      # Block is omitted when result_encryption_option is null.
      dynamic "encryption_configuration" {
        for_each = each.value.result_encryption_option != null ? [1] : []
        content {
          encryption_option = each.value.result_encryption_option
          # kms_key_arn is ignored by the provider when encryption_option = SSE_S3.
          kms_key_arn = each.value.kms_key_arn
        }
      }

      # ACL applied to result objects — only needed in cross-account bucket setups.
      # Block is omitted when s3_acl_option is null.
      dynamic "acl_configuration" {
        for_each = each.value.s3_acl_option != null ? [1] : []
        content {
          s3_acl_option = each.value.s3_acl_option
        }
      }
    }

    # ── Query engine ──────────────────────────────────────────────────────────
    # Declare the Athena engine version used by this workgroup.
    # "AUTO" lets AWS choose the latest stable version automatically.
    engine_version {
      selected_engine_version = each.value.engine_version
    }

    # ── Cost controls ─────────────────────────────────────────────────────────
    # Cancel any query that would scan more than this many bytes.
    # Omitted (null) means no per-query scan limit.
    bytes_scanned_cutoff_per_query = each.value.bytes_scanned_cutoff_per_query

    # When true, workgroup settings take precedence over client-side overrides.
    enforce_workgroup_configuration = each.value.enforce_workgroup_configuration

    # ── Observability ─────────────────────────────────────────────────────────
    # Emit per-query CloudWatch metrics: BytesScanned, DataScanned, etc.
    publish_cloudwatch_metrics_enabled = each.value.publish_cloudwatch_metrics

    # When true, the query requester bears the S3 requester-pays charges.
    requester_pays_enabled = each.value.requester_pays
  }

  # Merge common_tags with any workgroup-specific tags.
  tags = merge(local.common_tags, each.value.tags)
}

# ── Step 2: Databases ─────────────────────────────────────────────────────────
# Each Athena database maps to an AWS Glue Data Catalog database.
# Note: aws_athena_database does not support resource-level tags.
resource "aws_athena_database" "db" {
  for_each = local.databases_map

  # Athena/Glue database name (lowercase alphanumeric and underscores).
  name = each.value.name

  # S3 bucket used by Glue for DDL output (CREATE TABLE metadata, etc.).
  bucket = each.value.bucket

  # Optional human-readable comment stored in the Glue catalog.
  comment = each.value.comment

  # Restrict bucket access to a specific AWS account.
  expected_bucket_owner = each.value.expected_bucket_owner

  # Drop the database even when Glue tables still exist inside it.
  force_destroy = each.value.force_destroy

  # Encryption for DDL output stored in the S3 bucket.
  # Block is omitted when encryption_option is null (uses bucket-default encryption).
  dynamic "encryption_configuration" {
    for_each = each.value.encryption_option != null ? [1] : []
    content {
      encryption_option = each.value.encryption_option
      # Attribute name in aws_athena_database is kms_key (not kms_key_arn).
      kms_key = each.value.kms_key_arn
    }
  }
}

# ── Step 3: Named Queries ─────────────────────────────────────────────────────
# Saved queries visible in the Athena console and accessible via the API.
# The query string may be loaded from a file() call in the caller's locals.tf.
resource "aws_athena_named_query" "query" {
  for_each = local.named_queries_map

  name        = each.value.name
  description = each.value.description

  # Resolve workgroup name from the workgroup key provided by the caller.
  workgroup = aws_athena_workgroup.wg[each.value.workgroup_key].name

  # Resolve database name from the database key provided by the caller.
  database = aws_athena_database.db[each.value.database_key].name

  # SQL query string (up to 262 144 characters).
  query = each.value.query
}

# ── Step 4: Data Catalogs ─────────────────────────────────────────────────────
# Federated data sources that Athena can query alongside S3.
# Supported types:
#   GLUE   — AWS Glue Data Catalog (same or cross-account)
#   LAMBDA — Custom connector backed by an AWS Lambda function
#   HIVE   — External Hive metastore via a Lambda connector
resource "aws_athena_data_catalog" "catalog" {
  for_each = local.data_catalogs_map

  name        = each.value.name
  description = each.value.description
  type        = each.value.type

  # Type-specific connection parameters (see variable description for examples).
  parameters = each.value.parameters

  # Merge common_tags with any catalog-specific tags.
  tags = merge(local.common_tags, each.value.tags)
}
