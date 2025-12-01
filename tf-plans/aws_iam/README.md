# AWS IAM Terraform Module

This module creates and manages AWS IAM resources.

## Features

- Creates IAM users, groups, and policies.
- Stores access keys and secrets in AWS Secrets Manager.

## Usage

```hcl
module "iam" {
  source = "terraform-aws-modules/iam/aws"

  # Add your configuration here
}
```

## Access Keys and Secrets Storage

Access keys and secrets for IAM users are securely stored in AWS Secrets Manager. This ensures that sensitive information is managed and accessed securely.

## License

This project is licensed under the MIT License. See the LICENSE file for details.