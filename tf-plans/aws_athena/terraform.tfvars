region = "us-east-1"

tags = {
  environment = "production"
  team        = "data-platform"
  project     = "analytics-infra"
  managed_by  = "terraform"
}

# ── Workgroups ────────────────────────────────────────────────────────────────
# Pattern 1: Primary production workgroup — SSE-S3 encryption, engine v3,
#             1 TB scan limit, CloudWatch metrics enabled.
# Pattern 2: Dev workgroup — SSE-KMS encryption, 100 GB scan limit,
#             workgroup config NOT enforced (allows client overrides).
workgroups = [
  {
    # Production workgroup used by the data engineering team.
    key                             = "primary"
    name                            = "primary"
    description                     = "Production query workgroup for the data-platform team."
    state                           = "ENABLED"
    result_s3_location              = "s3://my-athena-results-123456789012/primary/"
    result_encryption_option        = "SSE_S3"
    engine_version                  = "Athena engine version 3"
    bytes_scanned_cutoff_per_query  = 1099511627776 # 1 TB — prevent runaway scans
    enforce_workgroup_configuration = true
    publish_cloudwatch_metrics      = true
    requester_pays                  = false
    tags                            = { workgroup_type = "production" }
  },
  {
    # Developer sandbox workgroup with KMS encryption and a tighter scan cap.
    key                             = "dev"
    name                            = "dev"
    description                     = "Developer sandbox workgroup — cost-controlled."
    state                           = "ENABLED"
    result_s3_location              = "s3://my-athena-results-123456789012/dev/"
    result_encryption_option        = "SSE_KMS"
    kms_key_arn                     = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123def456"
    engine_version                  = "Athena engine version 3"
    bytes_scanned_cutoff_per_query  = 107374182400 # 100 GB — low limit for dev
    enforce_workgroup_configuration = false        # allow developers to override settings
    publish_cloudwatch_metrics      = true
    requester_pays                  = false
    tags                            = { workgroup_type = "development" }
  }
]

# ── Databases ─────────────────────────────────────────────────────────────────
# Single analytics database backed by the S3 data lake bucket.
# No encryption_option set — relies on bucket-default SSE-S3.
databases = [
  {
    key           = "analytics"
    name          = "analytics"
    bucket        = "my-datalake-bucket-123456789012"
    comment       = "Main analytics database — tables point to S3 data lake prefixes."
    force_destroy = false
  }
]

# Named queries are NOT declared here.
# They are defined in locals.tf where file() can load SQL from templates/.

# ── Data Catalogs ─────────────────────────────────────────────────────────────
# GLUE catalog entry — allows Athena to query this account's Glue Data Catalog
# tables using the federated query interface.
data_catalogs = [
  {
    key         = "glue_main"
    name        = "glue-main-catalog"
    description = "Default AWS Glue Data Catalog for account 123456789012."
    type        = "GLUE"
    parameters  = { "catalog-id" = "123456789012" }
    tags        = { catalog_type = "glue" }
  }
]
