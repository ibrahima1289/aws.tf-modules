# AWS Organizations Terraform Module

Creates and manages [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) with support for multiple OUs, multiple member accounts, multiple policies, and policy attachments.

## Architecture

```text
Management Account
        |
        v
+-------------------------------+
| AWS Organization              |
|  - Root                       |
|  - Service access + policies  |
+-------------------------------+
        |
        +-------------------------------+
        |                               |
        v                               v
+--------------------+         +--------------------+
| Organizational Unit|         | Organizational Unit|
| (e.g., security)   |         | (e.g., workloads)  |
+--------------------+         +--------------------+
        |                               |
        v                               v
+--------------------+         +--------------------+
| Member Accounts    |         | Member Accounts    |
| (dev/test/prod)    |         | (shared/platform)  |
+--------------------+         +--------------------+

Policies (SCP/Tag/Backup/AI opt-out) can be attached to ROOT, OU, or ACCOUNT.
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region used by provider |

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_organization` | `bool` | `false` | Create org (`true`) or use existing org (`false`) |
| `organization` | `object` | `{}` | Organization settings (`feature_set`, service access, policy types) |
| `tags` | `map(string)` | `{}` | Common tags for all taggable resources |
| `organizational_units` | `list(object)` | `[]` | Multiple OUs to create (`key`, `name`, `parent_key`, `tags`) |
| `accounts` | `list(object)` | `[]` | Multiple member accounts (`key`, `name`, `email`, `parent_key`, etc.) |
| `policies` | `list(object)` | `[]` | Multiple policies (`key`, `name`, `type`, `content`, `tags`) |
| `policy_attachments` | `list(object)` | `[]` | Policy attachments to ROOT, OU, or ACCOUNT |

## Outputs

| Name | Description |
|------|-------------|
| `organization_id` | Organization ID |
| `root_id` | Root ID |
| `organizational_unit_ids` | Map of OU key to OU ID |
| `account_ids` | Map of account key to account ID |
| `account_arns` | Map of account key to account ARN |
| `policy_ids` | Map of policy key to policy ID |

## Usage

```hcl
module "organizations" {
  source = "../modules/management_and_governance/aws_organizations"

  region              = "us-east-1"
  create_organization = false

  tags = {
    environment = "platform"
    owner       = "cloud-team"
  }

  organizational_units = [
    { key = "security", name = "Security", parent_key = "ROOT" },
    { key = "workloads", name = "Workloads", parent_key = "ROOT" },
    { key = "prod", name = "Production", parent_key = "workloads" }
  ]

  accounts = [
    { key = "shared", name = "SharedServices", email = "aws-shared@example.com", parent_key = "security" },
    { key = "prod-app", name = "ProdApplications", email = "aws-prod@example.com", parent_key = "prod" }
  ]

  policies = [
    {
      key     = "deny-leave-org"
      name    = "DenyLeaveOrg"
      type    = "SERVICE_CONTROL_POLICY"
      content = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Sid      = "DenyLeaveOrganization"
          Effect   = "Deny"
          Action   = "organizations:LeaveOrganization"
          Resource = "*"
        }]
      })
    }
  ]

  policy_attachments = [
    { key = "attach-root", policy_key = "deny-leave-org", target_type = "ROOT", target_key = "" }
  ]
}
```

## Notes

- This module is intended for use in the AWS Organizations management account.
- `create_organization` defaults to `false` for safer adoption in existing environments.
- Account creation is asynchronous in AWS; account IDs may take time to become active for downstream automation.
