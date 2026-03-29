# AWS Backup — Wrapper Plan

Terraform wrapper for the [`aws_backup` module](../../modules/storage/aws_backup/README.md) — configure vaults, backup plans, and resource selections via `terraform.tfvars`.

> See [aws-backup.md](../../modules/storage/aws_backup/aws-backup.md) for a full service reference, supported resource types, and pricing model.

---

## Architecture

```
  terraform.tfvars
        │
        ▼
  tf-plans/aws_backup/
  ┌──────────────────────────────────────────────────────────────────────────┐
  │  main.tf  →  module "backup"                                             │
  │                                                                          │
  │  Pattern 1: Daily/weekly production backup                               │
  │  ─ vault: "primary" (AWS-managed KMS key)                                │
  │  ─ plan:  daily cron(0 5 * * ?) + weekly cron(0 5 ? * 1 *)               │
  │  ─ selection: tag Environment=production                                 │
  │                                                                          │
  │  Pattern 2 (commented): Cross-region DR copy                             │
  │  ─ vault: "dr-west" in us-west-2                                         │
  │  ─ plan:  daily rule with copy_action → dr vault ARN                     │
  │                                                                          │
  │  Pattern 3 (commented): Vault Lock / WORM compliance                     │
  │  ─ vault: "compliance" with lock_configuration                           │
  │  ─ min_retention_days=365, changeable_for_days=3                         │
  └──────────────────────────────────────────────────────────────────────────┘
        │
        ▼
  modules/storage/aws_backup/
  ┌────────────────────┐    ┌────────────────────┐     ┌──────────────────────┐
  │  aws_backup_vault  │◀──│  aws_backup_plan    │──▶ │ aws_backup_selection │
  │  (+ policy)        │    │  rules + lifecycle │     │ tag-based / ARN      │
  │  (+ vault lock)    │    │  + copy_actions    │     └──────────────────────┘
  └────────────────────┘    └────────────────────┘
```

---

## Configuration Patterns

### Pattern 1 — Daily/weekly production backup (active)

| Setting | Value |
|---------|-------|
| Vault | `prod-primary-vault` (AWS-managed KMS) |
| Rule 1 | Daily `cron(0 5 * * ? *)`, cold after 30 days, delete after 35 days |
| Rule 2 | Weekly Sunday `cron(0 5 ? * 1 *)`, cold after 30 days, delete after 365 days |
| Selection | Tag `Environment=production` (STRINGEQUALS) |
| IAM role | `AWSBackupDefaultServiceRole` (replace account ID) |

### Pattern 2 — Cross-region DR copy (commented out)

| Setting | Value |
|---------|-------|
| DR vault | `prod-dr-vault-usw2` in `us-west-2` |
| Copy action | `destination_vault_arn` = DR vault ARN |
| DR lifecycle | cold after 30 days, delete after 35 days |

### Pattern 3 — Vault Lock compliance (commented out)

| Setting | Value |
|---------|-------|
| Vault | `prod-compliance-vault` |
| `min_retention_days` | `365` (1-year WORM floor) |
| `max_retention_days` | `2555` (7-year ceiling) |
| `changeable_for_days` | `3` (grace period) |

---

## Usage

```bash
# Initialise providers and modules.
terraform init

# Preview the resources that will be created.
terraform plan -var-file=terraform.tfvars

# Create the resources.
terraform apply -var-file=terraform.tfvars
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region where resources are deployed (default: `us-east-1`) |

---

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all resources |
| `vaults` | `list(object)` | `[]` | Backup vault definitions |
| `plans` | `list(object)` | `[]` | Backup plan definitions |
| `selections` | `list(object)` | `[]` | Backup selection definitions |

See [module variables.tf](../../modules/storage/aws_backup/variables.tf) for complete nested object field reference.

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

## Tips

- **IAM role:** Replace the placeholder `123456789012` account ID in `iam_role_arn` with your AWS account ID before applying. The `AWSBackupDefaultServiceRole` is created automatically when you first visit the AWS Backup console, or you can create it via IAM.
- **Tag-based selection:** Leave `resources = []` and set `selection_tags` to dynamically back up any resource with a matching tag. This is the preferred approach for large or auto-scaling fleets.
- **Cold storage minimums:** For S3 and EFS, `cold_storage_after` must be at least 90 days and `delete_after` must be at least `cold_storage_after + 90`. EC2, EBS, and RDS have no minimum.
- **Vault Lock:** Test `lock_configuration` in a non-production vault first. Once `changeable_for_days` expires the lock is permanent and cannot be removed, even by AWS Support.
- **Cross-region DR:** The destination vault must exist in the target region before the plan is applied. Deploy a separate wrapper plan in the DR region to create the DR vault, then reference its ARN in `copy_actions`.

---

## File Structure

```
tf-plans/aws_backup/
├── provider.tf       # Terraform and AWS provider version constraints
├── locals.tf         # created_date timestamp local
├── variables.tf      # Mirror of module variables (simplified descriptions)
├── main.tf           # Calls module "backup"
├── outputs.tf        # Exposes all module outputs
├── terraform.tfvars  # Active configuration (3 commented patterns)
└── README.md         # This file
```

---

## See Also

- [Module README](../../modules/storage/aws_backup/README.md)
- [Service overview](../../modules/storage/aws_backup/aws-backup.md)
- [AWS Backup documentation](https://docs.aws.amazon.com/aws-backup/latest/devguide/whatisbackup.html)
- [Terraform aws_backup_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)
- [Terraform aws_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan)
- [Terraform aws_backup_selection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection)
