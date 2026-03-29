region = "us-east-1"

tags = {
  environment = "production"
  team        = "platform"
  project     = "backup-infra"
  managed_by  = "terraform"
}

# ── Vaults ─────────────────────────────────────────────────────────────────────
# Pattern 1: Primary encrypted vault for daily/weekly production backups.
#            Uses the default AWS-managed Backup key (no kms_key_id specified).
# Pattern 2: (commented out) DR vault in us-west-2 as copy_action destination.
# Pattern 3: (commented out) Compliance vault with Vault Lock (WORM) enabled.

vaults = [
  {
    # Primary production vault — encrypted with the AWS-managed Backup key.
    key  = "primary"
    name = "prod-primary-vault"
    tags = {
      role = "primary",
      tier = "production"
    }
    # kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123def456"
  }
  # ,
  # {
  #   # ── Pattern 2: Cross-region DR vault (us-west-2) ──────────────────────────
  #   # Receives copies of recovery points via copy_action in the backup plan.
  #   # Deploy this vault in the DR account/region using a separate wrapper plan.
  #   # Provide its ARN as destination_vault_arn in the copy_actions block below.
  #   key  = "dr-west"
  #   name = "prod-dr-vault-usw2"
  #   tags = { role = "dr", tier = "production", region = "us-west-2" }
  # },
  # {
  #   # ── Pattern 3: Compliance vault with Vault Lock (WORM) ────────────────────
  #   # min_retention_days = 365 enforces 1-year minimum retention.
  #   # changeable_for_days = 3 gives a 3-day grace period to correct mistakes.
  #   # After the grace period the lock is permanent — recovery points cannot be
  #   # deleted before 365 days have elapsed, even by an account administrator.
  #   key  = "compliance"
  #   name = "prod-compliance-vault"
  #   tags = { role = "compliance", compliance = "hipaa" }
  #   lock_configuration = {
  #     min_retention_days  = 365  # 1-year WORM floor
  #     max_retention_days  = 2555 # 7-year ceiling
  #     changeable_for_days = 3    # grace period — set to null to lock immediately
  #   }
  # }
]

# ── Plans ──────────────────────────────────────────────────────────────────────
# Pattern 1 — Daily at 05:00 UTC with 35-day retention (cold after 30 days),
#             plus weekly Sunday with 1-year retention (cold after 30 days).
# Pattern 2 — (commented out) Adds a cross-region DR copy_action to us-west-2.

plans = [
  {
    key  = "daily-weekly"
    name = "prod-daily-weekly-plan"
    tags = { schedule = "daily-weekly" }

    rules = [
      {
        # Daily backup at 05:00 UTC, 35-day retention, cold storage after 30 days.
        name              = "daily-0500-utc"
        target_vault_key  = "primary"
        schedule          = "cron(0 5 * * ? *)" # every day at 05:00 UTC
        start_window      = 60                  # minutes to start the job
        completion_window = 180                 # minutes to complete the job

        lifecycle = {
          cold_storage_after = 30 # transition to cold storage after 30 days
          delete_after       = 35 # delete after 35 days (cold_storage_after + 5)
        }

        recovery_point_tags = { frequency = "daily" }
      },
      {
        # Weekly backup every Sunday, 1-year retention, cold storage after 30 days.
        name              = "weekly-sunday"
        target_vault_key  = "primary"
        schedule          = "cron(0 5 ? * 1 *)" # every Sunday at 05:00 UTC
        start_window      = 60
        completion_window = 480 # 8 hours — longer window for large weekly backups

        lifecycle = {
          cold_storage_after = 30  # move to cold storage after 30 days
          delete_after       = 365 # retain for 1 year
        }

        recovery_point_tags = { frequency = "weekly" }
      }
    ]
  }
  # ,
  # {
  #   # ── Pattern 2: Cross-region DR copy ───────────────────────────────────────
  #   # Mirrors the daily rule above and adds a copy_action to a DR vault in
  #   # us-west-2.  Replace destination_vault_arn with the actual DR vault ARN.
  #   key  = "daily-with-dr"
  #   name = "prod-daily-dr-plan"
  #   tags = { schedule = "daily-dr" }
  #
  #   rules = [
  #     {
  #       name             = "daily-0500-utc-dr"
  #       target_vault_key = "primary"
  #       schedule         = "cron(0 5 * * ? *)"
  #       start_window     = 60
  #       completion_window = 180
  #
  #       lifecycle = {
  #         cold_storage_after = 30
  #         delete_after       = 35
  #       }
  #
  #       copy_actions = [
  #         {
  #           # Destination vault ARN in us-west-2 DR account.
  #           # Replace with the actual ARN output from the DR vault plan.
  #           destination_vault_arn = "arn:aws:backup:us-west-2:123456789012:backup-vault:prod-dr-vault-usw2"
  #
  #           lifecycle = {
  #             cold_storage_after = 30
  #             delete_after       = 35
  #           }
  #         }
  #       ]
  #     }
  #   ]
  # }
]

# ── Selections ─────────────────────────────────────────────────────────────────
# Pattern 1 — Tag-based selection: back up all resources tagged Environment=production.
#             Replace iam_role_arn with the role ARN from your account.
# Pattern 2 and 3 show ARN-based and vault-lock selections (commented out).

selections = [
  {
    # Tag-based selection — include all resources tagged Environment=production.
    # An empty resources list combined with selection_tags activates tag mode.
    key          = "prod-tagged"
    name         = "prod-tagged-resources"
    plan_key     = "daily-weekly"
    iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"

    # Leave resources empty to use tag-based selection.
    resources = []

    selection_tags = [
      {
        type  = "STRINGEQUALS"
        key   = "Environment"
        value = "production"
      }
    ]
  }
  # ,
  # {
  #   # ── Pattern 2: Explicit ARN-based selection ────────────────────────────────
  #   # Back up a specific RDS cluster and an EFS file system by ARN.
  #   key          = "specific-resources"
  #   name         = "specific-arns"
  #   plan_key     = "daily-weekly"
  #   iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"
  #
  #   resources = [
  #     "arn:aws:rds:us-east-1:123456789012:cluster:prod-aurora-cluster",
  #     "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-0abc123"
  #   ]
  # },
  # {
  #   # ── Pattern 3: Advanced conditions — tag-prefix wildcard ──────────────────
  #   # Include all resources where the Team tag starts with "platform".
  #   # Uses the conditions block (string_like) instead of legacy selection_tags.
  #   key          = "platform-team"
  #   name         = "platform-team-resources"
  #   plan_key     = "daily-weekly"
  #   iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"
  #
  #   conditions = {
  #     string_like = [
  #       { key = "Team", value = "platform*" }
  #     ]
  #   }
  # }
]
