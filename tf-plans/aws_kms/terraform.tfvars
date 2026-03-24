# AWS KMS Terraform Module — Example Usage
region = "ca-central-1"

tags = {
  Environment = "dev"
}

# ─────────────────────────────────────────────────────────────────────────────
# KMS Key Ownership Model — Reference
# ─────────────────────────────────────────────────────────────────────────────
# AWS Owned Keys
#   - Owned and managed entirely by AWS; used for internal service encryption.
#   - Invisible in your account; no cost, no control.
#   - Cannot be created, viewed, or managed via Terraform.
#
# AWS Managed Keys  (e.g. alias/aws/s3, alias/aws/ebs)
#   - Created automatically by AWS when you first enable encryption on a service.
#   - Visible in your account but key policy and rotation are controlled by AWS.
#   - Cannot be created via Terraform; reference them by alias in resource configs.
#
# Customer Managed Keys (CMK)  ← all keys below are CMKs
#   - Keys you create, own, and fully control: policy, rotation, aliases, grants.
#   - Can be symmetric, asymmetric (RSA/ECC), or HMAC.
#   - This module creates CMKs only.
# ─────────────────────────────────────────────────────────────────────────────
keys = [
  # CMK — Symmetric encryption key (SYMMETRIC_DEFAULT). Supports automatic annual rotation.
  {
    name                    = "app-key"
    description             = "Application encryption key"
    key_type                = "SYMMETRIC_ENCRYPTION"
    enable_key_rotation     = true
    aliases                 = ["app-key"]
    deletion_window_in_days = 7
    policy_file             = "policies/app-key-policy.json"
    tags                    = { Team = "platform" }
  },
  # CMK — Asymmetric RSA key used for digital signing and verification. Rotation not supported.
  {
    name                    = "signing-key"
    key_type                = "RSA_SIGN_VERIFY"
    key_spec                = "RSA_2048"
    aliases                 = ["signing-key"]
    multi_region            = true
    deletion_window_in_days = 7
    policy_file             = "policies/signing-key-policy.json"
    tags                    = { Team = "security" }
  },
  # CMK — Symmetric key scheduled for deletion (long deletion window for safety).
  {
    name                    = "legacy-key"
    description             = "Legacy key pending scheduled deletion"
    key_type                = "SYMMETRIC_ENCRYPTION"
    enable_key_rotation     = false
    aliases                 = ["legacy-key"]
    deletion_window_in_days = 30
    tags                    = { Team = "platform", Status = "deprecated" }
  },
  # CMK (Imported Key Material) — Key metadata is managed by AWS KMS, but cryptographic
  # material is imported from an external HSM or key management system (origin = EXTERNAL).
  {
    name        = "external-key"
    description = "External key imported into AWS KMS"
    key_usage   = "ENCRYPT_DECRYPT"
    key_spec    = "SYMMETRIC_DEFAULT"
    origin      = "EXTERNAL"
    aliases     = ["external-key"]
    tags        = { Team = "third-party" }
  },
  # CMK — HMAC key for message authentication codes (Generate/Verify MAC). Asymmetric; no rotation.
  {
    name        = "mac-key"
    description = "HMAC message authentication key"
    key_type    = "HMAC"
    key_spec    = "HMAC_256"
    aliases     = ["mac-key"]
    tags        = { Team = "security" }
  }
]

# Grants allow you to delegate specific permissions on a KMS key to other AWS principals (users, roles, services).
# This is more flexible than IAM policies for certain use cases, such as temporary permissions or cross-account access.
grants = [
  {
    name              = "app-decrypt"
    key_name          = "app-key"
    grantee_principal = "arn:aws:iam::123456789012:role/aws-ecr-role"
    operations        = ["Decrypt", "Encrypt", "GenerateDataKey"]
  },
  {
    name              = "signing-verify"
    key_name          = "signing-key"
    grantee_principal = "arn:aws:iam::123456789012:user/alice"
    operations        = ["Verify"]
    constraints = {
      encryption_context_subset = {
        "Department" = "Security"
      }
    }
  }
]
