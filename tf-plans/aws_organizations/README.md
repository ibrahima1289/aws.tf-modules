# AWS Organizations Wrapper (tf-plans)

This wrapper deploys the [AWS Organizations module](../../modules/management_and_governance/aws_organizations/README.md) with scalable inputs for multiple OUs, accounts, policies, and attachments.

## Architecture

```text
tf-plans/aws_organizations
        |
        v
modules/management_and_governance/aws_organizations
        |
        +--> Organization (optional create)
        +--> Organizational Units (many)
        +--> Accounts (many)
        +--> Policies (many)
        +--> Policy Attachments (many)
```

## Quick Start

```bash
terraform init -upgrade
terraform validate
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region used by provider |

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_organization` | `bool` | `false` | Set true only for first-time organization bootstrap |
| `organization` | `object` | `{}` | Feature set, service access principals, and enabled policy types |
| `tags` | `map(string)` | `{}` | Common tags merged with wrapper `created_date` |
| `organizational_units` | `list(object)` | `[]` | Multiple OUs (`key`, `name`, `parent_key`, `tags`) |
| `accounts` | `list(object)` | `[]` | Multiple accounts (`key`, `name`, `email`, `parent_key`, etc.) |
| `policies` | `list(object)` | `[]` | Multiple organizations policies |
| `policy_attachments` | `list(object)` | `[]` | Policy attachment targets (`ROOT`, `OU`, `ACCOUNT`) |

## Outputs

| Name | Description |
|------|-------------|
| `organization_id` | Organization ID |
| `root_id` | Root ID |
| `organizational_unit_ids` | Map of OU key to OU ID |
| `account_ids` | Map of account key to account ID |
| `account_arns` | Map of account key to account ARN |
| `policy_ids` | Map of policy key to policy ID |

## Notes

- Use valid, reachable mailbox addresses for each account email.
- Account creation is asynchronous; downstream provisioning should wait until account setup completes.
- Keep `create_organization = false` for existing organizations to avoid accidental bootstrap attempts.
