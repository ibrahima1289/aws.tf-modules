# AWS IAM Terraform Module

This module creates and manages AWS IAM resources.

## Features

- Creates IAM users, groups, and policies.
- Stores access keys and secrets in AWS Secrets Manager.

## Usage

```hcl
module "iam" {
  source = "../../modules/security_identity_compliance/aws_iam"

  region                   = var.region
  users                    = var.users
  groups                   = var.groups
  user_group_memberships   = var.user_group_memberships
  policies                 = var.policies
  group_policy_attachments = var.group_policy_attachments
  tags                     = var.tags
}
```

## Access Keys and Secrets Storage

Access keys and secrets for IAM users can be stored securely in AWS Secrets Manager if your policies and provisioning flow implement it; this wrapper does not store them by default.

## License

This project is licensed under the MIT License. See the LICENSE file for details.