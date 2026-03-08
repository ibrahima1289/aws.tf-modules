# AWS DocumentDB Terraform Module

This module creates and manages [AWS DocumentDB](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html) clusters with full MongoDB-compatible configuration support. It provisions subnet groups, optional custom parameter groups, the cluster itself, and one or more instances — all driven by a single `clusters` map for multi-cluster deployments.

## Features

- **Multi-Cluster Support** — Create multiple DocumentDB clusters from a single module call
- **Flexible Instance Scaling** — Set `instance_count` per cluster (1 = dev, 3+ = HA with read replicas)
- **Automatic Failover** — Promotion tiers assigned automatically; lowest index = highest priority
- **Storage Encryption** — At-rest encryption enabled by default with AWS-managed or customer KMS keys
- **I/O-Optimized Storage** — `storage_type = "iopt1"` for high-throughput production workloads
- **Custom Parameter Groups** — Automatically created only when parameters are provided (TLS, audit logs)
- **Automated Backups** — Configurable retention (1–35 days) with optional final snapshot
- **Snapshot Restore** — Provision a cluster from an existing snapshot via `snapshot_identifier`
- **CloudWatch Log Exports** — `audit` and `profiler` log streams to CloudWatch Logs
- **Deletion Protection** — Optional safeguard against accidental cluster deletion
- **Consistent Tagging** — Automatically adds `CreatedDate`, `ManagedBy`, and `Module` tags to all resources

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    DocumentDB Module Architecture                       │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ Input: clusters map                                                     │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│ │  Cluster 1   │  │  Cluster 2   │  │  Cluster N   │                    │
│ │  (app-dev)   │  │  (analytics) │  │  (staging)   │                    │
│ └──────────────┘  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ DocumentDB Resources (aws_docdb_*)                                      │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Subnet Group (aws_docdb_subnet_group)                               │ │
│ │ • Spans multiple Availability Zones (≥ 2 required, 3 recommended)   │ │
│ │ • Controls VPC placement of all cluster instances                   │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Parameter Group (aws_docdb_cluster_parameter_group) [Optional]      │ │
│ │ • Created only when custom parameters are provided                  │ │
│ │ • Controls: TLS enforcement, audit log level, profiler threshold    │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ DocumentDB Cluster (aws_docdb_cluster)                              │ │
│ │ • Cluster endpoint (write) ──► always routes to the primary         │ │
│ │ • Reader endpoint   (read)  ──► load-balanced across replicas       │ │
│ │ • Shared cluster volume: 6 copies replicated across 3 AZs           │ │
│ │ • Encryption at rest: AWS KMS (managed or customer key)             │ │
│ │ • Storage type: "standard" or "iopt1" (I/O-Optimized)               │ │
│ │ • Automated backups + point-in-time recovery                        │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Cluster Instances (aws_docdb_cluster_instance)                      │ │
│ │                                                                     │ │
│ │  instance_count = 1 (dev/test)                                      │ │
│ │  ┌──────────────────────┐                                           │ │
│ │  │ Instance 1 (Primary) │  Reads + Writes                           │ │
│ │  │  AZ: us-east-1a      │                                           │ │
│ │  └──────────────────────┘                                           │ │
│ │                                                                     │ │
│ │  instance_count = 3 (production HA)                                 │ │
│ │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐               │ │
│ │  │ Instance 1   │  │ Instance 2   │  │ Instance 3   │               │ │
│ │  │ (Primary)    │  │ (Replica)    │  │ (Replica)    │               │ │
│ │  │ AZ: 1a       │  │ AZ: 1b       │  │ AZ: 1c       │               │ │
│ │  │ Read+Write   │  │ Read only    │  │ Read only    │               │ │
│ │  │ tier: 0      │  │ tier: 1      │  │ tier: 2      │               │ │
│ │  └──────────────┘  └──────────────┘  └──────────────┘               │ │
│ │       ↑ Automatic failover on primary failure (< 30 seconds)        │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Monitoring & Observability                                          │ │
│ │ • CloudWatch Logs: audit (DDL/DML activity), profiler (slow queries)│ │
│ │ • CloudWatch Metrics: CPU, FreeableMemory, WriteIOPS, Connections   │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Security                                                            │ │
│ │ • VPC-only: no direct internet exposure                             │ │
│ │ • Security Groups: control port 27017 inbound access                │ │
│ │ • TLS 1.2 in transit (configurable via parameter group)             │ │
│ │ • KMS encryption at rest (AWS-managed or customer-managed)          │ │
│ │ • Deletion Protection: prevents accidental cluster removal          │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Application Connectivity                                                │
│                                                                         │
│  App (MongoDB driver) ──► cluster_endpoint:27017  (writes)              │
│  App (MongoDB driver) ──► reader_endpoint:27017   (reads, load-balanced)│
└─────────────────────────────────────────────────────────────────────────┘
```

## Usage

```hcl
module "documentdb" {
  source = "../../modules/databases/non-relational/aws_documentdb"

  region = "us-east-1"

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }

  clusters = {
    app-prod = {
      cluster_identifier     = "app-docdb-prod"
      engine_version         = "5.0"
      master_username        = "docdbadmin"
      master_password        = "SuperSecretPw1!"
      instance_class         = "db.r5.large"
      instance_count         = 3
      subnet_ids             = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
      vpc_security_group_ids = ["sg-xxxxxxxxx"]
      storage_encrypted      = true
      deletion_protection    = true
    }
  }
}
```

## Input Variables

### Top-Level Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `region` | `string` | ✅ | — | AWS region to deploy DocumentDB resources |
| `tags` | `map(string)` | ❌ | `{}` | Global tags applied to all resources |
| `clusters` | `map(object)` | ❌ | `{}` | Map of DocumentDB clusters to create |

### `clusters` Object Attributes

#### Cluster Identity & Engine

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `cluster_identifier` | `string` | ✅ | — | Unique name for the DocumentDB cluster |
| `engine_version` | `string` | ❌ | `"5.0"` | DocumentDB engine version: `"4.0"` or `"5.0"` |

#### Master Credentials

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `master_username` | `string` | ✅ | — | Admin username; cannot be changed after creation |
| `master_password` | `string` | ✅ | — | Admin password; use Secrets Manager in production |

#### Compute

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `instance_class` | `string` | ✅ | — | Instance type (e.g. `db.t3.medium`, `db.r5.large`) |
| `instance_count` | `number` | ❌ | `1` | Total instances per cluster (1 = single-node, 3+ = HA) |

#### Networking

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `subnet_ids` | `list(string)` | ✅ | — | Subnet IDs (span ≥ 2 AZs; 3 recommended for HA) |
| `vpc_security_group_ids` | `list(string)` | ✅ | — | Security groups controlling port 27017 access |
| `port` | `number` | ❌ | `27017` | MongoDB listener port |

#### Subnet Group

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `subnet_group_name` | `string` | ❌ | `"<cluster_identifier>-subnet-group"` | Custom subnet group name |
| `subnet_group_description` | `string` | ❌ | Auto-generated | Custom subnet group description |

#### Storage

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `storage_encrypted` | `bool` | ❌ | `true` | Enable encryption at rest |
| `kms_key_id` | `string` | ❌ | `null` | Customer KMS key ARN; AWS-managed key used when `null` |
| `storage_type` | `string` | ❌ | `"standard"` | `"standard"` or `"iopt1"` (I/O-Optimized; not all regions/instance types) |

#### Backup & Maintenance

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `backup_retention_period` | `number` | ❌ | `7` | Automated backup retention in days (1–35) |
| `preferred_backup_window` | `string` | ❌ | `"03:00-04:00"` | Daily backup window in UTC (`"HH:MM-HH:MM"`) |
| `preferred_maintenance_window` | `string` | ❌ | `"sun:05:00-sun:06:00"` | Weekly maintenance window (`"ddd:HH:MM-ddd:HH:MM"`) |
| `skip_final_snapshot` | `bool` | ❌ | `true` | Skip final snapshot on deletion |
| `final_snapshot_identifier` | `string` | ❌ | `"<cluster_identifier>-final-snapshot"` | Name for the final snapshot (when `skip_final_snapshot = false`) |
| `snapshot_identifier` | `string` | ❌ | `null` | Snapshot ARN/identifier to restore from |

#### Parameter Group

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `parameter_group_name` | `string` | ❌ | `"<cluster_identifier>-params"` | Custom parameter group name |
| `parameter_group_family` | `string` | ❌ | Auto-derived from `engine_version` | `"docdb4.0"` or `"docdb5.0"` |
| `parameters` | `list(object)` | ❌ | `[]` | List of parameter overrides; an empty list skips group creation |

#### `parameters` Object

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | `string` | ✅ | — | Parameter name (e.g. `"tls"`, `"audit_logs"`) |
| `value` | `string` | ✅ | — | Parameter value |
| `apply_method` | `string` | ❌ | `"pending-reboot"` | `"immediate"` or `"pending-reboot"` |

#### Operational

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `deletion_protection` | `bool` | ❌ | `false` | Prevent accidental cluster deletion |
| `apply_immediately` | `bool` | ❌ | `false` | Apply modifications immediately instead of next maintenance window |
| `auto_minor_version_upgrade` | `bool` | ❌ | `true` | Automatically apply minor engine upgrades |
| `enabled_cloudwatch_logs_exports` | `list(string)` | ❌ | `["audit"]` | Log types to export: `"audit"` and/or `"profiler"` |
| `tags` | `map(string)` | ❌ | `{}` | Per-cluster tags merged with global `tags` |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `clusters` | `map(object)` | Full cluster details (endpoint, reader_endpoint, ARN, config) |
| `cluster_arns` | `map(string)` | Map of cluster keys to ARNs |
| `cluster_endpoints` | `map(string)` | Map of cluster keys to primary (write) endpoints |
| `reader_endpoints` | `map(string)` | Map of cluster keys to reader (load-balanced read) endpoints |
| `subnet_groups` | `map(object)` | Subnet group IDs and ARNs per cluster |
| `parameter_groups` | `map(object)` | Parameter group IDs and ARNs (only clusters with custom parameters) |
| `instances` | `map(object)` | Full instance details keyed by `<cluster_key>-<index>` |

## Connecting Your Application

DocumentDB is **VPC-only** — your application must run in the same VPC (or a peered/Transit Gateway connected VPC). Use the [MongoDB driver](https://www.mongodb.com/docs/drivers/) with TLS enabled.

```python
# Python example using pymongo
from pymongo import MongoClient

client = MongoClient(
    host="<cluster_endpoint>",
    port=27017,
    username="docdbadmin",
    password="<password>",
    tls=True,
    tlsCAFile="global-bundle.pem",   # Download from https://docs.aws.amazon.com/documentdb/latest/developerguide/ca_cert_rotation.html
)
```

## Notes

- **`iopt1` storage** is not available in all AWS regions or for all instance classes. Check the [DocumentDB pricing page](https://aws.amazon.com/documentdb/pricing/) before enabling.
- **Passwords** should never be stored in plain text. Use [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) or [SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) and reference the value dynamically.
- **TLS** is enabled by default on DocumentDB 4.0+. Disabling it requires a custom parameter group with `tls = disabled` and a cluster reboot.
- **`deletion_protection = true`** is recommended for production clusters; Terraform will fail `destroy` until it is explicitly set back to `false`.

## Related Resources

- [DocumentDB Overview](aws-documentdb.md)
- [AWS DocumentDB Documentation](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html)
- [Terraform aws_docdb_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster)
- [Terraform aws_docdb_cluster_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_instance)
- [Terraform aws_docdb_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_subnet_group)
- [Terraform aws_docdb_cluster_parameter_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster_parameter_group)
- [DocumentDB Pricing](https://aws.amazon.com/documentdb/pricing/)
- [Wrapper Plan](../../../../tf-plans/aws_documentdb/README.md)
