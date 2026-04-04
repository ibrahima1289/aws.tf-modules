# ── Top-level variables ────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region for the Storage Gateway plan."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all Storage Gateway resources in this plan."
  type        = map(string)
  default     = {}
}

# ── Gateways ───────────────────────────────────────────────────────────────────

variable "gateways" {
  description = "List of Storage Gateway instances to create. See the root module README for field definitions."
  type = list(object({
    key                = string
    name               = string
    timezone           = string
    gateway_type       = string
    activation_key     = optional(string)
    gateway_ip_address = optional(string)

    cloudwatch_log_group_arn                    = optional(string)
    average_download_rate_limit_in_bits_per_sec = optional(number)
    average_upload_rate_limit_in_bits_per_sec   = optional(number)

    maintenance_start_time = optional(object({
      day_of_week    = optional(number)
      day_of_month   = optional(number)
      hour_of_day    = number
      minute_of_hour = optional(number, 0)
    }))

    tape_drive_type     = optional(string)
    medium_changer_type = optional(string)

    smb_active_directory_settings = optional(object({
      domain_name         = string
      username            = string
      password            = string
      domain_controllers  = optional(list(string))
      organizational_unit = optional(string)
      timeout_in_seconds  = optional(number, 20)
    }))

    smb_guest_password = optional(string)
    tags               = optional(map(string), {})
  }))
  default = []
}

# ── NFS File Shares ────────────────────────────────────────────────────────────

variable "nfs_file_shares" {
  description = "List of NFS file shares to create on FILE_S3 gateways."
  type = list(object({
    key          = string
    gateway_key  = string
    location_arn = string
    role_arn     = string
    client_list  = list(string)

    default_storage_class = optional(string, "S3_STANDARD")
    kms_encrypted         = optional(bool, false)
    kms_key_arn           = optional(string)
    object_acl            = optional(string, "private")
    read_only             = optional(bool, false)
    requester_pays        = optional(bool, false)
    squash                = optional(string, "RootSquash")

    nfs_file_share_defaults = optional(object({
      directory_mode = optional(string, "0777")
      file_mode      = optional(string, "0666")
      group_id       = optional(number, 65534)
      owner_id       = optional(number, 65534)
    }))

    file_share_name         = optional(string)
    guess_mime_type_enabled = optional(bool, true)
    notification_policy     = optional(string)
    vpc_endpoint_dns_name   = optional(string)
    bucket_region           = optional(string)
    audit_destination_arn   = optional(string)
    tags                    = optional(map(string), {})
  }))
  default = []
}

# ── SMB File Shares ────────────────────────────────────────────────────────────

variable "smb_file_shares" {
  description = "List of SMB file shares to create on FILE_S3 or FILE_FSX_SMB gateways."
  type = list(object({
    key          = string
    gateway_key  = string
    location_arn = string
    role_arn     = string

    authentication        = optional(string, "GuestAccess")
    default_storage_class = optional(string, "S3_STANDARD")
    kms_encrypted         = optional(bool, false)
    kms_key_arn           = optional(string)
    object_acl            = optional(string, "private")
    read_only             = optional(bool, false)
    requester_pays        = optional(bool, false)

    access_based_enumeration = optional(bool, false)
    valid_user_list          = optional(list(string), [])
    invalid_user_list        = optional(list(string), [])
    admin_user_list          = optional(list(string), [])

    file_share_name         = optional(string)
    guess_mime_type_enabled = optional(bool, true)
    smb_acl_enabled         = optional(bool, false)
    case_sensitivity        = optional(string, "ClientSpecified")
    notification_policy     = optional(string)
    vpc_endpoint_dns_name   = optional(string)
    bucket_region           = optional(string)
    audit_destination_arn   = optional(string)
    oplocks_enabled         = optional(bool, true)
    tags                    = optional(map(string), {})
  }))
  default = []
}

# ── Upload Buffers ─────────────────────────────────────────────────────────────

variable "upload_buffers" {
  description = "List of upload buffer disks to configure on Volume or Tape Gateways."
  type = list(object({
    key         = string
    gateway_key = string
    disk_id     = optional(string)
    disk_path   = optional(string)
  }))
  default = []
}

# ── Cache Disks ────────────────────────────────────────────────────────────────

variable "cache_disks" {
  description = "List of cache disks to configure on File or Volume Gateways."
  type = list(object({
    key         = string
    gateway_key = string
    disk_id     = string
  }))
  default = []
}

# ── Cached iSCSI Volumes ───────────────────────────────────────────────────────

variable "cached_volumes" {
  description = "List of cached iSCSI volumes to create on CACHED Volume Gateways."
  type = list(object({
    key                  = string
    gateway_key          = string
    network_interface_id = string
    target_name          = string
    volume_size_in_bytes = number
    snapshot_id          = optional(string)
    source_volume_arn    = optional(string)
    kms_encrypted        = optional(bool, false)
    kms_key              = optional(string)
    tags                 = optional(map(string), {})
  }))
  default = []
}

# ── Stored iSCSI Volumes ───────────────────────────────────────────────────────

variable "stored_volumes" {
  description = "List of stored iSCSI volumes to create on STORED Volume Gateways."
  type = list(object({
    key                    = string
    gateway_key            = string
    network_interface_id   = string
    target_name            = string
    disk_id                = string
    preserve_existing_data = optional(bool, false)
    snapshot_id            = optional(string)
    kms_encrypted          = optional(bool, false)
    kms_key                = optional(string)
    tags                   = optional(map(string), {})
  }))
  default = []
}

# ── Tape Pools ─────────────────────────────────────────────────────────────────

variable "tape_pools" {
  description = "List of virtual tape pools to create for VTL Tape Gateways."
  type = list(object({
    key                         = string
    name                        = string
    storage_class               = string
    retention_lock_type         = optional(string, "NONE")
    retention_lock_time_in_days = optional(number)
    tags                        = optional(map(string), {})
  }))
  default = []
}
