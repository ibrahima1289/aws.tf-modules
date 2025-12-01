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
  description = "List of bucket configurations. Each item supports name, acl, policy_json, logging, lifecycle_rules, replication, and tags."
  type = list(object({
    name        = string
    acl         = optional(string)
    policy_json = optional(string)
    tags        = optional(map(string))
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
    object_ownership        = optional(string)
    block_public_acls       = optional(bool)
    block_public_policy     = optional(bool)
    ignore_public_acls      = optional(bool)
    restrict_public_buckets = optional(bool)
    versioning_status       = optional(string)
    sse_enable              = optional(bool)
    sse_algorithm           = optional(string)
    kms_key_id              = optional(string)
    bucket_key_enabled      = optional(bool)
  })
  default = {}
}

variable "replication_role_arn" {
  description = "IAM role ARN used for S3 replication configuration when replication is defined."
  type        = string
  default     = null
}
