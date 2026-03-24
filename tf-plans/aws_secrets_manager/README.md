# AWS Secrets Manager — Terraform Wrapper

> **Module:** [aws_secrets_manager](../../modules/security_identity_compliance/aws_secrets_manager/README.md) &nbsp;|&nbsp; **Service Docs:** [aws-secrets-manager.md](../../modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) &nbsp;|&nbsp; **Pricing:** [aws.amazon.com/secrets-manager/pricing](https://aws.amazon.com/secrets-manager/pricing/)

Wrapper plan for the `aws_secrets_manager` root module. Demonstrates creating multiple secret types (rotated credentials, static API keys, JSON config bundles, multi-region replicas) with a single `terraform apply`.

---

## Architecture

```
terraform.tfvars  ──►  wrapper main.tf  ──►  module "secrets_manager"
                                                     │
                               ┌─────────────────────┼───────────────────┐
                               ▼                     ▼                   ▼
                   aws_secretsmanager_  aws_secretsmanager_ aws_secretsmanager_
                   secret              secret_version      secret_rotation
                   (all secrets)       (static values)     (rotation schedule)
                               │
                               ▼
                   aws_secretsmanager_secret_policy
                   (cross-account / service policy)
```

---

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Calls the root module, passes region, merged tags, and secrets list |
| `variables.tf` | Mirrors the root module's variable types |
| `locals.tf` | Computes `created_date` for wrapper-level tag injection |
| `provider.tf` | AWS provider + Terraform version constraints |
| `outputs.tf` | Passes all 5 module outputs through |
| `terraform.tfvars` | Example values for 4 secret patterns |

---

## Usage

```bash
cd tf-plans/aws_secrets_manager
terraform init
terraform plan
terraform apply
```

---

## Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region where secrets are created |
| `tags` | `map(string)` | No | `{}` | Global tags applied to all resources |
| `secrets` | `list(object)` | ✅ Yes | n/a | List of secret definitions — see fields below |

### `secrets` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique `for_each` map key |
| `name` | `string` | ✅ Yes | n/a | Secret name / path (e.g. `prod/app/db`) |
| `description` | `string` | No | `"Managed by Terraform"` | Human-readable description |
| `kms_key_id` | `string` | No | `null` | CMK ARN — defaults to AWS-managed key |
| `recovery_window_in_days` | `number` | No | `30` | `0` = force delete; `7`–`30` = scheduled |
| `secret_string` | `string` | No | `null` | Plain text or JSON value. Omit for rotated secrets |
| `rotation_lambda_arn` | `string` | No | `null` | Rotation Lambda ARN |
| `rotation_days` | `number` | No | `30` | Rotation frequency in days (`1`–`365`) |
| `policy` | `string` | No | `null` | JSON resource-based policy |
| `replica_regions` | `list(object)` | No | `null` | Multi-region replica config `{ region, kms_key_id }` |
| `tags` | `map(string)` | No | `{}` | Per-secret tags |

---

## Outputs

| Output | Description |
|--------|-------------|
| `secret_ids` | Map of key → secret ID |
| `secret_arns` | Map of key → secret ARN *(sensitive)* |
| `secret_names` | Map of key → secret name/path |
| `secret_version_ids` | Map of key → version ID (static-value secrets only) |
| `rotation_enabled_keys` | Sorted list of keys with rotation configured |

---

## Secret Patterns in `terraform.tfvars`

| Key | Pattern | KMS | Rotation | Policy | Multi-region |
|-----|---------|-----|----------|--------|--------------|
| `db-credentials` | RDS credentials | ✅ CMK | ✅ 30 days | — | — |
| `payment-api-key` | Static API key | — | — | — | — |
| `app-config` | JSON config bundle | — | — | ✅ cross-account | — |
| `jwt-signing-key` | Auth signing key | ✅ CMK | — | — | ✅ us-east-1 |
