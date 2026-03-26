# AWS EBS — Wrapper Plan

This wrapper demonstrates three real-world EBS deployment patterns using the [aws_ebs module](../../modules/storage/aws_ebs/README.md).

> See [aws-ebs.md](../../modules/storage/aws_ebs/aws-ebs.md) for a full service reference and volume type pricing model.

---

## Architecture

```
  terraform.tfvars
       │
       ├── var.volumes (3 volumes: gp3 webapp, io2 database, st1 bigdata)
       ├── var.attachments (webapp → app server, database → db server)
       └── var.snapshots (database compliance snapshot)
                │
                ▼
         module "ebs" (main.tf)
                │
                ▼
  ┌───────────────────────────────────────────────────────────────┐
  │              aws_ebs_volume (for_each)                        │
  │                                                               │
  │   "webapp"   gp3 100 GiB  6,000 IOPS  250 MiB/s  SSE-AES      │
  │   "database" io2 500 GiB 10,000 IOPS             SSE-KMS      │
  │   "bigdata"  st1   2 TiB                         SSE-AES      │
  └───────────┬─────────────────────┬─────────────────────────────┘
              │                     │
  ┌───────────▼───────────┐ ┌───────▼───────────────┐
  │  aws_volume_attachment│ │   aws_ebs_snapshot    │
  │  webapp → i-0abc...   │ │   prod-db-manual-snap │
  │  database → i-0def... │ │   (compliance PCI-DSS)│
  └───────────────────────┘ └───────────────────────┘
```

---

## Configuration Patterns

### Pattern 1 — General Purpose SSD (`webapp` — `gp3`)

| Setting | Value |
|---------|-------|
| Volume type | gp3 |
| Size | 100 GiB |
| IOPS | 6,000 (above 3,000 baseline) |
| Throughput | 250 MiB/s (above 125 baseline) |
| Encryption | SSE with AWS-managed key |
| Final snapshot | `true` (safety net on destroy) |

### Pattern 2 — Provisioned IOPS SSD (`database` — `io2`)

| Setting | Value |
|---------|-------|
| Volume type | io2 |
| Size | 500 GiB |
| IOPS | 10,000 (guaranteed) |
| Encryption | SSE with customer-managed KMS key |
| Attachment | Attached with `stop_instance_before_detaching = true` |
| Snapshot | Manual compliance snapshot created at apply time |

### Pattern 3 — Throughput Optimized HDD (`bigdata` — `st1`)

| Setting | Value |
|---------|-------|
| Volume type | st1 |
| Size | 2,000 GiB (2 TB) |
| Max throughput | 500 MiB/s |
| Encryption | SSE with AWS-managed key |
| Use case | Spark/Hadoop large sequential reads/writes |

---

## Usage

```bash
cd tf-plans/aws_ebs
terraform init
terraform plan
terraform apply
```

> **Note:** Replace placeholder EC2 instance IDs in `terraform.tfvars` with actual running instance IDs before applying.

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
| `volumes` | `list(object)` | `[]` | EBS volume definitions (see `terraform.tfvars` examples) |
| `attachments` | `list(object)` | `[]` | Volume attachment definitions |
| `snapshots` | `list(object)` | `[]` | Snapshot definitions |

---

## Outputs

| Output | Description |
|--------|-------------|
| `volume_ids` | Map of volume key → EBS volume ID |
| `volume_arns` | Map of volume key → EBS volume ARN |
| `volume_types` | Map of volume key → volume type |
| `volume_sizes` | Map of volume key → size in GiB |
| `volume_availability_zones` | Map of volume key → AZ |
| `attachment_volume_ids` | Map of attachment key → attached volume ID |
| `attachment_device_names` | Map of attachment key → device name |
| `snapshot_ids` | Map of snapshot key → snapshot ID |
| `snapshot_arns` | Map of snapshot key → snapshot ARN |

---

## Tips

- For **automated recurring snapshots**, use [AWS Data Lifecycle Manager (DLM)](https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-lifecycle.html) rather than Terraform-managed snapshots.
- For **cross-region disaster recovery**, copy snapshots using `aws ec2 copy-snapshot --source-region ... --destination-region ...`.
- To **resize a volume** without downtime, update `size` in `terraform.tfvars` and run `terraform apply`; then extend the file system inside the OS.
- The `final_snapshot = true` flag is a safety net — enable it for all production volumes.

---

## File Structure

```
tf-plans/aws_ebs/
├── provider.tf       # Terraform + AWS provider constraints
├── variables.tf      # Input variable declarations
├── locals.tf         # created_date computation
├── main.tf           # Module call
├── outputs.tf        # Expose module outputs
├── terraform.tfvars  # 3 volumes (gp3/io2/st1), 2 attachments, 1 snapshot
└── README.md         # This file
```

---

## See Also

- [Module](../../modules/storage/aws_ebs/README.md)
- [Service overview](../../modules/storage/aws_ebs/aws-ebs.md)
- [AWS EBS documentation](https://docs.aws.amazon.com/ebs/latest/userguide/)
- [EBS pricing](https://aws.amazon.com/ebs/pricing/)
