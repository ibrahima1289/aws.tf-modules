# AWS DocumentDB Wrapper

This wrapper provides a simplified, ready-to-use interface to the [AWS DocumentDB root module](../../modules/databases/non-relational/aws_documentdb/README.md). It demonstrates how to create and manage MongoDB-compatible DocumentDB clusters with configurable instances, storage options, parameter groups, backups, and CloudWatch log exports.

## Quick Start

1. Edit `terraform.tfvars` with your VPC, subnet, and security group IDs
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Usage Examples

The [terraform.tfvars](terraform.tfvars) file includes three patterns:

| # | Pattern | Description |
|---|---------|-------------|
| 1 | **Dev single-node** (active) | `db.t3.medium`, 1 instance, 1-day backup, no deletion protection |
| 2 | **Production HA** (commented) | `db.r5.large`, 3 instances, I/O-Optimized storage, CMK encryption, custom parameter group |
| 3 | **Snapshot restore** (commented) | Provision a new cluster from an existing snapshot for DR testing |

## Configuration

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region to deploy DocumentDB resources |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `clusters` | `map(object)` | `{}` | Map of DocumentDB clusters to create |

See the [root module README](../../modules/databases/non-relational/aws_documentdb/README.md) for the full `clusters` object schema with all attributes.

## Example: Dev Single-Node Cluster

```hcl
region = "us-east-1"

clusters = {
  dev-cluster = {
    cluster_identifier     = "app-docdb-dev"
    engine_version         = "5.0"
    master_username        = "docdbadmin"
    master_password        = "Dev$uperSecret1!"
    instance_class         = "db.t3.medium"
    instance_count         = 1
    subnet_ids             = ["subnet-aaa", "subnet-bbb"]
    vpc_security_group_ids = ["sg-xxxxxxx"]
    storage_encrypted      = true
    skip_final_snapshot    = true
  }
}
```

## Example: Production HA Cluster (3 Nodes)

```hcl
region = "us-east-1"

clusters = {
  prod-cluster = {
    cluster_identifier     = "app-docdb-prod"
    engine_version         = "5.0"
    master_username        = "docdbadmin"
    master_password        = "Pr0d$uperSecret1!"
    instance_class         = "db.r5.large"
    instance_count         = 3   # 1 primary + 2 replicas
    subnet_ids             = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    vpc_security_group_ids = ["sg-yyyyyyy"]

    storage_encrypted = true
    kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/xxx"
    storage_type      = "iopt1"   # I/O-Optimized for high throughput

    backup_retention_period = 7
    skip_final_snapshot     = false
    deletion_protection     = true

    # Custom parameter group to enforce TLS and capture all audit logs
    parameter_group_family = "docdb5.0"
    parameters = [
      { name = "tls",        value = "enabled", apply_method = "pending-reboot" },
      { name = "audit_logs", value = "all",     apply_method = "pending-reboot" }
    ]

    enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  }
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `clusters` | Full map of cluster details (endpoints, ARN, config) |
| `cluster_arns` | Map of cluster keys → ARNs |
| `cluster_endpoints` | Map of cluster keys → primary (write) endpoints |
| `reader_endpoints` | Map of cluster keys → reader (load-balanced read) endpoints |
| `subnet_groups` | Subnet group IDs and ARNs per cluster |
| `parameter_groups` | Parameter group IDs and ARNs (clusters with custom parameters only) |
| `instances` | Full instance details keyed by `<cluster_key>-<index>` |

## Important Notes

- **VPC-only access** — DocumentDB clusters are not publicly reachable. Your application must run in the same VPC or a peered network.
- **TLS is on by default** — Use the [global-bundle.pem](https://docs.aws.amazon.com/documentdb/latest/developerguide/ca_cert_rotation.html) CA certificate when connecting.
- **Passwords** — Never store passwords in plain text in version-controlled tfvars. Use [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/) or the [`aws_secretsmanager_secret_version`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) data source.
- **Deletion protection** — Set `deletion_protection = false` before running `terraform destroy` on protected clusters.
- **`iopt1` storage** — Check [regional availability](https://aws.amazon.com/documentdb/pricing/) before enabling; not all instance types support it.

## Related Resources

- [Root Module README](../../modules/databases/non-relational/aws_documentdb/README.md)
- [DocumentDB Overview](../../modules/databases/non-relational/aws_documentdb/aws-documentdb.md)
- [AWS DocumentDB Documentation](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html)
- [DocumentDB Pricing](https://aws.amazon.com/documentdb/pricing/)
