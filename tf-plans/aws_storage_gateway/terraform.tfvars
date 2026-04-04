# AWS Storage Gateway — example terraform.tfvars
# Replace placeholder ARNs, activation keys, and disk IDs with real values.
# This file demonstrates two gateways: an S3 File Gateway and a Tape Gateway.

region = "us-east-1"

tags = {
  Environment = "prod"
  Team        = "platform"
  Project     = "hybrid-storage"
}

# ── Gateways ───────────────────────────────────────────────────────────────────
gateways = [
  # ── Pattern 1: S3 File Gateway ──────────────────────────────────────────────
  # Exposes Amazon S3 buckets as NFS and SMB shares to on-premises clients.
  # Replace activation_key with the key obtained from http://<gateway-vm-ip>/
  {
    key            = "prod-file-gw"
    name           = "prod-s3-file-gateway"
    timezone       = "GMT"
    gateway_type   = "FILE_S3"
    activation_key = "AAAAA-BBBBB-CCCCC-DDDDD-EEEEE"

    # Optional: maintenance window on Sundays at 02:30 UTC.
    maintenance_start_time = {
      day_of_week    = 0 # Sunday
      hour_of_day    = 2
      minute_of_hour = 30
    }

    tags = { GatewayType = "FILE_S3" }
  },

  # ── Pattern 2: VTL Tape Gateway ─────────────────────────────────────────────
  # Presents a virtual tape library to backup software (Veeam, Commvault, etc.).
  # Uses IBM-ULT3580-TD5 drives compatible with most enterprise backup tools.
  {
    key                 = "prod-tape-gw"
    name                = "prod-vtl-gateway"
    timezone            = "GMT"
    gateway_type        = "VTL"
    activation_key      = "FFFFF-GGGGG-HHHHH-IIIII-JJJJJ"
    tape_drive_type     = "IBM-ULT3580-TD5"
    medium_changer_type = "AWS-Gateway-VTL"

    # Throttle upload to avoid saturating the WAN link during business hours.
    average_upload_rate_limit_in_bits_per_sec = 104857600 # 100 Mbps

    # Optional: maintenance window on Sundays at 03:00 UTC.
    maintenance_start_time = {
      day_of_week    = 0
      hour_of_day    = 3
      minute_of_hour = 0
    }

    tags = { GatewayType = "VTL" }
  }
]

# ── Cache Disks ─────────────────────────────────────────────────────────────────
# Cache disks store hot data locally. FILE_S3 gateways require at least one.
# disk_id values must match disks attached to the gateway VM.
cache_disks = [
  {
    key         = "file-gw-cache-sdb"
    gateway_key = "prod-file-gw"
    disk_id     = "/dev/sdb" # Replace with the actual disk ID from the gateway
  }
]

# ── Upload Buffers ─────────────────────────────────────────────────────────────
# Upload buffer disks stage data before it is sent to AWS.
# VTL and Volume Gateways require at least one upload buffer.
upload_buffers = [
  {
    key         = "tape-gw-buffer-sdb"
    gateway_key = "prod-tape-gw"
    disk_id     = "/dev/sdb" # Replace with the actual disk ID from the gateway
  }
]

# ── NFS File Shares ────────────────────────────────────────────────────────────
# NFS v3/v4.1 shares backed by S3 buckets. Linux clients mount via:
#   mount -t nfs -o nolock <gateway-ip>:/<s3-bucket-name> /mnt/media
nfs_file_shares = [
  # ── Pattern: KMS-encrypted media share with RootSquash ──────────────────────
  {
    key          = "media-nfs"
    gateway_key  = "prod-file-gw"
    location_arn = "arn:aws:s3:::my-media-bucket"
    role_arn     = "arn:aws:iam::123456789012:role/StorageGatewayS3Role"
    client_list  = ["10.0.0.0/8", "192.168.0.0/16"]

    default_storage_class = "S3_INTELLIGENT_TIERING"
    kms_encrypted         = true
    kms_key_arn           = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000001"
    squash                = "RootSquash"
    read_only             = false

    # Default Unix permissions applied to new files and directories.
    nfs_file_share_defaults = {
      directory_mode = "0755"
      file_mode      = "0644"
      group_id       = 1000
      owner_id       = 1000
    }

    tags = { ShareType = "NFS", ContentType = "media" }
  },

  # ── Pattern: Read-only analytics share (no write access needed) ──────────────
  {
    key          = "analytics-nfs-ro"
    gateway_key  = "prod-file-gw"
    location_arn = "arn:aws:s3:::my-analytics-bucket"
    role_arn     = "arn:aws:iam::123456789012:role/StorageGatewayS3Role"
    client_list  = ["10.1.0.0/24"]

    default_storage_class = "S3_STANDARD_IA"
    read_only             = true
    squash                = "AllSquash"

    tags = { ShareType = "NFS", Access = "readonly" }
  }
]

# ── SMB File Shares ────────────────────────────────────────────────────────────
# SMB 2/3 shares backed by S3 buckets. Windows clients connect via:
#   \\<gateway-ip>\<share-name>
smb_file_shares = [
  # ── Pattern: GuestAccess document share ─────────────────────────────────────
  # All clients authenticate with the smb_guest_password set on the gateway.
  {
    key             = "docs-smb-guest"
    gateway_key     = "prod-file-gw"
    location_arn    = "arn:aws:s3:::my-documents-bucket"
    role_arn        = "arn:aws:iam::123456789012:role/StorageGatewayS3Role"
    authentication  = "GuestAccess"
    file_share_name = "Documents"

    default_storage_class = "S3_STANDARD"
    kms_encrypted         = true
    kms_key_arn           = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000001"
    oplocks_enabled       = true

    tags = { ShareType = "SMB", Auth = "GuestAccess" }
  },

  # ── Pattern: Active Directory share with user restrictions ──────────────────
  # Requires smb_active_directory_settings on the gateway and AD membership.
  {
    key             = "finance-smb-ad"
    gateway_key     = "prod-file-gw"
    location_arn    = "arn:aws:s3:::my-finance-bucket"
    role_arn        = "arn:aws:iam::123456789012:role/StorageGatewayS3Role"
    authentication  = "ActiveDirectory"
    file_share_name = "Finance"

    default_storage_class    = "S3_STANDARD"
    kms_encrypted            = true
    kms_key_arn              = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000001"
    smb_acl_enabled          = true
    access_based_enumeration = true
    valid_user_list          = ["CORP\\finance-team", "CORP\\accounting"]
    admin_user_list          = ["CORP\\storage-admins"]

    tags = { ShareType = "SMB", Auth = "ActiveDirectory", Sensitivity = "high" }
  }
]

# ── Cached iSCSI Volumes ────────────────────────────────────────────────────────
# No cached volumes in this plan. Uncomment the block below to add one.
# Requires a CACHED gateway with upload_buffer and cache_disk configured.
cached_volumes = []

# Example cached volume (uncomment to use):
# cached_volumes = [
#   {
#     key                  = "cached-vol-100g"
#     gateway_key          = "prod-cached-gw"  # must be a CACHED gateway key
#     network_interface_id = "10.0.1.10"
#     target_name          = "iqn-cached-vol-1"
#     volume_size_in_bytes = 107374182400       # 100 GiB
#     kms_encrypted        = true
#     kms_key              = "arn:aws:kms:us-east-1:123456789012:key/..."
#   }
# ]

# ── Stored iSCSI Volumes ────────────────────────────────────────────────────────
# No stored volumes in this plan. Uncomment the block below to add one.
stored_volumes = []

# ── Tape Pools ─────────────────────────────────────────────────────────────────
# Define archive tiers and optional retention lock for the VTL Tape Gateway.
tape_pools = [
  # ── Pattern: Glacier pool with GOVERNANCE retention lock (30 days) ───────────
  # Tapes are archived to Glacier; cannot be deleted for at least 30 days.
  {
    key                         = "glacier-pool-30d"
    name                        = "prod-glacier-tape-pool"
    storage_class               = "GLACIER"
    retention_lock_type         = "GOVERNANCE"
    retention_lock_time_in_days = 30

    tags = { PoolType = "GLACIER", RetentionDays = "30" }
  },

  # ── Pattern: Deep Archive pool for long-term compliance archiving ────────────
  # Lowest cost ($0.00099/GB-month); tapes stored for 7-year compliance retention.
  {
    key                         = "deep-archive-pool-2555d"
    name                        = "prod-deep-archive-tape-pool"
    storage_class               = "DEEP_ARCHIVE"
    retention_lock_type         = "COMPLIANCE"
    retention_lock_time_in_days = 2555 # ~7 years

    tags = { PoolType = "DEEP_ARCHIVE", RetentionDays = "2555", Compliance = "true" }
  }
]
