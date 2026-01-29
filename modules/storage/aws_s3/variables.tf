variable "region" {
  description = "AWS region to use for S3 resources."
  type        = string
}

variable "tags" {
  description = "Global tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "buckets" {
  description = "List of bucket configurations. Supports name, acl, policy_json, logging, lifecycle_rules, replication, and tags. For lifecycle transitions, allowed storage classes: STANDARD, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER_IR, GLACIER, DEEP_ARCHIVE."
  type = list(object({
    name          = string
    storage_class = optional(string)
    acl           = optional(string)
    policy_json   = optional(string)
    tags          = optional(map(string))
    encryption = optional(object({
      enable             = optional(bool)
      algorithm          = optional(string)
      kms_key_id         = optional(string)
      bucket_key_enabled = optional(bool)
      customer_provided  = optional(bool)
    }))
    website = optional(object({
      index_document = optional(string)
      error_document = optional(string)
      redirect_all_requests_to = optional(object({
        host_name = string
        protocol  = optional(string)
      }))
    }))
    logging = optional(object({
      target_bucket = string
      target_prefix = optional(string)
    }))
    lifecycle_rules = optional(list(object({
      id                                 = string
      status                             = string
      prefix                             = optional(string)
      tags                               = optional(map(string))
      expiration_days                    = optional(number)
      noncurrent_version_expiration_days = optional(number)
      # Allowed storage_class values: STANDARD | STANDARD_IA | ONEZONE_IA | INTELLIGENT_TIERING | GLACIER_IR | GLACIER | DEEP_ARCHIVE
      transitions = optional(list(object({
        storage_class = string
        days          = number
      })))
      noncurrent_version_transitions = optional(list(object({
        storage_class   = string
        noncurrent_days = number
      })))
    })))
    replication = optional(object({
      rules = list(object({
        id                               = string
        status                           = string
        prefix                           = optional(string)
        destination_bucket_arn           = string
        storage_class                    = optional(string)
        replication_time_status          = optional(string)
        replication_time_minutes         = optional(number)
        delete_marker_replication_status = optional(string)
      }))
    }))
  }))
}

variable "bucket_defaults" {
  description = "Defaults for bucket settings like ownership, versioning, encryption, and public access block."
  type = object({
    ownership_controls_enable = optional(bool)
    object_ownership          = optional(string)
    block_public_acls         = optional(bool)
    block_public_policy       = optional(bool)
    ignore_public_acls        = optional(bool)
    restrict_public_buckets   = optional(bool)
    versioning_status         = optional(string)
    sse_enable                = optional(bool)
    sse_algorithm             = optional(string)
    kms_key_id                = optional(string)
    bucket_key_enabled        = optional(bool)
  })
  default = {}
}

variable "replication_role_arn" {
  description = "IAM role ARN used for S3 replication configuration when replication is defined."
  type        = string
  default     = null
}
