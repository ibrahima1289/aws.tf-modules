# AWS Storage Gateway — Wrapper Plan

> [Back to Module Service List](../../aws-module-service-list.md) | [Root Module](../../modules/storage/aws-storage-gateway/README.md) | [Resource Guide](../../modules/storage/aws-storage-gateway/aws-storage-gateway.md)

This wrapper plan demonstrates production-ready [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) configurations using the reusable root module. It deploys two gateways — an **S3 File Gateway** and a **VTL Tape Gateway** — with all common resource patterns pre-configured.

## Architecture

```
  On-Premises (VMware / Hyper-V / EC2)
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌───────────────────────────────────────┐                                  │
│  │   prod-s3-file-gateway (FILE_S3)      │                                  │
│  │   Cache: /dev/sdb                     │                                  │
│  │   ┌─────────────────────────────┐     │   NFS mount:                     │
│  │   │  media-nfs  (NFS, KMS-SSE)  │─────┼── <gw-ip>:/my-media-bucket       │
│  │   │  analytics-nfs-ro (NFS, RO) │─────┼── <gw-ip>:/my-analytics-bucket   │
│  │   │  docs-smb-guest (SMB Guest) │─────┼── \\<gw-ip>\Documents            │
│  │   │  finance-smb-ad (SMB AD)    │─────┼── \\<gw-ip>\Finance              │
│  │   └─────────────────────────────┘     │                                  │
│  └───────────────────────────────────────┘                                  │
│                                                                             │
│  ┌───────────────────────────────────────┐                                  │
│  │   prod-vtl-gateway (VTL)              │  iSCSI VTL (Veeam / Commvault)   │
│  │   Drive: IBM-ULT3580-TD5              │                                  │
│  │   Changer: AWS-Gateway-VTL            │                                  │
│  │   Upload Buffer: /dev/sdb             │                                  │
│  └───────────────────────────────────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────┘
               │ HTTPS / TLS 1.2   │ HTTPS / TLS 1.2
  ┌────────────▼───────────────────▼────────────────────────────────────────┐
  │                          AWS Cloud (us-east-1)                          │
  │                                                                         │
  │   Amazon S3                  Amazon S3 Glacier       Deep Archive       │
  │  ┌────────────────────┐     ┌─────────────────────────────────────────┐ │
  │  │ my-media-bucket    │     │ prod-glacier-tape-pool (30d GOVERNANCE) │ │
  │  │ my-analytics-bucket│     │ prod-deep-archive-pool (7yr COMPLIANCE) │ │
  │  │ my-documents-bucket│     └─────────────────────────────────────────┘ │
  │  │ my-finance-bucket  │       KMS-encrypted at rest (SSE-KMS)           │
  │  └────────────────────┘                                                 │
  └─────────────────────────────────────────────────────────────────────────┘
```

## What This Wrapper Deploys

| Resource | Key | Description |
|----------|-----|-------------|
| S3 File Gateway | `prod-file-gw` | FILE_S3 gateway, maintenance window Sun 02:30 UTC |
| VTL Tape Gateway | `prod-tape-gw` | VTL gateway with IBM drives, 100 Mbps upload cap |
| Cache Disk | `file-gw-cache-sdb` | `/dev/sdb` cache for the File Gateway |
| Upload Buffer | `tape-gw-buffer-sdb` | `/dev/sdb` upload buffer for the VTL Gateway |
| NFS Share | `media-nfs` | KMS-encrypted, S3 Intelligent-Tiering, RootSquash |
| NFS Share | `analytics-nfs-ro` | Read-only, S3 Standard-IA, AllSquash |
| SMB Share | `docs-smb-guest` | GuestAccess, KMS-encrypted, OpLocks enabled |
| SMB Share | `finance-smb-ad` | ActiveDirectory, ACL-enabled, access-based enumeration |
| Tape Pool | `glacier-pool-30d` | S3 Glacier, GOVERNANCE lock (30 days) |
| Tape Pool | `deep-archive-pool-2555d` | S3 Deep Archive, COMPLIANCE lock (7 years) |

## Prerequisites

Before running `terraform apply`, ensure:

1. **Gateway VMs are deployed and running** at the IP addresses (or activation keys) referenced in `terraform.tfvars`. Deploy the [Storage Gateway AMI](https://aws.amazon.com/storagegateway/pricing/#Hardware_appliance_option) on VMware, Hyper-V, KVM, or [Amazon EC2](https://docs.aws.amazon.com/storagegateway/latest/userguide/ec2-gateway-common-setup.html).

2. **IAM role for S3 access** (`StorageGatewayS3Role`) exists with a trust policy for `storagegateway.amazonaws.com` and inline permissions including `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`, `s3:GetBucketLocation`, and `kms:GenerateDataKey`/`kms:Decrypt` (if using KMS).

3. **S3 buckets exist** — `my-media-bucket`, `my-analytics-bucket`, `my-documents-bucket`, `my-finance-bucket`. Buckets must be in the same region as the gateway.

4. **KMS key exists** — replace the placeholder KMS ARN in `terraform.tfvars` with a real customer-managed key.

5. **Activation keys** — replace placeholder keys in `terraform.tfvars` with real activation keys. Keys expire after 30 minutes; see [activating your gateway](https://docs.aws.amazon.com/storagegateway/latest/userguide/get-activation-key.html).

6. **Local disks attached** — `/dev/sdb` (or equivalent) must be attached to each gateway VM before Terraform configures cache and upload buffer resources.

7. **Active Directory** (for `finance-smb-ad`) — add `smb_active_directory_settings` to `prod-file-gw` in `terraform.tfvars` to join the gateway to your AD domain.

## Usage

```bash
# Initialise provider and module dependencies
terraform init

# Preview the deployment plan
terraform plan

# Deploy all resources
terraform apply

# View key outputs
terraform output gateway_arns
terraform output nfs_share_paths
terraform output smb_share_paths
terraform output tape_pool_arns
```

## Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | — | AWS region (e.g., `"us-east-1"`) |
| `tags` | `map(string)` | No | `{}` | Tags applied to every resource |
| `gateways` | `list(object)` | No | `[]` | Gateway definitions (see root module) |
| `cache_disks` | `list(object)` | No | `[]` | Cache disk assignments |
| `upload_buffers` | `list(object)` | No | `[]` | Upload buffer disk assignments |
| `nfs_file_shares` | `list(object)` | No | `[]` | NFS share definitions |
| `smb_file_shares` | `list(object)` | No | `[]` | SMB share definitions |
| `cached_volumes` | `list(object)` | No | `[]` | Cached iSCSI volume definitions |
| `stored_volumes` | `list(object)` | No | `[]` | Stored iSCSI volume definitions |
| `tape_pools` | `list(object)` | No | `[]` | Tape pool definitions |

## Outputs

| Output | Description |
|--------|-------------|
| `gateway_ids` | Map of gateway key → gateway ID |
| `gateway_arns` | Map of gateway key → gateway ARN |
| `gateway_names` | Map of gateway key → display name |
| `nfs_share_ids` | Map of NFS share key → file share ID |
| `nfs_share_arns` | Map of NFS share key → file share ARN |
| `nfs_share_paths` | Map of NFS share key → NFS mount path |
| `smb_share_ids` | Map of SMB share key → file share ID |
| `smb_share_arns` | Map of SMB share key → file share ARN |
| `smb_share_paths` | Map of SMB share key → SMB path |
| `cached_volume_arns` | Map of cached volume key → volume ARN |
| `cached_volume_target_arns` | Map of cached volume key → iSCSI target ARN |
| `stored_volume_arns` | Map of stored volume key → volume ARN |
| `stored_volume_target_arns` | Map of stored volume key → iSCSI target ARN |
| `tape_pool_ids` | Map of tape pool key → pool ID |
| `tape_pool_arns` | Map of tape pool key → pool ARN |

## Adding More Gateways

To add a Volume Gateway or FSx File Gateway, extend the `terraform.tfvars` lists:

```hcl
# Add to gateways list:
{
  key          = "prod-cached-gw"
  name         = "prod-volume-cached-gateway"
  timezone     = "GMT"
  gateway_type = "CACHED"
  activation_key = "KKKKK-LLLLL-MMMMM-NNNNN-OOOOO"
}

# Add to upload_buffers:
{ key = "cached-gw-buffer", gateway_key = "prod-cached-gw", disk_id = "/dev/sdb" }

# Add to cache_disks:
{ key = "cached-gw-cache",  gateway_key = "prod-cached-gw", disk_id = "/dev/sdc" }

# Add to cached_volumes:
{
  key                  = "app-vol-100g"
  gateway_key          = "prod-cached-gw"
  network_interface_id = "10.0.1.20"
  target_name          = "app-iscsi-target"
  volume_size_in_bytes = 107374182400  # 100 GiB
  kms_encrypted        = true
  kms_key              = "arn:aws:kms:us-east-1:123456789012:key/..."
}
```

## Cost Considerations

See [AWS Storage Gateway Pricing](https://aws.amazon.com/storagegateway/pricing/) and the [AWS Pricing Guide](../../aws-services-pricing-guide.md) for detailed breakdowns.

| Component | Cost |
|-----------|------|
| File/Volume/Tape Gateway | Free (pay for underlying resources) |
| S3 storage via File Gateway | Standard [S3 pricing](https://aws.amazon.com/s3/pricing/) |
| S3 Glacier tape archiving | ~$0.004/GB-month |
| S3 Deep Archive tape archiving | ~$0.00099/GB-month |
| Data written to cloud | $0.01/GB (S3 File and Volume) |
| Hardware Appliance | One-time purchase (~$14,000 USD) |
