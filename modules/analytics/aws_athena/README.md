# AWS Athena Module

Reusable Terraform module for [AWS Athena](https://docs.aws.amazon.com/athena/latest/ug/what-is.html) — a serverless interactive query service that analyses data stored in Amazon S3 using standard SQL.

> See [aws-athena.md](aws-athena.md) for a full service reference, pricing model, and architecture deep-dive.

---

## Architecture

```
                          ┌─────────────────────────────────────────────────────┐
                          │               AWS Athena Module                     │
                          │                                                     │
  ┌──────────────┐        │  ┌─────────────────────────────────────────────┐   │
  │  Query Client│──SQL──►│  │           Workgroup (per-team/env)          │   │
  │ (Console/SDK)│        │  │  ─ Result S3 location                       │   │
  └──────────────┘        │  │  ─ SSE-S3 / SSE-KMS encryption              │   │
                          │  │  ─ Engine version (v2/v3/AUTO)              │   │
  ┌──────────────┐        │  │  ─ Byte-scan cutoff (cost control)          │   │
  │ Named Queries│──ref──►│  │  ─ CloudWatch metrics toggle                │   │
  │  (saved SQL) │        │  └──────────────────┬──────────────────────────┘   │
  └──────────────┘        │                     │                               │
                          │                     ▼                               │
  ┌──────────────┐        │  ┌─────────────────────────────────────────────┐   │
  │  Data Catalog│──fed──►│  │       Athena Database (Glue-backed)         │   │
  │ GLUE/LAMBDA/ │        │  │  ─ Maps to AWS Glue Data Catalog DB         │   │
  │    HIVE      │        │  │  ─ DDL results stored in S3 bucket          │   │
  └──────────────┘        │  │  ─ Optional encryption for DDL output       │   │
                          │  └──────────────────┬──────────────────────────┘   │
                          │                     │                               │
                          │                     ▼                               │
                          │  ┌─────────────────────────────────────────────┐   │
                          │  │       Query Execution (serverless)           │   │
                          │  │  ─ Scans S3 data (CSV, Parquet, ORC, JSON)  │   │
                          │  │  ─ Billed per TB scanned                    │   │
                          │  │  ─ Results written to result S3 location    │   │
                          │  └─────────────────────────────────────────────┘   │
                          └─────────────────────────────────────────────────────┘
                                        │                     │
                               ┌────────▼────────┐  ┌────────▼────────┐
                               │   S3 Data Lake  │  │   CloudWatch    │
                               │ (source tables) │  │ Metrics/Logs    │
                               └─────────────────┘  └─────────────────┘
```

---

## Resources Created

| Resource | Description |
|----------|-------------|
| `aws_athena_workgroup` | Query isolation boundary: result location, encryption, engine version, cost controls |
| `aws_athena_database` | Glue-backed catalog database holding table schemas |
| `aws_athena_named_query` | Saved SQL queries bound to a workgroup and database |
| `aws_athena_data_catalog` | Federated data source (GLUE, LAMBDA, or HIVE connector) |

---

## Usage

```hcl
module "athena" {
  source = "../../modules/analytics/aws_athena"

  region = "us-east-1"
  tags   = { environment = "production", team = "data-platform" }

  workgroups = [
    {
      key                            = "primary"
      name                           = "primary"
      description                    = "Production query workgroup"
      result_s3_location             = "s3://my-athena-results/primary/"
      result_encryption_option       = "SSE_S3"
      engine_version                 = "Athena engine version 3"
      bytes_scanned_cutoff_per_query = 1099511627776   # 1 TB
      publish_cloudwatch_metrics     = true
    }
  ]

  databases = [
    {
      key     = "analytics"
      name    = "analytics"
      bucket  = "my-datalake-bucket"
      comment = "Main analytics database"
    }
  ]

  named_queries = [
    {
      key           = "cost_report"
      name          = "Monthly Cost Report"
      workgroup_key = "primary"
      database_key  = "analytics"
      description   = "Top 10 services by unblended cost"
      query         = file("templates/cost-report.sql")
    }
  ]

  data_catalogs = [
    {
      key         = "glue_main"
      name        = "glue-main"
      description = "Default Glue Data Catalog"
      type        = "GLUE"
      parameters  = { "catalog-id" = "123456789012" }
    }
  ]
}
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region where resources are deployed |

---

## Optional Variables

### Top-level

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all taggable resources |
| `workgroups` | `list(object)` | `[]` | Workgroup definitions (see below) |
| `databases` | `list(object)` | `[]` | Database definitions (see below) |
| `named_queries` | `list(object)` | `[]` | Named query definitions (see below) |
| `data_catalogs` | `list(object)` | `[]` | Federated data catalog definitions (see below) |

### `workgroups` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Workgroup name |
| `description` | `string` | `""` | Human-readable description |
| `state` | `string` | `"ENABLED"` | `ENABLED` or `DISABLED` |
| `force_destroy` | `bool` | `false` | Delete workgroup even if it has saved queries |
| `result_s3_location` | `string` | required | S3 URI prefix for query results |
| `result_encryption_option` | `string` | `"SSE_S3"` | `SSE_S3`, `SSE_KMS`, or `CSE_KMS`; `null` to omit block |
| `kms_key_arn` | `string` | `null` | KMS key ARN (required for SSE_KMS/CSE_KMS) |
| `s3_acl_option` | `string` | `null` | `BUCKET_OWNER_FULL_CONTROL` or `BUCKET_OWNER_READ` |
| `expected_bucket_owner` | `string` | `null` | AWS account ID that owns the result bucket |
| `engine_version` | `string` | `"AUTO"` | `AUTO`, `Athena engine version 2`, or `Athena engine version 3` |
| `bytes_scanned_cutoff_per_query` | `number` | `null` | Max bytes per query (min 10 MB); `null` = unlimited |
| `enforce_workgroup_configuration` | `bool` | `true` | Workgroup settings override client overrides |
| `publish_cloudwatch_metrics` | `bool` | `true` | Emit per-query CloudWatch metrics |
| `requester_pays` | `bool` | `false` | Requester bears S3 requester-pays charges |
| `tags` | `map(string)` | `{}` | Additional tags for this workgroup |

### `databases` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Database name (lowercase alphanumeric/underscores) |
| `bucket` | `string` | required | S3 bucket for DDL output |
| `comment` | `string` | `""` | Database description |
| `encryption_option` | `string` | `null` | `SSE_S3`, `SSE_KMS`, or `CSE_KMS` for DDL results |
| `kms_key_arn` | `string` | `null` | KMS key for SSE_KMS/CSE_KMS |
| `expected_bucket_owner` | `string` | `null` | Account ID that owns the DDL bucket |
| `force_destroy` | `bool` | `false` | Drop database even when Glue tables exist |

### `named_queries` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Saved query display name |
| `workgroup_key` | `string` | required | Key of an entry in `workgroups` |
| `database_key` | `string` | required | Key of an entry in `databases` |
| `description` | `string` | `""` | Query description |
| `query` | `string` | required | SQL string (use `file()` for large queries) |

### `data_catalogs` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Catalog name |
| `description` | `string` | `""` | Catalog description |
| `type` | `string` | required | `LAMBDA`, `GLUE`, or `HIVE` |
| `parameters` | `map(string)` | required | Type-specific parameters (see variables.tf) |
| `tags` | `map(string)` | `{}` | Additional tags for this catalog |

---

## Outputs

| Output | Description |
|--------|-------------|
| `workgroup_names` | Map of workgroup key → name |
| `workgroup_arns` | Map of workgroup key → ARN |
| `workgroup_states` | Map of workgroup key → state |
| `database_names` | Map of database key → name |
| `named_query_ids` | Map of named query key → ID |
| `named_query_names` | Map of named query key → display name |
| `data_catalog_names` | Map of data catalog key → name |
| `data_catalog_arns` | Map of data catalog key → ARN |

---

## Notes

- `aws_athena_database` does **not** support resource-level tags — only workgroups and data catalogs accept tags.
- `bytes_scanned_cutoff_per_query` must be ≥ 10 MB (10,485,760 bytes) if set.
- Named query SQL strings can be kept in external `.sql` files and loaded with `file()` inside the calling wrapper's `locals.tf`, keeping `terraform.tfvars` free of inline SQL.
- Setting `enforce_workgroup_configuration = true` (default) prevents clients from overriding the result location or encryption settings.
- For cross-account Glue catalog access, set `data_catalog.type = "GLUE"` and `parameters = { "catalog-id" = "<target_account_id>" }`.

---

## See Also

- [Wrapper plan](../../../tf-plans/aws_athena/README.md)
- [Service overview](aws-athena.md)
- [AWS Athena documentation](https://docs.aws.amazon.com/athena/latest/ug/)
- [Terraform aws_athena_workgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup)
