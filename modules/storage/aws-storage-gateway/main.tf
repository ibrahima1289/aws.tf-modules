# Terraform AWS Storage Gateway Module
# Creates Storage Gateways (S3 File, FSx File, Volume, Tape) with NFS/SMB file
# shares, iSCSI cached/stored volumes, tape pools, upload buffers, and cache
# disks. All resource types support multiple instances via for_each; keys are
# supplied by the caller in each list entry's .key field.

# ── Step 1: Storage Gateways ──────────────────────────────────────────────────
# Registers and activates each gateway with AWS. The gateway type determines
# which child resources (file shares, volumes, tape pools) can be attached.
# Provide exactly one of activation_key or gateway_ip_address per gateway.
resource "aws_storagegateway_gateway" "gateway" {
  for_each = local.gateways_map

  # Display name visible in the AWS Console and CloudWatch dashboards.
  gateway_name = each.value.name

  # IANA timezone used by the gateway's scheduled maintenance window.
  gateway_timezone = each.value.timezone

  # Gateway type: FILE_S3 | FILE_FSX_SMB | CACHED | STORED | VTL
  gateway_type = each.value.gateway_type

  # Activation: provide activation_key (pre-obtained) or gateway_ip_address
  # (provider auto-fetches the key from the gateway's port-80 endpoint).
  activation_key     = each.value.activation_key
  gateway_ip_address = each.value.gateway_ip_address

  # Optional: CloudWatch log group ARN for SMB/NFS gateway audit logging.
  cloudwatch_log_group_arn = each.value.cloudwatch_log_group_arn

  # Optional: bandwidth throttle limits in bits per second.
  average_download_rate_limit_in_bits_per_sec = each.value.average_download_rate_limit_in_bits_per_sec
  average_upload_rate_limit_in_bits_per_sec   = each.value.average_upload_rate_limit_in_bits_per_sec

  # Optional: scheduled maintenance window (day, hour, minute in UTC).
  dynamic "maintenance_start_time" {
    for_each = each.value.maintenance_start_time != null ? [each.value.maintenance_start_time] : []
    content {
      day_of_week    = maintenance_start_time.value.day_of_week
      day_of_month   = maintenance_start_time.value.day_of_month
      hour_of_day    = maintenance_start_time.value.hour_of_day
      minute_of_hour = maintenance_start_time.value.minute_of_hour
    }
  }

  # VTL only: virtual tape drive type (e.g., IBM-ULT3580-TD5).
  tape_drive_type = each.value.gateway_type == "VTL" ? each.value.tape_drive_type : null

  # VTL only: medium changer type for backup software compatibility.
  medium_changer_type = each.value.gateway_type == "VTL" ? each.value.medium_changer_type : null

  # SMB Active Directory integration block (File Gateways with AD auth).
  dynamic "smb_active_directory_settings" {
    for_each = each.value.smb_active_directory_settings != null ? [each.value.smb_active_directory_settings] : []
    content {
      domain_name         = smb_active_directory_settings.value.domain_name
      username            = smb_active_directory_settings.value.username
      password            = smb_active_directory_settings.value.password
      domain_controllers  = smb_active_directory_settings.value.domain_controllers
      organizational_unit = smb_active_directory_settings.value.organizational_unit
      timeout_in_seconds  = smb_active_directory_settings.value.timeout_in_seconds
    }
  }

  # Guest password for GuestAccess SMB shares (no AD required).
  smb_guest_password = each.value.smb_guest_password

  # Merge common tags, per-gateway tags, and the Name tag.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ── Step 2: Upload Buffers ────────────────────────────────────────────────────
# Upload buffers stage outbound data before it is uploaded to AWS.
# Volume and Tape Gateways require at least one upload buffer disk.
# Provide disk_id or disk_path (not both) per entry.
resource "aws_storagegateway_upload_buffer" "upload_buffer" {
  for_each = local.upload_buffers_map

  # Reference the parent gateway ARN created in Step 1.
  gateway_arn = aws_storagegateway_gateway.gateway[each.value.gateway_key].arn

  # Local disk ID or disk path on the gateway host (exactly one must be set).
  disk_id   = each.value.disk_id
  disk_path = each.value.disk_path
}

# ── Step 3: Cache Disks ───────────────────────────────────────────────────────
# Cache disks hold frequently accessed data locally for low-latency reads.
# Required for FILE_S3 and CACHED Volume Gateways.
resource "aws_storagegateway_cache" "cache" {
  for_each = local.cache_disks_map

  # Reference the parent gateway ARN created in Step 1.
  gateway_arn = aws_storagegateway_gateway.gateway[each.value.gateway_key].arn

  # Local disk identifier that will serve as the read/write cache.
  disk_id = each.value.disk_id
}

# ── Step 4: NFS File Shares ───────────────────────────────────────────────────
# NFS file shares expose an S3 bucket as an NFS v3/v4.1 mount point.
# Requires a FILE_S3 gateway with at least one cache disk (Step 3).
resource "aws_storagegateway_nfs_file_share" "nfs_share" {
  for_each = local.nfs_shares_map

  # Reference the parent gateway ARN created in Step 1.
  gateway_arn = aws_storagegateway_gateway.gateway[each.value.gateway_key].arn

  # ARN of the S3 bucket that backs this NFS share.
  location_arn = each.value.location_arn

  # IAM role the gateway assumes when reading and writing the S3 bucket.
  role_arn = each.value.role_arn

  # Allowed NFS client CIDR blocks (e.g., ["10.0.0.0/8"]).
  client_list = each.value.client_list

  # Default S3 storage class applied to newly written objects.
  default_storage_class = each.value.default_storage_class

  # Server-side encryption: when true, objects are encrypted with the KMS key.
  kms_encrypted = each.value.kms_encrypted
  kms_key_arn   = each.value.kms_encrypted ? each.value.kms_key_arn : null

  # S3 object ACL applied to every new object written via this share.
  object_acl = each.value.object_acl

  # Prevent write operations from NFS clients when enabled.
  read_only = each.value.read_only

  # Charge data-transfer costs to the requester rather than the bucket owner.
  requester_pays = each.value.requester_pays

  # Unix squash mode: RootSquash | NoSquash | AllSquash
  squash = each.value.squash

  # Override default Unix file and directory permissions (optional).
  dynamic "nfs_file_share_defaults" {
    for_each = each.value.nfs_file_share_defaults != null ? [each.value.nfs_file_share_defaults] : []
    content {
      directory_mode = nfs_file_share_defaults.value.directory_mode
      file_mode      = nfs_file_share_defaults.value.file_mode
      group_id       = nfs_file_share_defaults.value.group_id
      owner_id       = nfs_file_share_defaults.value.owner_id
    }
  }

  # Override the share name visible to NFS clients.
  file_share_name = each.value.file_share_name

  # Guess MIME type from file extension when objects are uploaded.
  guess_mime_type_enabled = each.value.guess_mime_type_enabled

  # S3 event notification policy JSON for this share (optional).
  notification_policy = each.value.notification_policy

  # VPC endpoint DNS name for PrivateLink connectivity to S3 (optional).
  vpc_endpoint_dns_name = each.value.vpc_endpoint_dns_name

  # S3 bucket region for cross-region share targets (optional).
  bucket_region = each.value.bucket_region

  # CloudWatch log group ARN for file-level NFS audit logging (optional).
  audit_destination_arn = each.value.audit_destination_arn

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.key
  })

  # Ensure the gateway and its cache are ready before the file share is created.
  depends_on = [aws_storagegateway_cache.cache]
}

# ── Step 5: SMB File Shares ───────────────────────────────────────────────────
# SMB file shares expose an S3 bucket as a Windows-compatible SMB 2/3 share.
# Supported on FILE_S3 and FILE_FSX_SMB gateway types.
resource "aws_storagegateway_smb_file_share" "smb_share" {
  for_each = local.smb_shares_map

  # Reference the parent gateway ARN created in Step 1.
  gateway_arn = aws_storagegateway_gateway.gateway[each.value.gateway_key].arn

  # ARN of the S3 bucket that backs this SMB share.
  location_arn = each.value.location_arn

  # IAM role the gateway assumes when reading and writing the S3 bucket.
  role_arn = each.value.role_arn

  # Authentication method: ActiveDirectory | GuestAccess
  authentication = each.value.authentication

  # Default S3 storage class applied to newly written objects.
  default_storage_class = each.value.default_storage_class

  # Server-side encryption: when true, objects are encrypted with the KMS key.
  kms_encrypted = each.value.kms_encrypted
  kms_key_arn   = each.value.kms_encrypted ? each.value.kms_key_arn : null

  # S3 object ACL applied to every new object written via this share.
  object_acl = each.value.object_acl

  # Prevent write operations from SMB clients when enabled.
  read_only = each.value.read_only

  # Charge data-transfer costs to the requester.
  requester_pays = each.value.requester_pays

  # Hide share contents from users who have no read access (AD auth only).
  access_based_enumeration = each.value.access_based_enumeration

  # AD users/groups with read/write access (AD auth only; empty = all AD users).
  valid_user_list = each.value.valid_user_list

  # AD users/groups explicitly denied access (AD auth only).
  invalid_user_list = each.value.invalid_user_list

  # AD users/groups with full admin rights on the share (AD auth only).
  admin_user_list = each.value.admin_user_list

  # Share display name visible to Windows clients.
  file_share_name = each.value.file_share_name

  # Guess MIME type from file extension when objects are uploaded.
  guess_mime_type_enabled = each.value.guess_mime_type_enabled

  # Enable Windows ACL enforcement on the SMB share.
  smb_acl_enabled = each.value.smb_acl_enabled

  # Object name case sensitivity: ClientSpecified | ForcedCaseSensitivity
  case_sensitivity = each.value.case_sensitivity

  # S3 event notification policy JSON for this share (optional).
  notification_policy = each.value.notification_policy

  # VPC endpoint DNS name for PrivateLink connectivity to S3 (optional).
  vpc_endpoint_dns_name = each.value.vpc_endpoint_dns_name

  # S3 bucket region for cross-region share targets (optional).
  bucket_region = each.value.bucket_region

  # CloudWatch log group ARN for SMB access audit logging (optional).
  audit_destination_arn = each.value.audit_destination_arn

  # Enable opportunistic locks (OpLocks) for improved client write performance.
  oplocks_enabled = each.value.oplocks_enabled

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.key
  })

  # Ensure the gateway and its cache are ready before the file share is created.
  depends_on = [aws_storagegateway_cache.cache]
}

# ── Step 6: Cached iSCSI Volumes ──────────────────────────────────────────────
# Cached mode: primary data lives in S3; the local cache stores the working set.
# Presents iSCSI LUNs to on-premises servers without full local storage.
resource "aws_storagegateway_cached_iscsi_volume" "cached_volume" {
  for_each = local.cached_volumes_map

  # Reference the parent gateway ARN created in Step 1.
  gateway_arn = aws_storagegateway_gateway.gateway[each.value.gateway_key].arn

  # Network interface IP address the iSCSI target listens on.
  network_interface_id = each.value.network_interface_id

  # iSCSI target name; becomes the IQN suffix visible to initiators.
  target_name = each.value.target_name

  # Total volume size in bytes (must be a multiple of 512).
  volume_size_in_bytes = each.value.volume_size_in_bytes

  # Optional: restore volume data from an existing EBS snapshot.
  snapshot_id = each.value.snapshot_id

  # Optional: clone data from an existing cached or stored volume ARN.
  source_volume_arn = each.value.source_volume_arn

  # Encrypt volume data stored in S3 with a KMS key.
  kms_encrypted = each.value.kms_encrypted
  kms_key       = each.value.kms_encrypted ? each.value.kms_key : null

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.target_name
  })

  # Upload buffer and cache must exist before volumes can be created.
  depends_on = [
    aws_storagegateway_upload_buffer.upload_buffer,
    aws_storagegateway_cache.cache,
  ]
}

# ── Step 7: Stored iSCSI Volumes ──────────────────────────────────────────────
# Stored mode: all data is kept on-premises for minimum read/write latency.
# EBS snapshots are sent to S3 asynchronously for cloud backup and DR.
resource "aws_storagegateway_stored_iscsi_volume" "stored_volume" {
  for_each = local.stored_volumes_map

  # Reference the parent gateway ARN created in Step 1.
  gateway_arn = aws_storagegateway_gateway.gateway[each.value.gateway_key].arn

  # Network interface IP address the iSCSI target listens on.
  network_interface_id = each.value.network_interface_id

  # iSCSI target name visible to initiators.
  target_name = each.value.target_name

  # Local disk ID that backs this stored volume (must be attached to gateway).
  disk_id = each.value.disk_id

  # When true, existing disk data is preserved (useful for migration scenarios).
  preserve_existing_data = each.value.preserve_existing_data

  # Optional: seed volume from an existing EBS snapshot ID.
  snapshot_id = each.value.snapshot_id

  # Encrypt EBS snapshots uploaded to S3 with a KMS key.
  kms_encrypted = each.value.kms_encrypted
  kms_key       = each.value.kms_encrypted ? each.value.kms_key : null

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.target_name
  })

  # Upload buffer must exist before volumes can be created.
  depends_on = [aws_storagegateway_upload_buffer.upload_buffer]
}

# ── Step 8: Tape Pools ────────────────────────────────────────────────────────
# Tape pools define the S3 Glacier archive tier and optional retention lock
# policy for virtual tapes managed by a VTL Tape Gateway.
resource "aws_storagegateway_tape_pool" "tape_pool" {
  for_each = local.tape_pools_map

  # Display name for the tape pool visible in the console.
  pool_name = each.value.name

  # Archive storage class for tapes in this pool: GLACIER | DEEP_ARCHIVE
  storage_class = each.value.storage_class

  # Retention lock: COMPLIANCE (permanent, immutable) | GOVERNANCE | NONE
  retention_lock_type = each.value.retention_lock_type

  # Minimum days before an archived tape can be deleted (required unless NONE).
  retention_lock_time_in_days = each.value.retention_lock_type != "NONE" ? each.value.retention_lock_time_in_days : null

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}
