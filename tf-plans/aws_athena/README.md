# AWS Athena — Wrapper Plan

This wrapper demonstrates three real-world Athena deployment patterns using the [aws_athena module](../../modules/analytics/aws_athena/README.md).

> See [aws-athena.md](../../modules/analytics/aws_athena/aws-athena.md) for a full service reference and pricing model.

---

## Architecture

```
  terraform.tfvars                  locals.tf (SQL from file())
       │                                    │
       ▼                                    ▼
  var.workgroups               local.named_queries_config
  var.databases                  ├── cost-report.sql
  var.data_catalogs              └── security-audit.sql
       │                                    │
       └────────────────┬───────────────────┘
                        ▼
              module "athena" (main.tf)
                        │
                        ▼
          ┌─────────────────────────────────┐
          │      aws_athena_workgroup       │
          │  ─ primary  (SSE-S3, v3, 1 TB) │
          │  ─ dev      (SSE-KMS, 100 GB)  │
          └──────────────┬──────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │       aws_athena_database       │
          │  ─ analytics (→ S3 data lake)   │
          └──────────────┬──────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │     aws_athena_named_query      │
          │  ─ Monthly Cost Report (CUR)    │
          │  ─ Security Audit (CloudTrail)  │
          └──────────────┬──────────────────┘
                         │
          ┌──────────────▼──────────────────┐
          │     aws_athena_data_catalog     │
          │  ─ glue-main-catalog (GLUE)     │
          └─────────────────────────────────┘
```

---

## Configuration Patterns

### Pattern 1 — Production Workgroup (`primary`)

| Setting | Value |
|---------|-------|
| Engine version | Athena engine version 3 |
| Result encryption | SSE-S3 |
| Byte-scan cutoff | 1 TB per query |
| CloudWatch metrics | Enabled |
| Enforce config | `true` (clients cannot override) |

### Pattern 2 — Developer Workgroup (`dev`)

| Setting | Value |
|---------|-------|
| Engine version | Athena engine version 3 |
| Result encryption | SSE-KMS (customer-managed key) |
| Byte-scan cutoff | 100 GB per query |
| CloudWatch metrics | Enabled |
| Enforce config | `false` (developers can override result location) |

### Pattern 3 — Federated Data Catalog (GLUE)

Registers the account's default Glue Data Catalog so Athena federated queries can reference it by name.

```hcl
data_catalogs = [
  {
    key        = "glue_main"
    name       = "glue-main-catalog"
    type       = "GLUE"
    parameters = { "catalog-id" = "123456789012" }
  }
]
```

---

## SQL Templates

Named query SQL strings are stored in `templates/` and loaded via `file()` in `locals.tf`.

| File | Purpose |
|------|---------|
| `templates/cost-report.sql` | Top 10 services by unblended cost — queries a CUR table |
| `templates/security-audit.sql` | IAM API calls in the last 30 days — queries CloudTrail logs |

To add a new saved query, create a `.sql` file in `templates/` and add an entry to `named_queries_config` in `locals.tf`.

---

## Usage

```bash
cd tf-plans/aws_athena
terraform init
terraform plan
terraform apply
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region (default: `us-east-1`) |

---

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all taggable resources |
| `workgroups` | `list(object)` | `[]` | Workgroup definitions (see `terraform.tfvars` examples) |
| `databases` | `list(object)` | `[]` | Database definitions |
| `data_catalogs` | `list(object)` | `[]` | Federated data catalog definitions |

> **Note:** `named_queries` is not a variable in this wrapper — named queries are defined in `locals.tf` to allow SQL strings to be loaded from external `.sql` files via `file()`.

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

## File Structure

```
tf-plans/aws_athena/
├── provider.tf          # Terraform + AWS provider constraints
├── variables.tf         # Input variable declarations
├── locals.tf            # created_date + named_queries_config (SQL from file())
├── main.tf              # Module call
├── outputs.tf           # Expose module outputs
├── terraform.tfvars     # Example: 2 workgroups, 1 database, 1 data catalog
├── README.md            # This file
└── templates/
    ├── cost-report.sql      # CUR top-services query
    └── security-audit.sql   # CloudTrail IAM audit query
```

---

## See Also

- [Module](../../modules/analytics/aws_athena/README.md)
- [Service overview](../../modules/analytics/aws_athena/aws-athena.md)
- [AWS Athena documentation](https://docs.aws.amazon.com/athena/latest/ug/)
