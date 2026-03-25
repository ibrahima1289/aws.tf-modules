variable "region" {
  description = "AWS region where Athena resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all taggable Athena resources."
  type        = map(string)
  default     = {}
}

# ── Workgroups ────────────────────────────────────────────────────────────────

variable "workgroups" {
  description = "List of Athena workgroups.  See module variables.tf for full field reference."
  type = list(object({
    key                             = string
    name                            = string
    description                     = optional(string, "")
    state                           = optional(string, "ENABLED")
    force_destroy                   = optional(bool, false)
    result_s3_location              = string
    result_encryption_option        = optional(string, "SSE_S3")
    kms_key_arn                     = optional(string, null)
    s3_acl_option                   = optional(string, null)
    expected_bucket_owner           = optional(string, null)
    engine_version                  = optional(string, "AUTO")
    bytes_scanned_cutoff_per_query  = optional(number, null)
    enforce_workgroup_configuration = optional(bool, true)
    publish_cloudwatch_metrics      = optional(bool, true)
    requester_pays                  = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
  default = []
}

# ── Databases ─────────────────────────────────────────────────────────────────

variable "databases" {
  description = "List of Athena (Glue-backed) databases.  See module variables.tf for full field reference."
  type = list(object({
    key                   = string
    name                  = string
    bucket                = string
    comment               = optional(string, "")
    encryption_option     = optional(string, null)
    kms_key_arn           = optional(string, null)
    expected_bucket_owner = optional(string, null)
    force_destroy         = optional(bool, false)
  }))
  default = []
}

# ── Data Catalogs ─────────────────────────────────────────────────────────────
# Named queries are NOT declared here — they are built in locals.tf so that
# SQL strings can be loaded from external .sql files via file().

variable "data_catalogs" {
  description = "List of Athena federated data catalogs.  See module variables.tf for full field reference."
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "")
    type        = string
    parameters  = map(string)
    tags        = optional(map(string), {})
  }))
  default = []
}
