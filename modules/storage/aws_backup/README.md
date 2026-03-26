# AWS Backup Module

Reusable Terraform module for [Amazon AWS Backup](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html) — centrally manage and automate data protection across AWS services including EC2, RDS, S3, EBS, and EFS.

> See [aws-backup.md](aws-backup.md) for a full service reference, supported resource types, and pricing model.

---

## Architecture

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                        AWS Backup Module                                 │
  │                                                                          │
  │  ┌──────────────────────────────────────────────────────────────────┐    │
  │  │              aws_backup_plan  (for_each)                         │    │
  │  │                                                                  │    │
  │  │  ┌──────────────────┐    ┌──────────────────────────────────┐    │    │
  │  │  │  rule: daily     │    │  rule: weekly                    │    │    │
  │  │  │  cron(0 5 * * ?) │    │  cron(0 5 ? * 1 *)              │    │    │
  │  │  │  lifecycle: 35d  │    │  lifecycle: 365d                 │    │    │
  │  │  └────────┬─────────┘    └──────────────┬───────────────────┘    │    │
  │  └───────────┼──────────────────────────────┼───────────────────────┘    │
  │              │                              │                            │
  │              ▼                              ▼                            │
  │  ┌─────────────────────────────────────────────────────────────────┐     │
  │  │              aws_backup_vault  (for_each)                        │     │
  │  │                                                                  │     │
  │  │  ─ KMS encryption (AWS-managed or customer key)                  │     │
  │  │  ─ Optional resource policy (cross-account access)               │     │
  │  │  ─ Optional Vault Lock / WORM (min/max retention days)           │     │
  │  │  ─ Optional DR copy to remote region vault                       │     │
  │  └──────────────────────────────────────────────────────────────────┘     │
  │                                                                          │
  │  ┌──────────────────────────────────────────────────────────────────┐    │
  │  │              aws_backup_selection  (for_each)                    │    │
  │  │                                                                  │    │
  │  │  ─ Tag-based (selection_tags / conditions)                       │    │
  │  │  ─ ARN-based (explicit resources list)                           │    │
  │  │  ─ IAM role assumed by AWS Backup service                        │    │
  │  └───────┬───────────────────────────────────────────────┬──────────┘    │
  └──────────┼───────────────────────────────────────────────┼───────────────┘
             │                                               │
             ▼                                               ▼
  ┌──────────────────────┐                     ┌─────────────────────────────┐
  │  Backed-up Resources │                     │   Recovery Points stored    │
  │  ─ EC2 instances     │    AWS Backup ──▶   │   in aws_backup_vault       │
  │  ─ RDS / Aurora      │                     │   (encrypted, WORM-locked,  │
  │  ─ S3 buckets        │                     │    or replicated to DR)     │
  │  ─ EBS volumes       │                     └─────────────────────────────┘
  │  ─ EFS file systems  │
  └──────────────────────┘
```

---

## Resources Created

| Resource | Description |
|----------|-------------|
| `aws_backup_vault` | Encrypted container that stores recovery points |
| `aws_backup_vault_policy` | IAM resource policy on a vault (optional; created only when `vault_policy` is set) |
| `aws_backup_vault_lock_configuration` | WORM lock enforcing min/max retention (optional; created only when `lock_configuration` is set) |
| `aws_backup_plan` | Schedule rules defining when backups run, retention lifecycle, and DR copy actions |
| `aws_backup_selection` | Associates AWS resources with a backup plan via ARN list or tag-based selection |

---

## Usage

### Simple daily backup with tag-based selection

```hcl
module "backup" {
  source = "../../modules/storage/aws_backup"

  region = "us-east-1"
  tags   = { environment = "production", team = "platform" }

  vaults = [
    {
      key  = "primary"
      name = "prod-primary-vault"
    }
  ]

  plans = [
    {
      key  = "daily"
      name = "prod-daily-plan"

      rules = [
        {
          name             = "daily-0500-utc"
          target_vault_key = "primary"
          schedule         = "cron(0 5 * * ? *)"

          lifecycle = {
            cold_storage_after = 30
            delete_after       = 35
          }
        }
      ]
    }
  ]

  selections = [
    {
      key          = "prod-tagged"
      name         = "prod-tagged-resources"
      plan_key     = "daily"
      iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"

      selection_tags = [
        {
          type  = "STRINGEQUALS"
          key   = "Environment"
          value = "production"
        }
      ]
    }
  ]
}
```

---

## Cross-Region DR Example

Use `copy_actions` to replicate recovery points to a vault in another region for disaster recovery.

```hcl
module "backup" {
  source = "../../modules/storage/aws_backup"
  region = "us-east-1"
  tags   = { environment = "production" }

  vaults = [
    {
      key  = "primary"
      name = "prod-primary-vault"
    }
  ]

  plans = [
    {
      key  = "daily-with-dr"
      name = "prod-daily-dr-plan"

      rules = [
        {
          name             = "daily-dr"
          target_vault_key = "primary"
          schedule         = "cron(0 5 * * ? *)"

          lifecycle = {
            cold_storage_after = 30
            delete_after       = 35
          }

          # Copy the recovery point to a vault in us-west-2.
          copy_actions = [
            {
              destination_vault_arn = "arn:aws:backup:us-west-2:123456789012:backup-vault:prod-dr-vault"

              lifecycle = {
                cold_storage_after = 30
                delete_after       = 35
              }
            }
          ]
        }
      ]
    }
  ]

  selections = [
    {
      key          = "prod-tagged"
      name         = "prod-tagged"
      plan_key     = "daily-with-dr"
      iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"

      selection_tags = [
        { type = "STRINGEQUALS", key = "Environment", value = "production" }
      ]
    }
  ]
}
```

---

## Vault Lock Example

Enable WORM protection to satisfy regulatory immutability requirements (e.g., HIPAA, PCI-DSS).

```hcl
module "backup" {
  source = "../../modules/storage/aws_backup"
  region = "us-east-1"
  tags   = { environment = "production", compliance = "hipaa" }

  vaults = [
    {
      key  = "compliance"
      name = "prod-compliance-vault"

      lock_configuration = {
        min_retention_days  = 365  # recovery points cannot be deleted sooner than 1 year
        max_retention_days  = 2555 # upper ceiling of 7 years
        changeable_for_days = 3    # 3-day grace period — set null to lock immediately
      }
    }
  ]

  plans = [
    {
      key  = "compliance-daily"
      name = "prod-compliance-daily-plan"

      rules = [
        {
          name             = "daily-0500-utc"
          target_vault_key = "compliance"
          schedule         = "cron(0 5 * * ? *)"

          lifecycle = {
            delete_after = 365
          }
        }
      ]
    }
  ]

  selections = [
    {
      key          = "compliance-tagged"
      name         = "compliance-tagged"
      plan_key     = "compliance-daily"
      iam_role_arn = "arn:aws:iam::123456789012:role/AWSBackupDefaultServiceRole"

      selection_tags = [
        { type = "STRINGEQUALS", key = "Compliance", value = "hipaa" }
      ]
    }
  ]
}
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region where Backup resources are deployed |

---

## Optional Variables

### Top-level

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all taggable resources |
| `vaults` | `list(object)` | `[]` | Backup vault definitions (see below) |
| `plans` | `list(object)` | `[]` | Backup plan definitions (see below) |
| `selections` | `list(object)` | `[]` | Backup selection definitions (see below) |

### `vaults` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Vault display name (must be unique per account/region) |
| `kms_key_id` | `string` | `null` | Customer-managed KMS key ARN; `null` uses the AWS-managed Backup key |
| `tags` | `map(string)` | `{}` | Additional tags for this vault |
| `vault_policy` | `string` | `null` | JSON IAM resource policy attached to the vault |
| `lock_configuration` | `object` | `null` | Vault Lock (WORM) settings; see nested fields below |

#### `vaults[*].lock_configuration` fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `min_retention_days` | `number` | required | Minimum days a recovery point must be retained |
| `max_retention_days` | `number` | `null` | Maximum days before a recovery point is auto-deleted; `null` means no ceiling |
| `changeable_for_days` | `number` | `null` | Grace period in days to modify the lock (1–7); `null` locks immediately |

### `plans` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Plan display name |
| `tags` | `map(string)` | `{}` | Additional tags for this plan |
| `rules` | `list(object)` | required | One or more backup schedule rules (see below) |

#### `plans[*].rules` fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | required | Rule name (unique within the plan) |
| `target_vault_key` | `string` | required | Key of the target vault from `vaults[*].key` |
| `schedule` | `string` | `null` | Cron or rate expression (e.g. `cron(0 5 * * ? *)`) |
| `start_window` | `number` | `60` | Minutes after schedule to start the job |
| `completion_window` | `number` | `180` | Minutes after start within which the job must complete |
| `enable_continuous_backup` | `bool` | `false` | Enable point-in-time restore (S3 only; incompatible with lifecycle) |
| `recovery_point_tags` | `map(string)` | `{}` | Tags applied to each recovery point |
| `lifecycle` | `object` | `null` | Transition and deletion settings (see below) |
| `copy_actions` | `list(object)` | `[]` | Cross-vault/cross-region copy targets (see below) |

#### `plans[*].rules[*].lifecycle` fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `cold_storage_after` | `number` | `null` | Days until transition to cold storage (min 90 for S3/EFS) |
| `delete_after` | `number` | `null` | Days until permanent deletion (must be ≥ `cold_storage_after` + 90 when set) |

#### `plans[*].rules[*].copy_actions` fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `destination_vault_arn` | `string` | required | ARN of the destination vault |
| `lifecycle` | `object` | `null` | Lifecycle for the copy (same fields as rule lifecycle) |

### `selections` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique for_each key |
| `name` | `string` | required | Selection display name |
| `plan_key` | `string` | required | Key of the associated backup plan from `plans[*].key` |
| `iam_role_arn` | `string` | required | IAM role ARN assumed by AWS Backup (needs Backup managed policies) |
| `resources` | `list(string)` | `[]` | Explicit resource ARNs to back up; empty = tag-based mode |
| `not_resources` | `list(string)` | `[]` | ARNs to exclude (tag-based mode only) |
| `selection_tags` | `list(object)` | `[]` | Legacy tag conditions (see below) |
| `conditions` | `object` | `null` | Advanced tag conditions (see below) |

#### `selections[*].selection_tags` fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | `string` | Operator: `STRINGEQUALS`, `STRINGLIKE`, `STRINGNOTEQUALS`, `STRINGNOTLIKE` |
| `key` | `string` | Tag key to evaluate |
| `value` | `string` | Tag value to match (wildcards supported for `LIKE` operators) |

#### `selections[*].conditions` fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `string_equals` | `list(object {key, value})` | `[]` | Include resources whose tag exactly equals key=value |
| `string_not_equals` | `list(object {key, value})` | `[]` | Include resources whose tag does not equal key=value |
| `string_like` | `list(object {key, value})` | `[]` | Include resources whose tag matches glob pattern |
| `string_not_like` | `list(object {key, value})` | `[]` | Include resources whose tag does not match glob pattern |

---

## Outputs

| Output | Description |
|--------|-------------|
| `vault_ids` | Map of vault key → Backup vault ID |
| `vault_arns` | Map of vault key → Backup vault ARN |
| `vault_names` | Map of vault key → Backup vault name |
| `plan_ids` | Map of plan key → Backup plan ID |
| `plan_arns` | Map of plan key → Backup plan ARN |
| `plan_versions` | Map of plan key → Backup plan version string |
| `selection_ids` | Map of selection key → Backup selection ID |

---

## Notes

- **IAM role requirement:** The `iam_role_arn` in each selection must have `AWSBackupServiceRolePolicyForBackup` and `AWSBackupServiceRolePolicyForRestores` attached. The pre-created `AWSBackupDefaultServiceRole` satisfies both requirements. Use a custom role to scope access to specific resources or KMS keys.
- **Tag-based vs ARN-based selection:** Leave `resources = []` and populate `selection_tags` or `conditions` for dynamic fleet-wide selection. Provide explicit ARNs in `resources` for precise control over individual resources.
- **Cold storage minimums:** S3 and EFS recovery points require at least **90 days** in cold storage before deletion (`delete_after` must be ≥ `cold_storage_after + 90`). No minimum applies to EC2, EBS, or RDS.
- **Continuous backup:** `enable_continuous_backup = true` enables point-in-time restore for S3. It is **incompatible with lifecycle rules** — do not set `lifecycle` on the same rule.
- **Vault lock grace period:** `changeable_for_days` (1–7) gives a window to remove or modify the lock before it becomes permanent. Setting `changeable_for_days = null` applies the lock immediately with **no grace period** — this cannot be undone.
- **Vault lock permanence:** Once the grace period expires, recovery points in a locked vault cannot be deleted before `min_retention_days`, even by the account root user. Test in a non-production vault before locking compliance vaults.

---

## See Also

- [Wrapper plan](../../../tf-plans/aws_backup/README.md)
- [Service overview](aws-backup.md)
- [AWS Backup documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html)
- [Terraform aws_backup_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)
- [Terraform aws_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan)
- [Terraform aws_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection)
- [Terraform aws_backup_vault_lock_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_lock_configuration)
