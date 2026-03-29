variable "region" {
  description = "AWS region where Backup resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all taggable AWS Backup resources."
  type        = map(string)
  default     = {}
}

# ── Vaults ─────────────────────────────────────────────────────────────────────

variable "vaults" {
  description = "List of Backup vaults to create.  See module variables.tf for full field reference."
  type = list(object({
    key          = string
    name         = string
    kms_key_id   = optional(string, null)
    tags         = optional(map(string), {})
    vault_policy = optional(string, null)
    lock_configuration = optional(object({
      changeable_for_days = optional(number, null)
      max_retention_days  = optional(number, null)
      min_retention_days  = number
    }), null)
  }))
  default = []
}

# ── Plans ──────────────────────────────────────────────────────────────────────

variable "plans" {
  description = "List of Backup plans to create.  See module variables.tf for full field reference."
  type = list(object({
    key  = string
    name = string
    tags = optional(map(string), {})
    rules = list(object({
      name                     = string
      target_vault_key         = string
      schedule                 = optional(string, null)
      start_window             = optional(number, 60)
      completion_window        = optional(number, 180)
      enable_continuous_backup = optional(bool, false)
      recovery_point_tags      = optional(map(string), {})
      lifecycle = optional(object({
        cold_storage_after = optional(number, null)
        delete_after       = optional(number, null)
      }), null)
      copy_actions = optional(list(object({
        destination_vault_arn = string
        lifecycle = optional(object({
          cold_storage_after = optional(number, null)
          delete_after       = optional(number, null)
        }), null)
      })), [])
    }))
  }))
  default = []
}

# ── Selections ─────────────────────────────────────────────────────────────────

variable "selections" {
  description = "List of Backup selections to create.  See module variables.tf for full field reference."
  type = list(object({
    key           = string
    name          = string
    plan_key      = string
    iam_role_arn  = string
    resources     = optional(list(string), [])
    not_resources = optional(list(string), [])
    selection_tags = optional(list(object({
      type  = string
      key   = string
      value = string
    })), [])
    conditions = optional(object({
      string_equals     = optional(list(object({ key = string, value = string })), [])
      string_not_equals = optional(list(object({ key = string, value = string })), [])
      string_like       = optional(list(object({ key = string, value = string })), [])
      string_not_like   = optional(list(object({ key = string, value = string })), [])
    }), null)
  }))
  default = []
}
