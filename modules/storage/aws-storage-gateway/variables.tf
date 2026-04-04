# ── Top-level variables ────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region where Storage Gateway resources are deployed."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Common tags applied to all taggable Storage Gateway resources."
  type        = map(string)
  default     = {}
}

# ── Gateways ───────────────────────────────────────────────────────────────────

variable "gateways" {
  description = <<-EOT
    List of Storage Gateway instances to create. Each entry maps to one
    aws_storagegateway_gateway resource. Unique keys are used as for_each
    identifiers and are referenced by nfs_file_shares, smb_file_shares,
    upload_buffers, cache_disks, cached_volumes, stored_volumes, and
    tape_pools via their gateway_key field.

    Gateway types:
      FILE_S3      – NFS/SMB file shares backed by Amazon S3
      FILE_FSX_SMB – SMB shares backed by Amazon FSx for Windows File Server
      CACHED       – iSCSI block volumes; primary data in S3, working set cached locally
      STORED       – iSCSI block volumes; all data on-premises, EBS snapshots to S3
      VTL          – Virtual tape library backed by Amazon S3 and Glacier

    Activation (provide exactly one):
      activation_key     – pre-obtained key from the gateway's local web UI (port 80)
      gateway_ip_address – IP address; the provider auto-fetches the activation key
  EOT
  type = list(object({
    # Unique identifier used as the for_each key; referenced by child resources.
    key = string

    # Display name shown in the AWS Console.
    name = string

    # IANA timezone for the maintenance window (e.g., "GMT", "US/Eastern").
    timezone = string

    # Gateway type: FILE_S3 | FILE_FSX_SMB | CACHED | STORED | VTL
    gateway_type = string

    # Pre-obtained activation key. Mutually exclusive with gateway_ip_address.
    activation_key = optional(string)

    # Gateway VM/appliance IP address; provider auto-retrieves the activation key.
    # Mutually exclusive with activation_key.
    gateway_ip_address = optional(string)

    # ARN of the CloudWatch log group for gateway-level SMB/NFS audit logs.
    cloudwatch_log_group_arn = optional(string)

    # Average download rate limit in bits per second (null = unlimited).
    average_download_rate_limit_in_bits_per_sec = optional(number)

    # Average upload rate limit in bits per second (null = unlimited).
    average_upload_rate_limit_in_bits_per_sec = optional(number)

    # Scheduled maintenance window; patch and update window settings.
    maintenance_start_time = optional(object({
      # Day of week: 0 (Sunday) through 6 (Saturday). Omit for any day.
      day_of_week = optional(number)
      # Day of month (1–28). Use instead of day_of_week for monthly windows.
      day_of_month = optional(number)
      # Hour of day in UTC (0–23). Required when block is set.
      hour_of_day = number
      # Minute of hour (0–59).
      minute_of_hour = optional(number, 0)
    }))

    # VTL only: virtual tape drive type.
    # Examples: IBM-ULT3580-TD5, IBM-ULT3580-TD4, HP-LTO-5-ULTRIUM3280
    tape_drive_type = optional(string)

    # VTL only: medium changer type for backup software compatibility.
    # Examples: STK-L700, AWS-Gateway-VTL, IBM-03584L32-0402
    medium_changer_type = optional(string)

    # Active Directory settings for SMB FILE_S3 and FILE_FSX_SMB gateways.
    smb_active_directory_settings = optional(object({
      domain_name         = string
      username            = string
      password            = string
      domain_controllers  = optional(list(string))
      organizational_unit = optional(string)
      timeout_in_seconds  = optional(number, 20)
    }))

    # Guest password for GuestAccess SMB shares (no Active Directory required).
    smb_guest_password = optional(string)

    # Per-gateway tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── NFS File Shares ────────────────────────────────────────────────────────────

variable "nfs_file_shares" {
  description = <<-EOT
    List of NFS file shares to create on FILE_S3 gateways. Each entry maps to
    one aws_storagegateway_nfs_file_share resource.

    Requirements:
      - gateway_key must reference a FILE_S3 gateway key in var.gateways.
      - location_arn must be an S3 bucket ARN.
      - role_arn must be an IAM role ARN with s3:GetObject/PutObject/DeleteObject.
      - A cache disk must be configured on the gateway before creating shares.
  EOT
  type = list(object({
    # Unique key used as for_each identifier.
    key = string

    # References the parent gateway key from var.gateways.
    gateway_key = string

    # ARN of the S3 bucket that backs this NFS share.
    location_arn = string

    # IAM role ARN the gateway assumes to read/write the S3 bucket.
    role_arn = string

    # Allowed client CIDR blocks (e.g., ["10.0.0.0/8"]).
    client_list = list(string)

    # Default S3 storage class for new objects.
    # Allowed: S3_STANDARD | S3_STANDARD_IA | S3_ONEZONE_IA | S3_INTELLIGENT_TIERING
    default_storage_class = optional(string, "S3_STANDARD")

    # Enable KMS server-side encryption for objects written to S3.
    kms_encrypted = optional(bool, false)

    # KMS key ARN; required when kms_encrypted = true.
    kms_key_arn = optional(string)

    # S3 object ACL applied to new objects: private | public-read | etc.
    object_acl = optional(string, "private")

    # Whether the share is read-only for NFS clients.
    read_only = optional(bool, false)

    # Whether the requester pays for data-transfer out of S3.
    requester_pays = optional(bool, false)

    # Unix squash mode: RootSquash | NoSquash | AllSquash
    squash = optional(string, "RootSquash")

    # Override default Unix file/directory permission modes.
    nfs_file_share_defaults = optional(object({
      directory_mode = optional(string, "0777")
      file_mode      = optional(string, "0666")
      group_id       = optional(number, 65534)
      owner_id       = optional(number, 65534)
    }))

    # Override the share name visible to NFS clients.
    file_share_name = optional(string)

    # Infer MIME type from file extension for uploaded objects.
    guess_mime_type_enabled = optional(bool, true)

    # S3 event notification policy JSON (optional).
    notification_policy = optional(string)

    # VPC endpoint DNS name for PrivateLink access to S3 (optional).
    vpc_endpoint_dns_name = optional(string)

    # S3 bucket region for cross-region share targets (optional).
    bucket_region = optional(string)

    # CloudWatch log group ARN for file-level NFS audit logs (optional).
    audit_destination_arn = optional(string)

    # Per-share tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── SMB File Shares ────────────────────────────────────────────────────────────

variable "smb_file_shares" {
  description = <<-EOT
    List of SMB file shares to create on FILE_S3 or FILE_FSX_SMB gateways.
    Each entry maps to one aws_storagegateway_smb_file_share resource.

    Requirements:
      - gateway_key must reference a FILE_S3 or FILE_FSX_SMB gateway.
      - For ActiveDirectory auth the gateway must be joined to an AD domain.
      - For GuestAccess auth smb_guest_password must be set on the gateway.
  EOT
  type = list(object({
    # Unique key used as for_each identifier.
    key = string

    # References the parent gateway key from var.gateways.
    gateway_key = string

    # ARN of the S3 bucket that backs this SMB share.
    location_arn = string

    # IAM role ARN the gateway assumes to read/write the S3 bucket.
    role_arn = string

    # Authentication method: ActiveDirectory | GuestAccess
    authentication = optional(string, "GuestAccess")

    # Default S3 storage class for new objects.
    default_storage_class = optional(string, "S3_STANDARD")

    # Enable KMS server-side encryption for objects written to S3.
    kms_encrypted = optional(bool, false)

    # KMS key ARN; required when kms_encrypted = true.
    kms_key_arn = optional(string)

    # S3 object ACL: private | public-read | bucket-owner-full-control | etc.
    object_acl = optional(string, "private")

    # Whether the share is read-only for all connected clients.
    read_only = optional(bool, false)

    # Whether the requester pays for data-transfer out of S3.
    requester_pays = optional(bool, false)

    # Hide shares from users without read access (AD auth only).
    access_based_enumeration = optional(bool, false)

    # AD users/groups allowed to access the share (AD auth only).
    valid_user_list = optional(list(string), [])

    # AD users/groups explicitly denied access (AD auth only).
    invalid_user_list = optional(list(string), [])

    # AD users/groups with full admin rights on the share (AD auth only).
    admin_user_list = optional(list(string), [])

    # Share display name visible to SMB clients.
    file_share_name = optional(string)

    # Infer MIME type from file extension for uploaded objects.
    guess_mime_type_enabled = optional(bool, true)

    # Enable Windows ACL enforcement on the SMB share (AD auth recommended).
    smb_acl_enabled = optional(bool, false)

    # Case sensitivity: ClientSpecified | ForcedCaseSensitivity
    case_sensitivity = optional(string, "ClientSpecified")

    # S3 event notification policy JSON (optional).
    notification_policy = optional(string)

    # VPC endpoint DNS name for PrivateLink access to S3 (optional).
    vpc_endpoint_dns_name = optional(string)

    # S3 bucket region for cross-region share targets (optional).
    bucket_region = optional(string)

    # CloudWatch log group ARN for SMB access audit logs (optional).
    audit_destination_arn = optional(string)

    # Enable SMB OpLocks (opportunistic locks) for improved client performance.
    oplocks_enabled = optional(bool, true)

    # Per-share tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── Upload Buffers ─────────────────────────────────────────────────────────────

variable "upload_buffers" {
  description = <<-EOT
    List of local disks to configure as upload buffers on Volume or Tape Gateways.
    Upload buffers stage outbound data before it is transmitted to AWS.

    Requirements:
      - Each disk must already be attached to the gateway VM/appliance.
      - Provide either disk_id or disk_path (not both) per entry.
      - Volume and Tape Gateways require at least one upload buffer.
      - Upload buffer and cache disks must not share the same physical disk.
  EOT
  type = list(object({
    # Unique key for for_each.
    key = string

    # References the parent gateway key from var.gateways.
    gateway_key = string

    # Local disk identifier (e.g., obtained via aws_storagegateway_local_disk data source).
    disk_id = optional(string)

    # Local disk path on the gateway host (alternative to disk_id).
    disk_path = optional(string)
  }))
  default = []
}

# ── Cache Disks ────────────────────────────────────────────────────────────────

variable "cache_disks" {
  description = <<-EOT
    List of local disks to configure as cache storage on File or Volume Gateways.
    Cache disks hold frequently accessed data locally for low-latency reads.

    Requirements:
      - Each disk must be attached to the gateway VM/appliance.
      - FILE_S3 and CACHED Volume Gateways require at least one cache disk.
      - Cache disk and upload buffer cannot share the same physical disk.
  EOT
  type = list(object({
    # Unique key for for_each.
    key = string

    # References the parent gateway key from var.gateways.
    gateway_key = string

    # Local disk identifier that will serve as the read/write cache.
    disk_id = string
  }))
  default = []
}

# ── Cached iSCSI Volumes ───────────────────────────────────────────────────────

variable "cached_volumes" {
  description = <<-EOT
    List of cached iSCSI volumes to create on CACHED Volume Gateways.
    Primary data is stored in S3; only the working set is cached locally.

    Requirements:
      - gateway_key must reference a CACHED gateway key.
      - Upload buffer and cache disks must be configured on the gateway first.
      - volume_size_in_bytes must be a multiple of 512.
      - target_name must be unique within the gateway.
  EOT
  type = list(object({
    # Unique key for for_each.
    key = string

    # References the parent gateway key from var.gateways.
    gateway_key = string

    # Network interface IP address the iSCSI target listens on.
    network_interface_id = string

    # iSCSI target name; becomes the IQN suffix visible to initiators.
    target_name = string

    # Volume size in bytes (must be a multiple of 512).
    # Examples: 107374182400 = 100 GiB, 1099511627776 = 1 TiB
    volume_size_in_bytes = number

    # Optional: seed the volume from an existing EBS snapshot ID.
    snapshot_id = optional(string)

    # Optional: clone volume data from an existing cached/stored volume ARN.
    source_volume_arn = optional(string)

    # Encrypt volume data in S3 with a KMS key.
    kms_encrypted = optional(bool, false)

    # KMS key ARN; required when kms_encrypted = true.
    kms_key = optional(string)

    # Per-volume tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── Stored iSCSI Volumes ───────────────────────────────────────────────────────

variable "stored_volumes" {
  description = <<-EOT
    List of stored iSCSI volumes to create on STORED Volume Gateways.
    All data is stored on-premises; EBS snapshots are asynchronously sent to S3.

    Requirements:
      - gateway_key must reference a STORED gateway key.
      - disk_id must reference a local disk attached to the gateway.
      - Upload buffer disk must be configured on the gateway first.
      - target_name must be unique within the gateway.
  EOT
  type = list(object({
    # Unique key for for_each.
    key = string

    # References the parent gateway key from var.gateways.
    gateway_key = string

    # Network interface IP address the iSCSI target listens on.
    network_interface_id = string

    # iSCSI target name visible to initiators.
    target_name = string

    # Local disk ID that backs this stored volume.
    disk_id = string

    # Whether to preserve data already on the disk (set true for migration).
    preserve_existing_data = optional(bool, false)

    # Optional: seed from an existing EBS snapshot ID.
    snapshot_id = optional(string)

    # Encrypt EBS snapshots uploaded to S3 with a KMS key.
    kms_encrypted = optional(bool, false)

    # KMS key ARN; required when kms_encrypted = true.
    kms_key = optional(string)

    # Per-volume tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── Tape Pools ─────────────────────────────────────────────────────────────────

variable "tape_pools" {
  description = <<-EOT
    List of virtual tape pools to create for Tape Gateway archiving.
    Tape pools define the archive storage class and optional retention lock policy.

    Requirements:
      - storage_class must be GLACIER or DEEP_ARCHIVE.
      - retention_lock_time_in_days is required when retention_lock_type is not NONE.
      - COMPLIANCE lock is permanent after creation; use with care.
  EOT
  type = list(object({
    # Unique key for for_each.
    key = string

    # Display name for the tape pool.
    name = string

    # Archive storage class: GLACIER | DEEP_ARCHIVE
    storage_class = string

    # Retention lock type: COMPLIANCE | GOVERNANCE | NONE
    retention_lock_type = optional(string, "NONE")

    # Minimum days a tape must be retained (required for GOVERNANCE/COMPLIANCE).
    retention_lock_time_in_days = optional(number)

    # Per-pool tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}
