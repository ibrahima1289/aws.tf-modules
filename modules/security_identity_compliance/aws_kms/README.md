# AWS KMS Terraform Module

This module creates AWS KMS keys with aliases and grants. It supports symmetric/asymmetric keys, optional rotation, custom policies, multi-region keys.

## Requirements
- Terraform >= 1.0
- AWS Provider >= 4.0

## Inputs
Required
- `region` (string): AWS region.
- `keys` (list(object)): Key definitions.
  - `name` (string): Logical name.

Optional
- `tags` (map(string), default={}): Global tags.
- `keys[].description` (string)
- `keys[].key_usage` (string, default `ENCRYPT_DECRYPT`)
- `keys[].key_spec` (string, default `SYMMETRIC_DEFAULT`)
- `keys[].policy_json` (string)
- `keys[].deletion_window_in_days` (number, default 30)
- `keys[].enable_key_rotation` (bool, default false; symmetric only)
- `keys[].is_enabled` (bool, default true)
- `keys[].multi_region` (bool, default false)
- `keys[].bypass_policy_lockout_safety_check` (bool, default false)
- `keys[].aliases` (list(string))
- `keys[].tags` (map(string))
- `grants` (list(object), default=[]): Grant definitions.
  - `name` (string)
  - `key_name` (string)
  - `grantee_principal` (string)
  - `operations` (list(string))
  - `retiring_principal` (string?)
  - `encryption_context_equals` (map(string)?)
  - `encryption_context_subset` (map(string)?)

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
