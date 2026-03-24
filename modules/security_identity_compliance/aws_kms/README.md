# AWS KMS Terraform Module

This module creates AWS KMS keys with aliases and grants. It supports symmetric/asymmetric keys, optional rotation, custom policies, multi-region keys.

## Requirements
- Terraform >= 1.0
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
| `key_usage` | `string` | No | `"ENCRYPT_DECRYPT"` | Key usage: `ENCRYPT_DECRYPT` or `SIGN_VERIFY` |
| `key_spec` | `string` | No | `"SYMMETRIC_DEFAULT"` | Key spec: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, `ECC_SECG_P256K1`, `HMAC_256`, etc. |
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
      name                        = "app-key"
      description                 = "App encryption key"
      key_usage                   = "ENCRYPT_DECRYPT"
      key_spec                    = "SYMMETRIC_DEFAULT"
      enable_key_rotation         = true
      aliases                     = ["app-key", "app-key-v2"]
      tags                        = { Team = "platform" }
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
