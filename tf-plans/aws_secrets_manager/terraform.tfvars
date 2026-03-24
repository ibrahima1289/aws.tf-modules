region = "ca-central-1"

tags = {
  Environment = "dev"
  Project     = "platform"
}

# ─────────────────────────────────────────────────────────────────────────────
# Secrets — All entries below are Customer-managed secrets.
# AWS Secrets Manager stores three categories of secrets:
#  · Credentials  — database usernames/passwords, SSH keys
#  · API Keys      — third-party service tokens, OAuth tokens
#  · Configuration — app config bundles, JSON documents
# ─────────────────────────────────────────────────────────────────────────────
secrets = [
  # CMK-encrypted RDS credentials with automatic 30-day rotation via Lambda.
  # No secret_string here — the rotation Lambda initialises and rotates the value.
  {
    key                     = "db-credentials"
    name                    = "prod/rds/db-credentials"
    description             = "RDS MySQL master credentials — rotated every 30 days by Lambda"
    kms_key_id              = "arn:aws:kms:ca-central-1:123456789012:key/mrk-abc123"
    recovery_window_in_days = 7
    rotation_lambda_arn     = "arn:aws:lambda:ca-central-1:123456789012:function:rotate-rds-secret"
    rotation_days           = 30
    tags = {
      Team = "platform",
      App  = "webapp"
    }
  },

  # Static third-party payment API key stored as a plain-text string.
  # lifecycle { ignore_changes } prevents Terraform drift after a manual key roll.
  {
    key           = "payment-api-key"
    name          = "prod/integrations/payment-api-key"
    description   = "Payment gateway API key — update via Console or SDK, not Terraform"
    secret_string = "sk_live_REPLACE_ME"
    tags = {
      Team = "payments"
    }
  },

  # JSON application config bundle with a cross-account read policy.
  # Policy is loaded from policies/app-config-policy.json via locals.tf — not set here.
  # secret_string is loaded from secrets/app-config.json via locals.tf — not set here.
  {
    key         = "app-config"
    name        = "prod/app/config"
    description = "Application configuration bundle shared with analytics account"
    tags = {
      Team = "platform"
    }
  },

  # Multi-region JWT signing key replicated to us-east-1 for disaster recovery.
  # Each region uses its own CMK replica for encryption.
  {
    key         = "jwt-signing-key"
    name        = "prod/auth/jwt-signing-key"
    description = "JWT signing key replicated to us-east-1 for DR failover"
    kms_key_id  = "arn:aws:kms:ca-central-1:123456789012:key/mrk-def456"
    replica_regions = [
      {
        region     = "us-east-1"
        kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/mrk-ghi789"
      }
    ]
    tags = {
      Team = "security"
    }
  }
]
