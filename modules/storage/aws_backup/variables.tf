# ── Top-level variables ───────────────────────────────────────────────────────

variable "region" {
  description = "AWS region where Backup resources are deployed."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Common tags applied to all taggable AWS Backup resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

# ── Vaults ─────────────────────────────────────────────────────────────────────

variable "vaults" {
  description = <<-EOT
    List of AWS Backup vaults to create.  Each entry maps to one aws_backup_vault
    resource, with optional vault policy and vault lock configuration.
    Unique keys are used as for_each identifiers.

    Vault guidance:
      - Every backup plan rule must reference a target vault by key.
      - Encrypt vaults with a customer-managed KMS key for compliance workloads.
      - Use vault lock (WORM) to satisfy regulatory immutability requirements.
      - The default vault policy is open to the owning account; restrict it for
        cross-account or cross-region access patterns.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Backup vault display name; must be unique within the account/region.
    name = string

    # ARN of a customer-managed KMS key used to encrypt recovery points.
    # When null, the default AWS-managed Backup key is used.
    kms_key_id = optional(string, null)

    # Per-vault tags merged with common_tags.
    tags = optional(map(string), {})

    # JSON IAM resource policy attached to the vault.
    # Controls who may create, delete, or restore recovery points.
    # Null means no explicit policy (account root has full access).
    vault_policy = optional(string, null)

    # Vault Lock (WORM) settings.  Once the grace period expires the lock
    # becomes permanent and recovery points cannot be deleted ahead of schedule.
    # Null means no lock is applied.
    lock_configuration = optional(object({
      # Grace period in days during which the lock can be removed (1–7 days).
      # After this window the lock is permanent and cannot be changed.
      # Null means no grace period (lock is applied immediately — use with care).
      changeable_for_days = optional(number, null)

      # Maximum allowed retention in days for recovery points in this vault.
      # Recovery points stored longer than this value will be automatically deleted.
      # Null means no upper retention limit.
      max_retention_days = optional(number, null)

      # Minimum required retention in days for recovery points in this vault.
      # AWS Backup will reject any lifecycle that would delete a point sooner.
      min_retention_days = number
    }), null)
  }))
  default = []
}

# ── Plans ──────────────────────────────────────────────────────────────────────

variable "plans" {
  description = <<-EOT
    List of AWS Backup plans to create.  Each entry maps to one aws_backup_plan
    resource, which may contain multiple schedule rules and copy actions.
    Unique keys are used as for_each identifiers.

    Plan guidance:
      - A plan can contain multiple rules with different schedules and retention.
      - Each rule targets exactly one vault (by vault_key).
      - Use copy_actions to replicate recovery points to a DR vault (same or
        different region/account).
      - enable_continuous_backup is only supported for S3 and is incompatible
        with lifecycle rules.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Backup plan display name.
    name = string

    # Per-plan tags merged with common_tags.
    tags = optional(map(string), {})

    # One or more backup rules defining schedule, retention, and copy behaviour.
    rules = list(object({
      # Rule display name; must be unique within the plan.
      name = string

      # Key of the target vault (must match a vaults[*].key entry).
      target_vault_key = string

      # Cron or rate expression for the backup schedule.
      # Examples: "cron(0 5 * * ? *)" for daily at 05:00 UTC,
      #           "rate(1 day)" for every 24 hours.
      # Null means on-demand only.
      schedule = optional(string, null)

      # Minutes after the scheduled time within which the backup job must start.
      start_window = optional(number, 60)

      # Minutes after a backup job starts within which it must complete.
      completion_window = optional(number, 180)

      # Enable continuous backups for point-in-time restore (S3 only).
      # Incompatible with lifecycle rules.
      enable_continuous_backup = optional(bool, false)

      # Additional tags applied to each recovery point created by this rule.
      recovery_point_tags = optional(map(string), {})

      # Transition and deletion lifecycle for recovery points.
      # Null means no lifecycle management (recovery points persist until manual deletion).
      lifecycle = optional(object({
        # Days after creation before transitioning the recovery point to cold storage.
        # Minimum 90 days for S3 and EFS.  Null means never transition.
        cold_storage_after = optional(number, null)

        # Days after creation before deleting the recovery point.
        # Must be >= cold_storage_after + 90 when cold_storage_after is set.
        # Null means retain indefinitely.
        delete_after = optional(number, null)
      }), null)

      # Cross-vault or cross-region/account copy actions performed after backup.
      copy_actions = optional(list(object({
        # ARN of the destination vault to copy the recovery point into.
        destination_vault_arn = string

        # Lifecycle settings for the copy stored in the destination vault.
        # Null means no lifecycle on the copy (it persists until manually deleted).
        lifecycle = optional(object({
          # Days after copy creation before transitioning to cold storage.
          cold_storage_after = optional(number, null)

          # Days after copy creation before deleting the recovery point.
          delete_after = optional(number, null)
        }), null)
      })), [])
    }))
  }))
  default = []
}

# ── Selections ─────────────────────────────────────────────────────────────────

variable "selections" {
  description = <<-EOT
    List of AWS Backup selections to create.  Each entry maps to one
    aws_backup_selection resource that associates resources with a backup plan.
    Unique keys are used as for_each identifiers.

    Selection guidance:
      - Use resources (ARN list) for explicit resource targeting.
      - Leave resources empty and set selection_tags or conditions for
        tag-based dynamic selection (preferred for large fleets).
      - not_resources excludes specific ARNs from a tag-based selection.
      - The IAM role must have the AWSBackupServiceRolePolicyForBackup and
        AWSBackupServiceRolePolicyForRestores managed policies attached.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Selection display name.
    name = string

    # Key of the backup plan to associate with (must match a plans[*].key entry).
    plan_key = string

    # ARN of the IAM role that AWS Backup assumes to back up the selected resources.
    # Typically arn:aws:iam::ACCOUNT_ID:role/AWSBackupDefaultServiceRole.
    iam_role_arn = string

    # Explicit list of resource ARNs to back up.
    # An empty list means all resources that match selection_tags/conditions.
    resources = optional(list(string), [])

    # Explicit list of resource ARNs to exclude from a tag-based selection.
    # Only valid when resources is empty (tag-based mode).
    not_resources = optional(list(string), [])

    # Tag-based selection conditions (legacy format; compatible with all resource types).
    # Each entry adds one tag condition.  Multiple conditions are ANDed together.
    selection_tags = optional(list(object({
      # Condition type: STRINGEQUALS, STRINGLIKE, STRINGNOTEQUALS, STRINGNOTLIKE.
      type = string

      # Tag key to match.
      key = string

      # Tag value to match (supports wildcards for STRINGLIKE/STRINGNOTLIKE).
      value = string
    })), [])

    # Advanced conditions block for fine-grained tag-based selection.
    # Supports multiple condition types in a single block.
    # Null means no advanced conditions.
    conditions = optional(object({
      # Resources whose tag exactly equals key=value are included.
      string_equals = optional(list(object({ key = string, value = string })), [])

      # Resources whose tag does not exactly equal key=value are included.
      string_not_equals = optional(list(object({ key = string, value = string })), [])

      # Resources whose tag value matches the glob pattern are included.
      string_like = optional(list(object({ key = string, value = string })), [])

      # Resources whose tag value does not match the glob pattern are included.
      string_not_like = optional(list(object({ key = string, value = string })), [])
    }), null)
  }))
  default = []
}
