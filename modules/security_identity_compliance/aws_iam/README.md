# Terraform AWS IAM Module

This module creates multiple AWS IAM users, groups, policies, attaches policies to groups, adds users to groups, and can optionally create access keys and console access for users.

## Usage

```hcl
module "iam" {
  source = "../modules/security_identity_compliance/aws_iam"

  users = [
    {
      name              = "example-user"
      path              = "/"
      force_destroy     = false
      permissions_boundary = null
      tags              = { Owner = "team" }
      create_access_key = true
      access_key_pgp_key = null
      access_key_status = "Active"
      access_key_description = "Access key for example-user"
      console_access   = true
      console_password_length = 16
      console_password_reset_required = true
      console_pgp_key  = null
    },
    # Add more users as needed
  ]

  groups = [
    { name = "example-group" },
    # Add more groups as needed
  ]

  user_group_memberships = [
    { user = "example-user", groups = ["example-group"] },
    # Add more memberships as needed
  ]

  policies = [
    {
      name        = "example-policy"
      path        = "/"
      description = "Example policy for demonstration."
      policy_json = file("./example-policy.json")
    },
    # Add more policies as needed
  ]

  group_policy_attachments = [
    { group = "example-group", policy = "example-policy" },
    # Add more attachments as needed
  ]

  tags = {
    Environment = "dev"
  }
}
```

## Required Variables
- `users`: List of user objects (each must have `name`)
- `groups`: List of group objects (each must have `name`)
- `user_group_memberships`: List of user-group membership objects
- `policies`: List of policy objects (each must have `name` and `policy_json`)
- `group_policy_attachments`: List of group-policy attachment objects

## Optional User/Group/Policy Fields
- `path` (string, default: "/")
- `force_destroy` (bool, default: false)
- `permissions_boundary` (string, default: null)
- `tags` (map(string), default: `{}`)
- `create_access_key` (bool, default: false)
- `access_key_pgp_key` (string, default: null)
- `access_key_status` (string, default: "Active")
- `access_key_description` (string, default: "User access key"): Description for the access key
- `console_access` (bool, default: false): Whether to enable AWS Console access for the user
- `console_password_length` (number, default: 16): Length of the generated console password
- `console_password_reset_required` (bool, default: true): Require password reset on first login
- `console_pgp_key` (string, default: null): PGP key to encrypt the console password
- `description` (string, default: "")

## Outputs
- `user_names`: List of created IAM user names
- `group_names`: List of created IAM group names
- `policy_arns`: List of created IAM policy ARNs
- `access_key_ids`: Map of user name to access key ID (if created)
- `access_key_secrets`: Map of user name to secret access key (if created, encrypted if pgp_key is set)
- `console_passwords`: Map of user name to encrypted console password (if console access is enabled and pgp_key is set)

## Example Policy JSON

Save as `example-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListAllMyBuckets",
      "Resource": "*"
    }
  ]
}
```

## License

This module is licensed under the MIT License. See the LICENSE file for more information.
