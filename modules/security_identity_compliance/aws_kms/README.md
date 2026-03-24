# AWS KMS Terraform Module

> **Service:** AWS Key Management Service (KMS) &nbsp;|&nbsp; **Module path:** `modules/security_identity_compliance/aws_kms` &nbsp;|&nbsp; **Wrapper path:** `tf-plans/aws_kms`

This module creates **Customer Managed Keys (CMK)** in AWS KMS with full control over aliases, grants, key policies, rotation, and multi-region replication.

---

## KMS Key Ownership Models

Understanding the three key ownership models helps you choose when to use this module vs. relying on AWS-managed defaults.

| Model | Owned & Managed by | Visible in Account | Creatable via Terraform | Cost |
|---|---|---|---|---|
| **AWS Owned Keys** | AWS (internal only) | ❌ No | ❌ No | Free |
| **AWS Managed Keys** | AWS (on your behalf) | ✅ Yes — `alias/aws/<service>` | ❌ No — auto-created by AWS services | Free |
| **Customer Managed Keys (CMK)** | **You** | ✅ Yes — full control | ✅ **Yes — this module** | ~$1/key/month + API call fees |

> **This module creates CMKs only.** To use an AWS Managed Key (e.g. `alias/aws/s3`), reference it directly in your resource's `kms_key_id` argument — no Terraform resource is needed.

---

## CMK Key Types

| `key_type` | AWS `key_usage` | Default `key_spec` | Rotation Supported | Typical Use Case |
|---|---|---|---|---|
| `SYMMETRIC_ENCRYPTION` *(default)* | `ENCRYPT_DECRYPT` | `SYMMETRIC_DEFAULT` | ✅ Yes (annual) | S3, EBS, RDS, Secrets Manager, general-purpose encryption |
| `RSA_ENCRYPT_DECRYPT` | `ENCRYPT_DECRYPT` | `RSA_2048` | ❌ No | Envelope encryption with external RSA public key |
| `RSA_SIGN_VERIFY` | `SIGN_VERIFY` | `RSA_2048` | ❌ No | JWT signing, document signing, code signing |
| `ECC_SIGN_VERIFY` | `SIGN_VERIFY` | `ECC_NIST_P256` | ❌ No | ECDSA signatures, TLS client auth |
| `HMAC` | `GENERATE_VERIFY_MAC` | `HMAC_256` | ❌ No | Message authentication codes (MAC), API request signing |

**Key spec options per type:**

| Type | Available `key_spec` values |
|---|---|
| Symmetric | `SYMMETRIC_DEFAULT` |
| RSA | `RSA_2048` · `RSA_3072` · `RSA_4096` |
| ECC | `ECC_NIST_P256` · `ECC_NIST_P384` · `ECC_NIST_P521` · `ECC_SECG_P256K1` |
| HMAC | `HMAC_224` · `HMAC_256` · `HMAC_384` · `HMAC_512` |

---

## Terraform & Provider Requirements

| Requirement | Version |
|---|---|
| Terraform | `>= 1.3` (required for `optional()` with defaults in object types) |
| AWS Provider | `>= 4.0` |
| AWS Region | Set via `var.region` |

---

## Requirements
- Terraform >= 1.3
- AWS Provider >= 4.0

## Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region where KMS keys are created |
| `tags` | `map(string)` | No | `{}` | Global tags applied to all KMS resources |
| `keys` | `list(object)` | ✅ Yes | n/a | List of KMS key definitions — see object fields below |
| `grants` | `list(object)` | No | `[]` | List of KMS grant definitions bound to keys — see object fields below |

### `keys` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | ✅ Yes | n/a | Logical name used for tagging, aliases, and grant lookups |
| `description` | `string` | No | `""` | Human-readable description of the key |
| `key_type` | `string` | No | `"SYMMETRIC_ENCRYPTION"` | High-level key type that auto-sets `key_usage` and a default `key_spec`. Values: `SYMMETRIC_ENCRYPTION`, `RSA_ENCRYPT_DECRYPT`, `RSA_SIGN_VERIFY`, `ECC_SIGN_VERIFY`, `HMAC` |
| `key_usage` | `string` | No | *(derived from `key_type`)* | Override the AWS key usage directly: `ENCRYPT_DECRYPT`, `SIGN_VERIFY`, or `GENERATE_VERIFY_MAC`. Ignored when `key_type` is sufficient |
| `key_spec` | `string` | No | *(derived from `key_type`)* | Key spec override: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, `ECC_SECG_P256K1`, `HMAC_224`, `HMAC_256`, `HMAC_384`, `HMAC_512`. When omitted, `key_type` supplies the default |
| `policy_json` | `string` | No | `null` | JSON-encoded IAM key policy; defaults to AWS-managed default policy when omitted |
| `deletion_window_in_days` | `number` | No | `10` | Days before key is permanently deleted after scheduling deletion (7–30) |
| `enable_key_rotation` | `bool` | No | `false` | Enable automatic annual key rotation — only valid for `SYMMETRIC_DEFAULT` keys |
| `is_enabled` | `bool` | No | `true` | Whether the key is enabled for cryptographic operations |
| `multi_region` | `bool` | No | `false` | Create a multi-region primary key that can be replicated to other regions |
| `bypass_policy_lockout_safety_check` | `bool` | No | `false` | Skip the AWS lockout safety check when setting a custom key policy |
| `aliases` | `list(string)` | No | `[]` | Alias names to attach (without the `alias/` prefix); first entry becomes the primary alias |
| `tags` | `map(string)` | No | `{}` | Key-level tags merged with global `tags` and `created_date` |

### `grants` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | ✅ Yes | n/a | Unique name for the grant resource |
| `key_name` | `string` | ✅ Yes | n/a | Must match a `name` in `var.keys` |
| `grantee_principal` | `string` | ✅ Yes | n/a | ARN of the IAM principal (role, user, service) receiving the grant |
| `operations` | `list(string)` | ✅ Yes | n/a | Allowed operations, e.g. `["Encrypt", "Decrypt", "GenerateDataKey"]` |
| `retiring_principal` | `string` | No | `null` | ARN of the principal allowed to retire the grant |
| `encryption_context_equals` | `map(string)` | No | `null` | Exact encryption context required for the grant to apply |
| `encryption_context_subset` | `map(string)` | No | `null` | Partial encryption context subset required for the grant to apply |

## Outputs
- `key_ids`: Map of key name to KMS key ID.
- `key_arns`: Map of key name to KMS key ARN.
- `alias_names`: Map of key name to its primary alias (if defined).
- `all_aliases`: Map of key name to all alias names (primary + additional, if any).

## Tags
All KMS keys include `created_date` in tags, sourced from `locals.created_date` (YYYY-MM-DD).

## Usage
```
module "aws_kms" {
  source = "../../modules/security_identity_compliance/aws_kms"
  region = var.region
  tags   = { Environment = "dev" }

  keys = [
    {
      name                = "app-key"
      description         = "Symmetric encryption key for application data"
      key_type            = "SYMMETRIC_ENCRYPTION"   # key_usage + key_spec auto-set
      enable_key_rotation = true
      aliases             = ["app-key", "app-key-v2"]
      tags                = { Team = "platform" }
    },
    {
      name     = "signing-key"
      key_type = "RSA_SIGN_VERIFY"                   # key_usage = SIGN_VERIFY
      key_spec = "RSA_4096"                          # override default RSA_2048
      aliases  = ["signing-key"]
    },
    {
      name     = "mac-key"
      key_type = "HMAC"                              # key_usage = GENERATE_VERIFY_MAC
      key_spec = "HMAC_256"
      aliases  = ["mac-key"]
    }
  ]

  grants = [
    {
      name              = "app-decrypt"
      key_name          = "app-key"
      grantee_principal = "arn:aws:iam::123456789012:role/app-role"
      operations        = ["Decrypt", "Encrypt", "GenerateDataKey"]
    }
  ]
}
```
