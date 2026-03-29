# ── AWS Backup module ──────────────────────────────────────────────────────────
# Creates Backup vaults, optional vault policies, optional vault lock
# configurations, backup plans with schedule rules, and resource selections.
# All resource types support multiple instances via for_each; keys are provided
# by the caller in each list entry's .key field.

# ── Step 1: Backup Vaults ──────────────────────────────────────────────────────
# Encrypted containers that store AWS Backup recovery points (snapshots).
# Each vault is independently access-controlled via its own resource policy.
resource "aws_backup_vault" "vault" {
  for_each = local.vaults_map

  # Vault display name — must be unique within the account and region.
  name = each.value.name

  # ARN of the customer-managed KMS key used to encrypt recovery points.
  # Null falls back to the default AWS-managed Backup key (alias/aws/backup).
  kms_key_arn = each.value.kms_key_id

  # Merge common tags, vault-specific tags, and the Name tag.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ── Step 2: Vault Policies ─────────────────────────────────────────────────────
# Optional IAM resource policies that control cross-account or cross-service
# access to recovery points stored in a vault.
# Only created for vaults where vault_policy is explicitly set.
resource "aws_backup_vault_policy" "vault_policy" {
  for_each = { for k, v in local.vaults_map : k => v if v.vault_policy != null }

  # Reference the vault created in Step 1 by its key.
  backup_vault_name = aws_backup_vault.vault[each.key].name

  # JSON IAM policy document attached to the vault resource.
  policy = each.value.vault_policy
}

# ── Step 3: Vault Lock Configurations ─────────────────────────────────────────
# Write-Once-Read-Many (WORM) protection for recovery points.
# Once the changeable_for_days grace period expires, the lock is permanent
# and recovery points cannot be deleted before min_retention_days elapses.
# Only created for vaults where lock_configuration is explicitly set.
resource "aws_backup_vault_lock_configuration" "vault_lock" {
  for_each = { for k, v in local.vaults_map : k => v if v.lock_configuration != null }

  # Reference the vault created in Step 1 by its key.
  backup_vault_name = aws_backup_vault.vault[each.key].name

  # Grace period in days during which the lock settings can still be changed.
  # After this window the lock is permanent.  Null applies the lock immediately.
  changeable_for_days = each.value.lock_configuration.changeable_for_days

  # Upper retention ceiling in days; recovery points older than this are deleted.
  # Null means no upper limit.
  max_retention_days = each.value.lock_configuration.max_retention_days

  # Minimum retention floor in days; recovery points cannot be deleted sooner.
  min_retention_days = each.value.lock_configuration.min_retention_days
}

# ── Step 4: Backup Plans ───────────────────────────────────────────────────────
# Define when backups run, how long they are retained, and whether recovery
# points are copied to additional vaults for cross-region DR.
resource "aws_backup_plan" "plan" {
  for_each = local.plans_map

  # Backup plan display name.
  name = each.value.name

  # ── Rules ─────────────────────────────────────────────────────────────────────
  # Each rule defines one independent backup schedule within the plan.
  dynamic "rule" {
    for_each = each.value.rules
    content {
      # Rule display name — must be unique within the plan.
      rule_name = rule.value.name

      # Resolve vault name from the vault key provided by the caller.
      target_vault_name = aws_backup_vault.vault[rule.value.target_vault_key].name

      # Cron or rate expression; null means on-demand only.
      schedule = rule.value.schedule

      # How long after the scheduled time AWS Backup will attempt to start the job.
      start_window = rule.value.start_window

      # Maximum duration for the backup job before it is marked as failed.
      completion_window = rule.value.completion_window

      # Enable continuous backups for point-in-time restore (S3 only).
      # Incompatible with lifecycle rules — do not set both.
      enable_continuous_backup = rule.value.enable_continuous_backup

      # Tags applied to every recovery point created by this rule.
      recovery_point_tags = rule.value.recovery_point_tags

      # ── Lifecycle ──────────────────────────────────────────────────────────────
      # Controls transition to cold storage and final deletion of recovery points.
      # Omitted when lifecycle is null (no automatic lifecycle management).
      dynamic "lifecycle" {
        for_each = rule.value.lifecycle != null ? [rule.value.lifecycle] : []
        content {
          # Days until the recovery point is moved to cold storage.
          # Minimum 90 days for S3/EFS sources.  Null means never transition.
          cold_storage_after = lifecycle.value.cold_storage_after

          # Days until the recovery point is permanently deleted.
          # Must be >= cold_storage_after + 90 when cold storage is used.
          delete_after = lifecycle.value.delete_after
        }
      }

      # ── Copy Actions ───────────────────────────────────────────────────────────
      # Replicate each recovery point to additional vaults (same or other region).
      # Omitted when copy_actions is empty.
      dynamic "copy_action" {
        for_each = rule.value.copy_actions
        content {
          # ARN of the destination vault where the copy will be stored.
          destination_vault_arn = copy_action.value.destination_vault_arn

          # Lifecycle settings applied to the copy in the destination vault.
          # Omitted when lifecycle is null on the copy action.
          dynamic "lifecycle" {
            for_each = copy_action.value.lifecycle != null ? [copy_action.value.lifecycle] : []
            content {
              # Days until the copy transitions to cold storage.
              cold_storage_after = lifecycle.value.cold_storage_after

              # Days until the copy is permanently deleted.
              delete_after = lifecycle.value.delete_after
            }
          }
        }
      }
    }
  }

  # Merge common tags, plan-specific tags, and the Name tag.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ── Step 5: Backup Selections ──────────────────────────────────────────────────
# Associate AWS resources (by ARN or tag) with a backup plan so that AWS Backup
# knows which resources to protect on each scheduled run.
resource "aws_backup_selection" "selection" {
  for_each = local.selections_map

  # Selection display name.
  name = each.value.name

  # Resolve backup plan ID from the plan key provided by the caller.
  plan_id = aws_backup_plan.plan[each.value.plan_key].id

  # IAM role that AWS Backup assumes to create and restore recovery points.
  # Must have AWSBackupServiceRolePolicyForBackup and
  # AWSBackupServiceRolePolicyForRestores attached.
  iam_role_arn = each.value.iam_role_arn

  # Explicit list of resource ARNs to back up.
  # Empty list combined with selection_tags or conditions enables tag-based mode.
  resources = each.value.resources

  # Explicit ARN exclusions — only valid in tag-based selection mode.
  not_resources = each.value.not_resources

  # ── Tag-based Selection (legacy format) ────────────────────────────────────────
  # Adds one selection_tag block per entry; all conditions are ANDed.
  dynamic "selection_tag" {
    for_each = each.value.selection_tags
    content {
      # Condition operator: STRINGEQUALS, STRINGLIKE, STRINGNOTEQUALS, STRINGNOTLIKE.
      type = selection_tag.value.type

      # Tag key to evaluate.
      key = selection_tag.value.key

      # Tag value to match (supports wildcards for LIKE operators).
      value = selection_tag.value.value
    }
  }

  # ── Advanced Conditions ────────────────────────────────────────────────────────
  # Fine-grained tag-based selection using multiple condition types in one block.
  # Omitted when conditions is null.
  dynamic "condition" {
    for_each = each.value.conditions != null ? [each.value.conditions] : []
    content {
      # Include resources whose tag exactly equals key=value.
      dynamic "string_equals" {
        for_each = condition.value.string_equals
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }

      # Include resources whose tag does not exactly equal key=value.
      dynamic "string_not_equals" {
        for_each = condition.value.string_not_equals
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }

      # Include resources whose tag value matches the glob pattern.
      dynamic "string_like" {
        for_each = condition.value.string_like
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }

      # Include resources whose tag value does not match the glob pattern.
      dynamic "string_not_like" {
        for_each = condition.value.string_not_like
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }
}
