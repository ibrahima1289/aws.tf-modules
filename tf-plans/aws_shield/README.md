# tf-plans/aws\_shield

Terraform wrapper for the [AWS Shield Advanced module](../../modules/security_identity_compliance/aws_shield/README.md).  
Deploy DDoS protections, protection groups, DRT access, and proactive engagement in one plan.

---

## Architecture

```
tf-plans/aws_shield/
├── provider.tf        ← Terraform + AWS provider constraints
├── variables.tf       ← Input declarations (mirrors module types)
├── locals.tf          ← created_date tag
├── main.tf            ← Module call
├── outputs.tf         ← Pass-through of module outputs
├── terraform.tfvars   ← Example values (ALB, CloudFront, EIP)
└── README.md          ← This file

modules/security_identity_compliance/aws_shield/
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf            ← aws_shield_subscription, _protection, _protection_group,
│                         _drt_access_role_arn_association, _drt_access_log_bucket_association,
│                         _proactive_engagement
└── outputs.tf
```

---

## Files

| File | Purpose |
|------|---------|
| `provider.tf` | Terraform `>= 1.3` + AWS `>= 5.0` constraints, `provider "aws"` |
| `variables.tf` | Input variable declarations |
| `locals.tf` | `created_date` tag (`formatdate`) |
| `main.tf` | Calls `aws_shield` module |
| `outputs.tf` | Exposes `protection_ids`, `protection_arns`, `protection_group_ids`, `subscription_id` |
| `terraform.tfvars` | Worked example — ALB, CloudFront, EIP protections + ALL/ARBITRARY groups |

---

## Usage

```bash
cd tf-plans/aws_shield

# Review the plan — subscription is disabled by default
terraform init
terraform plan

# Enable the subscription ONLY when ready for $3,000/month commitment
# Set enable_subscription = true in terraform.tfvars, then:
terraform apply
```

> **Cost Warning**: `enable_subscription = true` activates a **$3,000/month** Shield Advanced
> subscription (billed annually). Ensure budget approval before applying.

---

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `region` | `string` | — | AWS provider region. Use `us-east-1` for CloudFront/Route 53 resources |
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `enable_subscription` | `bool` | `false` | Manage Shield Advanced subscription — **$3,000/month** |
| `subscription_auto_renew` | `string` | `"ENABLED"` | `ENABLED` or `DISABLED` |
| `protections` | `list(object)` | `[]` | Shield protection definitions — see object fields below |
| `protection_groups` | `list(object)` | `[]` | Protection group definitions — see object fields below |
| `drt_role_arn` | `string` | `null` | IAM role ARN for DRT — must trust `shield.amazonaws.com` |
| `drt_log_buckets` | `list(string)` | `[]` | S3 buckets the DRT can read for attack log analysis |
| `proactive_engagement_enabled` | `bool` | `false` | Enable proactive engagement by DRT on attack detection |
| `emergency_contacts` | `list(object)` | `[]` | Contact list for proactive engagement |

### `protections` object fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `key` | `string` | ✅ | Unique key; used in `protection_groups[].member_keys` |
| `name` | `string` | ✅ | Display name for the protection |
| `resource_arn` | `string` | ✅ | Full ARN of the resource to protect |
| `tags` | `map(string)` | — | Tags specific to this protection |

### `protection_groups` object fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `key` | `string` | ✅ | Unique key used as `for_each` index |
| `protection_group_id` | `string` | ✅ | ID for the protection group |
| `aggregation` | `string` | ✅ | `SUM`, `MEAN`, or `MAX` |
| `pattern` | `string` | ✅ | `ALL`, `BY_RESOURCE_TYPE`, or `ARBITRARY` |
| `resource_type` | `string` | — | Required when `pattern = "BY_RESOURCE_TYPE"` |
| `member_keys` | `list(string)` | — | Protection keys — required when `pattern = "ARBITRARY"` |
| `tags` | `map(string)` | — | Tags specific to this group |

### `emergency_contacts` object fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email_address` | `string` | ✅ | Contact email (must be verified) |
| `phone_number` | `string` | — | E.164 format, e.g. `+15551234567` |
| `contact_notes` | `string` | — | Escalation instructions for DRT |

---

## Outputs

| Name | Description |
|------|-------------|
| `protection_ids` | Map of protection key → Shield protection ID |
| `protection_arns` | Map of protection key → Shield protection ARN |
| `protection_group_ids` | Map of group key → protection group ID |
| `subscription_id` | Shield Advanced subscription ID (empty when `enable_subscription = false`) |

---

## Protection Group Pattern Summary

| Pattern | `resource_type` | `member_keys` | Coverage |
|---------|----------------|---------------|----------|
| `ALL` | not set | not set | Every Shield-protected resource in the account |
| `BY_RESOURCE_TYPE` | Required | not set | All protected resources of a specific type |
| `ARBITRARY` | not set | Required | Explicitly listed protection keys only |

---

## Notes

- **Global service**: Shield Advanced resources are global. The `region` variable controls only the
  provider endpoint; protections apply account-wide.
- **ARBITRARY member resolution**: `member_keys` values reference `protections[].key` fields.
  Terraform resolves them to ARNs at plan time — no hardcoded ARNs needed.
- **DRT prerequisites**: `drt_log_buckets` require `drt_role_arn` to be set first. The module
  enforces this via `depends_on`.
- **Proactive engagement**: Requires `emergency_contacts` to be non-empty and DRT role to be
  associated. Set `proactive_engagement_enabled = true` only after both are configured.
