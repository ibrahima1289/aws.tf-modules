# AWS Secrets Manager Terraform Module

> **Service:** [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) &nbsp;|&nbsp; **Module path:** `modules/security_identity_compliance/aws_secrets_manager` &nbsp;|&nbsp; **Wrapper path:** `tf-plans/aws_secrets_manager` &nbsp;|&nbsp; **Pricing:** [aws.amazon.com/secrets-manager/pricing](https://aws.amazon.com/secrets-manager/pricing/)

This module creates and manages **AWS Secrets Manager** secrets with full support for static values, automatic rotation via Lambda, resource-based policies, and multi-region replication — all driven by a single `secrets` list variable.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       AWS Secrets Manager Module                        │
│                                                                         │
│  var.secrets (list)                                                     │
│       │                                                                 │
│       ▼                                                                 │
│  locals.secrets_map ──────────────────────────────────────────┐         │
│       │                           │                            │        │
│       ▼                           ▼                            ▼        │
│  aws_secretsmanager_secret    secrets_with_           secrets_with_     │
│  (always created)             string_map              rotation_map      │
│       │                           │                            │        │
│       │                           ▼                            ▼        │
│       │                  aws_secretsmanager_      aws_secretsmanager_   │
│       │                  secret_version           secret_rotation       │
│       │                  (static value)           (Lambda rotation)     │
│       │                                                                 │
│       │                  secrets_with_policy_map                        │
│       │                           │                                     │
│       │                           ▼                                     │
│       │                  aws_secretsmanager_                            │
│       │                  secret_policy                                  │
│       │                  (resource-based policy)                        │
│       │                                                                 │
│  Outputs: secret_ids · secret_arns · secret_names                       │
│           secret_version_ids · rotation_enabled_keys                    │
└─────────────────────────────────────────────────────────────────────────┘

  Downstream consumers (read secret value at runtime):
  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────────────┐
  │ EC2 / ECS  │  │   Lambda   │  │ CodePipeline│  │ Cross-account    │
  │ app code   │  │ functions  │  │ / CI-CD    │  │ via policy       │
  └────────────┘  └────────────┘  └────────────┘  └──────────────────┘
```

---

## Secret Resources Created

| Resource | Purpose | Conditional |
|---|---|---|
| [`aws_secretsmanager_secret`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | Secret container, metadata, KMS key, replication | Always |
| [`aws_secretsmanager_secret_version`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | Stores static string value | Only when `secret_string` provided |
| [`aws_secretsmanager_secret_rotation`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_rotation) | Configures Lambda-based rotation schedule | Only when `rotation_lambda_arn` provided |
| [`aws_secretsmanager_secret_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy) | Attaches resource-based IAM policy | Only when `policy` provided |

---

## Terraform & Provider Requirements

| Requirement | Version |
|---|---|
| Terraform | `>= 1.3` (required for `optional()` with defaults in object types) |
| AWS Provider | `>= 5.0` |
| AWS Region | Set via `var.region` |

---

## Input Variables

### Top-level variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region where secrets are created |
| `tags` | `map(string)` | No | `{}` | Global tags applied to all resources |
| `secrets` | `list(object)` | ✅ Yes | n/a | List of secret definitions — see object fields below |

### `secrets` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique identifier used as the `for_each` map key |
| `name` | `string` | ✅ Yes | n/a | Secrets Manager secret name — path-style recommended (e.g. `prod/app/db`) |
| `description` | `string` | No | `"Managed by Terraform"` | Human-readable description of the secret |
| `kms_key_id` | `string` | No | `null` | ARN of a CMK to encrypt the secret. Defaults to AWS-managed key when omitted |
| `recovery_window_in_days` | `number` | No | `30` | `0` = force-delete immediately; `7`–`30` = scheduled deletion window |
| `secret_string` | `string` | No | `null` | Plain-text or JSON string value. Omit when rotation manages the value |
| `rotation_lambda_arn` | `string` | No | `null` | ARN of a Secrets Manager-compatible rotation Lambda |
| `rotation_days` | `number` | No | `30` | How often (in days) rotation is triggered (`1`–`365`) |
| `policy` | `string` | No | `null` | JSON resource-based policy for cross-account or service-level access control |
| `replica_regions` | `list(object)` | No | `null` | List of `{ region, kms_key_id }` objects for multi-region replication |
| `tags` | `map(string)` | No | `{}` | Per-secret tags merged with global `tags` and `created_date` |

#### `replica_regions` sub-object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | Target AWS region for the replica |
| `kms_key_id` | `string` | No | `null` | CMK ARN in the replica region. Defaults to AWS-managed key when omitted |

---

## Outputs

| Output | Description |
|--------|-------------|
| `secret_ids` | Map of secret key → Secrets Manager secret ID |
| `secret_arns` | Map of secret key → secret ARN *(sensitive)* |
| `secret_names` | Map of secret key → secret name (path) |
| `secret_version_ids` | Map of secret key → current version ID (only for static-value secrets) |
| `rotation_enabled_keys` | Sorted list of keys that have automatic rotation configured |

---

## Rotation Notes

| Behaviour | Details |
|---|---|
| **Static value** (`secret_string` set) | Terraform writes the value once. The `lifecycle { ignore_changes }` block prevents Terraform from overwriting future rotations. |
| **Rotation-only** (no `secret_string`) | Secret container is created with no initial value. The rotation Lambda is responsible for populating and rotating the value. |
| **rotation_days** | Maps to `automatically_after_days` in `aws_secretsmanager_secret_rotation.rotation_rules`. |
| **Supported rotation targets** | RDS, Aurora, Redshift, DocumentDB, and custom services via custom Lambda functions. |

---

## Tags

All secrets include `created_date` (YYYY-MM-DD) sourced from `local.created_date`, merged with global `var.tags` and any per-secret `tags`.

---

## Usage

```hcl
module "secrets_manager" {
  source = "../../modules/security_identity_compliance/aws_secrets_manager"
  region = var.region
  tags   = { Environment = "prod" }

  secrets = [
    {
      # RDS credentials — rotation Lambda manages the value; no secret_string here.
      key                     = "db-credentials"
      name                    = "prod/rds/db-credentials"
      description             = "RDS master credentials rotated every 30 days"
      kms_key_id              = "arn:aws:kms:ca-central-1:123456789012:key/mrk-abc123"
      recovery_window_in_days = 7
      rotation_lambda_arn     = "arn:aws:lambda:ca-central-1:123456789012:function:rotate-rds-secret"
      rotation_days           = 30
      tags                    = { Team = "platform" }
    },
    {
      # Static API key — Terraform writes the value once, lifecycle prevents drift overwrites.
      key           = "api-key"
      name          = "prod/integrations/payment-api-key"
      secret_string = "sk_live_REPLACE_ME"
      tags          = { Team = "payments" }
    },
    {
      # JSON config secret with cross-account read policy.
      key           = "app-config"
      name          = "prod/app/config"
      secret_string = jsonencode({ db_host = "db.example.com", db_port = 5432 })
      policy        = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect    = "Allow"
          Principal = { AWS = "arn:aws:iam::987654321098:root" }
          Action    = ["secretsmanager:GetSecretValue"]
          Resource  = "*"
        }]
      })
    },
    {
      # Multi-region secret replicated to us-east-1 for DR.
      key     = "jwt-signing-key"
      name    = "prod/auth/jwt-signing-key"
      replica_regions = [
        { region = "us-east-1", kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/mrk-ghi789" }
      ]
    }
  ]
}
```

---

## Consuming Secrets at Runtime

Secrets should **never** be read back as Terraform outputs in production. Instead, retrieve them at runtime:

**AWS SDK / CLI:**
```bash
aws secretsmanager get-secret-value \
  --secret-id prod/rds/db-credentials \
  --query SecretString --output text
```

**ECS Task Definition (inject as environment variable):**
```hcl
secrets = [
  {
    name      = "DB_PASSWORD"
    valueFrom = module.secrets_manager.secret_arns["db-credentials"]
  }
]
```

**Lambda environment variable:**
```hcl
environment {
  variables = {
    SECRET_ARN = module.secrets_manager.secret_arns["api-key"]
  }
}
```

**IAM permission required on the consuming role:**
```json
{
  "Effect": "Allow",
  "Action": ["secretsmanager:GetSecretValue"],
  "Resource": "<secret-arn>"
}
```
