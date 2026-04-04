# AWS Storage Gateway Terraform Module

> [Back to Module Service List](../../../aws-module-service-list.md) | [Resource Guide](aws-storage-gateway.md) | [Wrapper Plan](../../../tf-plans/aws_storage_gateway/README.md)

This module creates [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) resources with comprehensive configuration options:

- **Multiple gateway types** — S3 File, FSx File, Volume (Cached/Stored), and Tape (VTL) via `for_each`
- **NFS and SMB file shares** — backed by Amazon S3 with per-share KMS encryption, access controls, and audit logging
- **iSCSI block volumes** — cached (primary in S3) and stored (primary on-premises) with optional snapshot seeding
- **Virtual tape pools** — Glacier or Deep Archive with GOVERNANCE/COMPLIANCE retention lock
- **Upload buffers & cache disks** — local disk configuration for Volume and File Gateways
- **Consistent tagging** — `created_date` and common tags applied to all resources

## Architecture

```
  On-Premises Environment
┌─────────────────────────────────────────────────────────────────────────┐
│  NFS / SMB Clients      iSCSI Initiators      Backup Software (VTL)     │
│        │ NFS/SMB               │ iSCSI               │ iSCSI VTL        │
│  ┌─────▼───────────────────────▼─────────────────────▼────────────────┐ │
│  │           Storage Gateway VM / Hardware Appliance                  │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │ │
│  │  │  Cache Disk  │  │Upload Buffer │  │  Local Volume Disk       │  │ │
│  │  │ (hot data)   │  │(stage to S3) │  │  (STORED mode only)      │  │ │
│  │  └──────┬───────┘  └──────┬───────┘  └────────────┬─────────────┘  │ │
│  └─────────│─────────────────│───────────────────────│────────────────┘ │
└────────────│─────────────────│───────────────────────│──────────────────┘
             │ HTTPS / TLS 1.2 │                       │
      ┌──────▼─────────────────▼───────────────────────▼───────────┐
      │                   AWS Storage Backend                      │
      │  FILE_S3      → Amazon S3  (any storage class)             │
      │  FILE_FSX_SMB → Amazon FSx for Windows File Server         │
      │  CACHED/STORED→ Amazon S3 + EBS Snapshots                  │
      │  VTL          → Amazon S3 → S3 Glacier / Deep Archive      │
      └────────────────────────────────────────────────────────────┘
```

## Requirements

| Tool | Minimum Version |
|------|----------------|
| [Terraform](https://www.terraform.io/downloads.html) | >= 1.3 |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | >= 5.0 |

## Resources Created

| Resource | Description |
|----------|-------------|
| [`aws_storagegateway_gateway`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway) | Storage Gateway (any type) |
| [`aws_storagegateway_cache`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_cache) | Cache disk for File/Volume Gateways |
| [`aws_storagegateway_upload_buffer`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_upload_buffer) | Upload buffer for Volume/Tape Gateways |
| [`aws_storagegateway_nfs_file_share`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_nfs_file_share) | NFS v3/v4.1 file share (FILE_S3) |
| [`aws_storagegateway_smb_file_share`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_smb_file_share) | SMB 2/3 file share (FILE_S3, FILE_FSX_SMB) |
| [`aws_storagegateway_cached_iscsi_volume`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_cached_iscsi_volume) | Cached iSCSI volume (CACHED) |
| [`aws_storagegateway_stored_iscsi_volume`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_stored_iscsi_volume) | Stored iSCSI volume (STORED) |
| [`aws_storagegateway_tape_pool`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_tape_pool) | Virtual tape pool (VTL) |

## Inputs

### Top-Level Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | — | AWS region for all Storage Gateway resources |
| `tags` | `map(string)` | No | `{}` | Common tags applied to every taggable resource |
| `gateways` | `list(object)` | No | `[]` | List of gateways to create (see below) |
| `nfs_file_shares` | `list(object)` | No | `[]` | NFS file shares for FILE_S3 gateways |
| `smb_file_shares` | `list(object)` | No | `[]` | SMB file shares for FILE_S3/FILE_FSX_SMB gateways |
| `upload_buffers` | `list(object)` | No | `[]` | Upload buffer disks for Volume/Tape Gateways |
| `cache_disks` | `list(object)` | No | `[]` | Cache disks for File/Volume Gateways |
| `cached_volumes` | `list(object)` | No | `[]` | Cached iSCSI volumes for CACHED gateways |
| `stored_volumes` | `list(object)` | No | `[]` | Stored iSCSI volumes for STORED gateways |
| `tape_pools` | `list(object)` | No | `[]` | Virtual tape pools for VTL gateways |

---

### `gateways[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier used as the `for_each` key |
| `name` | `string` | ✅ Yes | — | Gateway display name shown in the AWS Console |
| `timezone` | `string` | ✅ Yes | — | IANA timezone for maintenance window (e.g., `"GMT"`) |
| `gateway_type` | `string` | ✅ Yes | — | `FILE_S3`, `FILE_FSX_SMB`, `CACHED`, `STORED`, or `VTL` |
| `activation_key` | `string` | ⚠️ One of | `null` | Pre-obtained activation key (mutually exclusive with `gateway_ip_address`) |
| `gateway_ip_address` | `string` | ⚠️ One of | `null` | Gateway IP; provider auto-fetches the activation key |
| `cloudwatch_log_group_arn` | `string` | No | `null` | CloudWatch log group ARN for audit logging |
| `average_download_rate_limit_in_bits_per_sec` | `number` | No | `null` | Download bandwidth cap (bits/sec) |
| `average_upload_rate_limit_in_bits_per_sec` | `number` | No | `null` | Upload bandwidth cap (bits/sec) |
| `maintenance_start_time` | `object` | No | `null` | Maintenance window: `{ hour_of_day, day_of_week?, day_of_month?, minute_of_hour? }` |
| `tape_drive_type` | `string` | No | `null` | VTL only — e.g., `"IBM-ULT3580-TD5"` |
| `medium_changer_type` | `string` | No | `null` | VTL only — e.g., `"AWS-Gateway-VTL"` |
| `smb_active_directory_settings` | `object` | No | `null` | AD settings: `{ domain_name, username, password, domain_controllers?, organizational_unit?, timeout_in_seconds? }` |
| `smb_guest_password` | `string` | No | `null` | Guest password for GuestAccess SMB shares |
| `tags` | `map(string)` | No | `{}` | Per-gateway tags merged with common tags |

---

### `nfs_file_shares[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `gateway_key` | `string` | ✅ Yes | — | Parent gateway key from `gateways[].key` |
| `location_arn` | `string` | ✅ Yes | — | S3 bucket ARN backing this NFS share |
| `role_arn` | `string` | ✅ Yes | — | IAM role ARN with S3 read/write permissions |
| `client_list` | `list(string)` | ✅ Yes | — | Allowed client CIDR blocks (e.g., `["10.0.0.0/8"]`) |
| `default_storage_class` | `string` | No | `"S3_STANDARD"` | `S3_STANDARD`, `S3_STANDARD_IA`, `S3_ONEZONE_IA`, `S3_INTELLIGENT_TIERING` |
| `kms_encrypted` | `bool` | No | `false` | Enable KMS server-side encryption |
| `kms_key_arn` | `string` | No | `null` | KMS key ARN (required when `kms_encrypted = true`) |
| `object_acl` | `string` | No | `"private"` | S3 object ACL for new objects |
| `read_only` | `bool` | No | `false` | Make share read-only for NFS clients |
| `requester_pays` | `bool` | No | `false` | Charge data-transfer to requester |
| `squash` | `string` | No | `"RootSquash"` | `RootSquash`, `NoSquash`, or `AllSquash` |
| `nfs_file_share_defaults` | `object` | No | `null` | Default Unix permissions: `{ directory_mode, file_mode, group_id, owner_id }` |
| `file_share_name` | `string` | No | `null` | Override share name visible to NFS clients |
| `guess_mime_type_enabled` | `bool` | No | `true` | Infer MIME type from file extension |
| `notification_policy` | `string` | No | `null` | S3 event notification policy JSON |
| `vpc_endpoint_dns_name` | `string` | No | `null` | VPC endpoint DNS name for PrivateLink |
| `bucket_region` | `string` | No | `null` | S3 bucket region (cross-region targets) |
| `audit_destination_arn` | `string` | No | `null` | CloudWatch log group ARN for NFS audit logs |
| `tags` | `map(string)` | No | `{}` | Per-share tags |

---

### `smb_file_shares[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `gateway_key` | `string` | ✅ Yes | — | Parent gateway key from `gateways[].key` |
| `location_arn` | `string` | ✅ Yes | — | S3 bucket ARN backing this SMB share |
| `role_arn` | `string` | ✅ Yes | — | IAM role ARN with S3 read/write permissions |
| `authentication` | `string` | No | `"GuestAccess"` | `ActiveDirectory` or `GuestAccess` |
| `default_storage_class` | `string` | No | `"S3_STANDARD"` | S3 storage class for new objects |
| `kms_encrypted` | `bool` | No | `false` | Enable KMS server-side encryption |
| `kms_key_arn` | `string` | No | `null` | KMS key ARN (required when `kms_encrypted = true`) |
| `object_acl` | `string` | No | `"private"` | S3 object ACL |
| `read_only` | `bool` | No | `false` | Make share read-only |
| `requester_pays` | `bool` | No | `false` | Charge data-transfer to requester |
| `access_based_enumeration` | `bool` | No | `false` | Hide share from users without access (AD only) |
| `valid_user_list` | `list(string)` | No | `[]` | AD users/groups allowed (AD auth only) |
| `invalid_user_list` | `list(string)` | No | `[]` | AD users/groups denied (AD auth only) |
| `admin_user_list` | `list(string)` | No | `[]` | AD users/groups with full admin rights |
| `file_share_name` | `string` | No | `null` | Override share display name |
| `guess_mime_type_enabled` | `bool` | No | `true` | Infer MIME type from file extension |
| `smb_acl_enabled` | `bool` | No | `false` | Enforce Windows ACLs on the share |
| `case_sensitivity` | `string` | No | `"ClientSpecified"` | `ClientSpecified` or `ForcedCaseSensitivity` |
| `notification_policy` | `string` | No | `null` | S3 event notification policy JSON |
| `vpc_endpoint_dns_name` | `string` | No | `null` | VPC endpoint DNS name for PrivateLink |
| `bucket_region` | `string` | No | `null` | S3 bucket region (cross-region targets) |
| `audit_destination_arn` | `string` | No | `null` | CloudWatch log group ARN for SMB audit logs |
| `oplocks_enabled` | `bool` | No | `true` | Enable SMB OpLocks for client performance |
| `tags` | `map(string)` | No | `{}` | Per-share tags |

---

### `upload_buffers[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `gateway_key` | `string` | ✅ Yes | — | Parent gateway key from `gateways[].key` |
| `disk_id` | `string` | ⚠️ One of | `null` | Local disk identifier on the gateway host |
| `disk_path` | `string` | ⚠️ One of | `null` | Local disk path (alternative to `disk_id`) |

---

### `cache_disks[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `gateway_key` | `string` | ✅ Yes | — | Parent gateway key from `gateways[].key` |
| `disk_id` | `string` | ✅ Yes | — | Local disk identifier to use as cache |

---

### `cached_volumes[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `gateway_key` | `string` | ✅ Yes | — | Parent CACHED gateway key |
| `network_interface_id` | `string` | ✅ Yes | — | Network interface IP for iSCSI target |
| `target_name` | `string` | ✅ Yes | — | iSCSI target name (IQN suffix) |
| `volume_size_in_bytes` | `number` | ✅ Yes | — | Volume size in bytes (multiple of 512) |
| `snapshot_id` | `string` | No | `null` | Seed volume from EBS snapshot |
| `source_volume_arn` | `string` | No | `null` | Clone from existing volume ARN |
| `kms_encrypted` | `bool` | No | `false` | Encrypt volume data with KMS |
| `kms_key` | `string` | No | `null` | KMS key ARN (required when `kms_encrypted = true`) |
| `tags` | `map(string)` | No | `{}` | Per-volume tags |

---

### `stored_volumes[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `gateway_key` | `string` | ✅ Yes | — | Parent STORED gateway key |
| `network_interface_id` | `string` | ✅ Yes | — | Network interface IP for iSCSI target |
| `target_name` | `string` | ✅ Yes | — | iSCSI target name (IQN suffix) |
| `disk_id` | `string` | ✅ Yes | — | Local disk ID backing this volume |
| `preserve_existing_data` | `bool` | No | `false` | Preserve disk data on volume creation |
| `snapshot_id` | `string` | No | `null` | Seed volume from EBS snapshot |
| `kms_encrypted` | `bool` | No | `false` | Encrypt EBS snapshots with KMS |
| `kms_key` | `string` | No | `null` | KMS key ARN (required when `kms_encrypted = true`) |
| `tags` | `map(string)` | No | `{}` | Per-volume tags |

---

### `tape_pools[]` Object

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | — | Unique identifier for `for_each` |
| `name` | `string` | ✅ Yes | — | Display name for the tape pool |
| `storage_class` | `string` | ✅ Yes | — | `GLACIER` or `DEEP_ARCHIVE` |
| `retention_lock_type` | `string` | No | `"NONE"` | `NONE`, `GOVERNANCE`, or `COMPLIANCE` |
| `retention_lock_time_in_days` | `number` | No | `null` | Minimum days before tape deletion (required for GOVERNANCE/COMPLIANCE) |
| `tags` | `map(string)` | No | `{}` | Per-pool tags |

---

## Outputs

| Output | Description |
|--------|-------------|
| `gateway_ids` | Map of gateway key → gateway ID |
| `gateway_arns` | Map of gateway key → gateway ARN |
| `gateway_names` | Map of gateway key → gateway display name |
| `nfs_share_ids` | Map of NFS share key → file share ID |
| `nfs_share_arns` | Map of NFS share key → file share ARN |
| `nfs_share_paths` | Map of NFS share key → NFS mount path |
| `smb_share_ids` | Map of SMB share key → file share ID |
| `smb_share_arns` | Map of SMB share key → file share ARN |
| `smb_share_paths` | Map of SMB share key → SMB share path |
| `cached_volume_arns` | Map of cached volume key → volume ARN |
| `cached_volume_target_arns` | Map of cached volume key → iSCSI target ARN |
| `cached_volume_ids` | Map of cached volume key → volume ID |
| `stored_volume_arns` | Map of stored volume key → volume ARN |
| `stored_volume_target_arns` | Map of stored volume key → iSCSI target ARN |
| `stored_volume_ids` | Map of stored volume key → volume ID |
| `tape_pool_ids` | Map of tape pool key → pool ID |
| `tape_pool_arns` | Map of tape pool key → pool ARN |

## Tags

All taggable resources receive the `created_date` tag (`YYYY-MM-DD`) from `locals.created_date`, merged with any common and per-resource `tags` supplied by the caller.

## Usage

```hcl
module "storage_gateway" {
  source = "../../modules/storage/aws-storage-gateway"
  region = "us-east-1"

  tags = {
    Environment = "prod"
    Team        = "platform"
  }

  # ── S3 File Gateway ─────────────────────────────────────────────────────────
  gateways = [
    {
      key          = "prod-file-gw"
      name         = "prod-s3-file-gateway"
      timezone     = "GMT"
      gateway_type = "FILE_S3"
      # Provide activation_key or gateway_ip_address — not both
      activation_key = "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
      maintenance_start_time = {
        hour_of_day    = 2
        day_of_week    = 0   # Sunday
        minute_of_hour = 30
      }
    }
  ]

  # ── Cache disk for the File Gateway ─────────────────────────────────────────
  cache_disks = [
    {
      key         = "file-gw-cache"
      gateway_key = "prod-file-gw"
      disk_id     = "/dev/sdb"
    }
  ]

  # ── NFS share backed by S3 ───────────────────────────────────────────────────
  nfs_file_shares = [
    {
      key          = "media-nfs"
      gateway_key  = "prod-file-gw"
      location_arn = "arn:aws:s3:::my-media-bucket"
      role_arn     = "arn:aws:iam::123456789012:role/StorageGatewayS3Role"
      client_list  = ["10.0.0.0/8"]
      squash       = "RootSquash"
      kms_encrypted = true
      kms_key_arn   = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
    }
  ]

  # ── SMB GuestAccess share backed by S3 ──────────────────────────────────────
  smb_file_shares = [
    {
      key            = "docs-smb"
      gateway_key    = "prod-file-gw"
      location_arn   = "arn:aws:s3:::my-docs-bucket"
      role_arn       = "arn:aws:iam::123456789012:role/StorageGatewayS3Role"
      authentication = "GuestAccess"
    }
  ]
}
```

## Prerequisites

Before applying this module, ensure the following are in place:

1. **Gateway VM/appliance is running** — The gateway must be deployed (VMware ESXi, Hyper-V, KVM, or Amazon EC2) and network-reachable from the Terraform host.
2. **Activation** — Either retrieve the `activation_key` from `http://<gateway-ip>/localconsole` or supply `gateway_ip_address` and let the provider activate automatically.
3. **IAM role for S3 access** — An IAM role allowing the gateway to `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`, etc. on the target S3 buckets.
4. **Local disks** — Cache and/or upload buffer disks must be attached to the gateway VM before configuring `cache_disks` and `upload_buffers`.
5. **Active Directory** (optional) — For `authentication = "ActiveDirectory"` SMB shares, the gateway must be joined to the AD domain via `smb_active_directory_settings`.
