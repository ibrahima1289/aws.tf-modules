# AWS Elastic Block Store (EBS) Module

Reusable Terraform module for [Amazon EBS](https://docs.aws.amazon.com/ebs/latest/userguide/what-is-ebs.html) — persistent, high-performance block-storage volumes for EC2 instances.

> See [aws-ebs.md](aws-ebs.md) for a full service reference, volume type comparison, and pricing model.

---

## Architecture

```
  ┌────────────────────────────────────────────────────────────────────┐
  │                       AWS EBS Module                               │
  │                                                                    │
  │  ┌──────────────────────────────────────────────────────────────┐  │
  │  │             aws_ebs_volume  (for_each)                       │  │
  │  │                                                              │  │
  │  │  ┌───────────┐  ┌───────────┐  ┌──────────┐  ┌──────────┐    │  │
  │  │  │   gp3     │  │  io1/io2  │  │   st1    │  │   sc1    │    │  │
  │  │  │ General   │  │Provisioned│  │Throughput│  │  Cold    │    │  │
  │  │  │ Purpose   │  │   IOPS    │  │ Optimized│  │   HDD    │    │  │
  │  │  └───────────┘  └───────────┘  └──────────┘  └──────────┘    │  │
  │  │                                                              │  │
  │  │  ─ Encryption at rest (SSE / customer KMS key)               │  │
  │  │  ─ Multi-Attach support (io1/io2 only)                       │  │
  │  │  ─ Restore from snapshot                                     │  │
  │  │  ─ Final snapshot before destroy                             │  │
  │  └──────────────────────┬───────────────────────────────────────┘  │
  │                         │                                          │
  │          ┌──────────────┴──────────────┐                           │
  │          ▼                             ▼                           │
  │  ┌───────────────────────┐   ┌─────────────────────────┐           │
  │  │  aws_volume_attachment│   │    aws_ebs_snapshot     │           │
  │  │  ─ device_name        │   │  ─ point-in-time backup │           │
  │  │  ─ instance_id        │   │  ─ incremental (S3)     │           │
  │  │  ─ force_detach       │   │  ─ cross-region copyable│           │
  │  │  ─ stop before detach │   └────────────┬────────────┘           │
  │  └──────────┬────────────┘                │                        │
  └─────────────┼─────────────────────────────┼────────────────────────┘
                ▼                             ▼
     ┌─────────────────────┐      ┌─────────────────────┐
     │    EC2 Instance     │      │   Amazon S3         │
     │  (receives volume   │      │  (snapshot backend; │
     │   on device_name)   │      │   managed by AWS)   │
     └─────────────────────┘      └─────────────────────┘
```

---

## Resources Created

| Resource | Description |
|----------|-------------|
| `aws_ebs_volume` | Persistent block-storage volume (gp3/io2/st1/sc1; optional encryption and snapshot restore) |
| `aws_volume_attachment` | Attaches a managed volume to an EC2 instance |
| `aws_ebs_snapshot` | Point-in-time incremental backup of a managed volume |

---

## Usage

```hcl
module "ebs" {
  source = "../../modules/storage/aws_ebs"

  region = "us-east-1"
  tags   = { environment = "production", team = "platform" }

  volumes = [
    {
      key               = "webapp"
      name              = "webapp-data"
      availability_zone = "us-east-1a"
      type              = "gp3"
      size              = 100
      encrypted         = true
    },
    {
      key               = "database"
      name              = "db-data"
      availability_zone = "us-east-1a"
      type              = "io2"
      size              = 500
      iops              = 10000
      encrypted         = true
      kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"
    }
  ]

  attachments = [
    {
      key         = "webapp-attach"
      volume_key  = "webapp"
      instance_id = "i-0abc123def456789"
      device_name = "/dev/xvdf"
    }
  ]

  snapshots = [
    {
      key         = "db-snap"
      volume_key  = "database"
      name        = "db-daily-snapshot"
      description = "Daily snapshot of production database volume"
    }
  ]
}
```

---

## Multi-Attach

> **Supported volume types:** `io1` and `io2` only. The module enforces this with a `lifecycle precondition` — Terraform will emit a clear error at plan time if `multi_attach_enabled = true` is set on any other type.

Multi-Attach lets a single EBS volume be simultaneously attached to **up to 16 Nitro-based EC2 instances** in the same Availability Zone.

**Requirements**

| Requirement | Detail |
|---|---|
| Volume type | `io1` or `io2` |
| File system | Cluster-aware: GFS2, OCFS2 (prevents concurrent-write corruption) |
| Attachment flag | `skip_destroy = true` on every attachment (avoids parallel-detach races) |

```hcl
module "ebs_cluster" {
  source = "../../modules/storage/aws_ebs"
  region = "us-east-1"
  tags   = { environment = "production", cluster = "app-cluster" }

  volumes = [
    {
      key                  = "cluster-shared"
      name                 = "cluster-shared-vol"
      availability_zone    = "us-east-1a"
      type                 = "io2"    # required for Multi-Attach
      size                 = 200
      iops                 = 5000     # required for io2
      encrypted            = true
      multi_attach_enabled = true     # enables simultaneous multi-instance access
    }
  ]

  attachments = [
    {
      key          = "cluster-node1"
      volume_key   = "cluster-shared"
      instance_id  = "i-0aaa111bbb222ccc1"
      device_name  = "/dev/xvdf"
      skip_destroy = true             # recommended for multi-attach volumes
    },
    {
      key          = "cluster-node2"
      volume_key   = "cluster-shared"  # same volume_key → same physical EBS volume
      instance_id  = "i-0ddd333eee444fff2"
      device_name  = "/dev/xvdf"
      skip_destroy = true
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
| `volumes` | `list(object)` | `[]` | EBS volume definitions (see below) |
| `attachments` | `list(object)` | `[]` | Volume attachment definitions (see below) |
| `snapshots` | `list(object)` | `[]` | Snapshot definitions (see below) |

### `volumes` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Value written to the `Name` tag |
| `availability_zone` | `string` | required | AZ for the volume (must match target EC2 AZ) |
| `type` | `string` | `"gp3"` | Volume type: `gp3`, `gp2`, `io1`, `io2`, `st1`, `sc1` |
| `size` | `number` | `20` | Size in GiB |
| `iops` | `number` | `null` | Provisioned IOPS (required for io1/io2; optional for gp3) |
| `throughput` | `number` | `null` | Throughput in MiB/s — gp3 only (max 1,000) |
| `encrypted` | `bool` | `true` | Encrypt the volume at rest |
| `kms_key_id` | `string` | `null` | Customer-managed KMS key ARN; `null` uses the AWS-managed key |
| `multi_attach_enabled` | `bool` | `false` | Attach to multiple instances (io1/io2 only) |
| `snapshot_id` | `string` | `null` | Restore from this snapshot ID |
| `final_snapshot` | `bool` | `false` | Take a snapshot before the volume is destroyed |
| `tags` | `map(string)` | `{}` | Additional tags for this volume |

### `attachments` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `volume_key` | `string` | required | Key of an entry in `volumes` |
| `instance_id` | `string` | required | EC2 instance ID to attach to |
| `device_name` | `string` | required | Block device name inside the instance (e.g. `/dev/xvdf`) |
| `force_detach` | `bool` | `false` | Force detach on destroy (may cause data loss) |
| `skip_destroy` | `bool` | `false` | Do not detach on destroy (orphans the attachment) |
| `stop_instance_before_detaching` | `bool` | `false` | Stop the instance before detach, restart after |

### `snapshots` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `volume_key` | `string` | required | Key of an entry in `volumes` |
| `name` | `string` | required | Value written to the `Name` tag |
| `description` | `string` | `""` | Human-readable description stored with the snapshot |
| `tags` | `map(string)` | `{}` | Additional tags for this snapshot |

---

## Outputs

| Output | Description |
|--------|-------------|
| `volume_ids` | Map of volume key → EBS volume ID |
| `volume_arns` | Map of volume key → EBS volume ARN |
| `volume_types` | Map of volume key → volume type |
| `volume_sizes` | Map of volume key → size in GiB |
| `volume_availability_zones` | Map of volume key → Availability Zone |
| `attachment_volume_ids` | Map of attachment key → attached volume ID |
| `attachment_device_names` | Map of attachment key → device name |
| `snapshot_ids` | Map of snapshot key → snapshot ID |
| `snapshot_arns` | Map of snapshot key → snapshot ARN |

---

## Volume Type Quick Reference

| Type | Use Case | Max IOPS | Max Throughput | Bootable |
|------|----------|----------|----------------|----------|
| `gp3` | General purpose (web, dev, small DB) | 16,000 | 1,000 MiB/s | ✅ |
| `gp2` | Legacy general purpose | 16,000 | 250 MiB/s | ✅ |
| `io1` | High-IOPS databases (SQL, Oracle) | 64,000 | 1,000 MiB/s | ✅ |
| `io2` | Mission-critical databases (99.999% durability) | 64,000 | 1,000 MiB/s | ✅ |
| `st1` | Big data, log processing, data warehouses | 500 | 500 MiB/s | ❌ |
| `sc1` | Infrequent access, archival | 250 | 250 MiB/s | ❌ |

---

## Notes

- EBS volumes are **Availability Zone-bound** — they can only be attached to EC2 instances in the same AZ.
- `iops` must be set for `io1`/`io2` volumes; it is ignored for `gp2`, `st1`, `sc1`.
- `throughput` is only valid for `gp3` volumes; the provider ignores it for other types.
- `multi_attach_enabled` requires `io1` or `io2` — enforced by a module `precondition` that fails the plan early on any other type. All attached instances must run a cluster-aware file system (e.g., GFS2, OCFS2). Set `skip_destroy = true` on every attachment to avoid concurrent-detach race conditions during `terraform destroy`.
- Setting `encrypted = true` with `kms_key_id = null` uses the per-region AWS-managed EBS key (`alias/aws/ebs`).
- `final_snapshot = true` causes Terraform to create a snapshot before destroying the volume — useful as a safety net.
- Snapshots created by this module are billed at **$0.05/GB-month** in most regions.

---

## See Also

- [Wrapper plan](../../../tf-plans/aws_ebs/README.md)
- [Service overview](aws-ebs.md)
- [AWS EBS documentation](https://docs.aws.amazon.com/ebs/latest/userguide/)
- [Terraform aws_ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume)
- [Terraform aws_volume_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment)
- [Terraform aws_ebs_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot)
