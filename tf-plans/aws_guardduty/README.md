# AWS GuardDuty — Wrapper Plan

Example Terraform wrapper demonstrating how to call the [GuardDuty module](../../modules/security_identity_compliance/aws_guardDuty/README.md) with realistic production patterns.

---

## Architecture

```
  terraform.tfvars
        │
        ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                   tf-plans/aws_guardduty                            │
  │   provider.tf · variables.tf · locals.tf · main.tf · outputs.tf     │
  └──────────────────────────┬──────────────────────────────────────────┘
                             │  module "guardduty"
                             ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │          modules/security_identity_compliance/aws_guardDuty         │
  │                                                                     │
  │  aws_guardduty_detector          (1 per account/region)             │
  │  aws_guardduty_detector_feature  (S3 / EKS / Malware — opt-in)      │
  │  aws_guardduty_filter            (suppression rules, ARCHIVE/NOOP)  │
  │  aws_guardduty_ipset             (trusted corporate IPs)            │
  │  aws_guardduty_threatintelset    (custom threat feeds)              │
  │  aws_guardduty_publishing_dest   (S3 findings export)               │
  │  aws_guardduty_member            (member account invitations)       │
  └─────────────────────────────────────────────────────────────────────┘
```

---

## Configuration Patterns

### Pattern 1 — Production Detector (active in terraform.tfvars)

| Parameter | Value |
|-----------|-------|
| `key` | `prod` |
| `enable` | `true` |
| `finding_publishing_frequency` | `FIFTEEN_MINUTES` |
| `enable_s3_logs` | `true` |
| `enable_kubernetes` | `false` (enable if EKS present) |
| `enable_malware_protection` | `false` (enable for EC2 malware scanning) |

### Pattern 2 — Suppression Filter (active in terraform.tfvars)

| Parameter | Value |
|-----------|-------|
| `name` | `suppress-low-port-probe` |
| `action` | `ARCHIVE` |
| `rank` | `1` |
| Criteria | `type == Recon:EC2/PortProbeUnprotectedPort` AND `severity ≤ 2` |

### Pattern 3 — Trusted IP Set (commented out — requires S3 file)

| Parameter | Value |
|-----------|-------|
| `name` | `corporate-trusted-ips` |
| `format` | `TXT` (one CIDR or IP per line) |
| `location` | `s3://my-security-bucket/guardduty/trusted-ips.txt` |
| `activate` | `true` |

### Pattern 4 — Findings Publishing (commented out — requires S3 + KMS setup)

| Parameter | Value |
|-----------|-------|
| `destination_type` | `S3` |
| `destination_arn` | S3 bucket ARN with GuardDuty bucket policy |
| `kms_key_arn` | KMS key ARN with GuardDuty key policy |

### Pattern 5 — Member Account Invitations (commented out)

| Parameter | Value |
|-----------|-------|
| `account_id` | Member AWS account ID |
| `email` | Root email address of the member account |
| `invite` | `true` |

---

## Prerequisites

### Publishing Destination (S3)
The destination S3 bucket requires the following bucket policy statement before applying:
```json
{
  "Sid": "GuardDutyExport",
  "Effect": "Allow",
  "Principal": { "Service": "guardduty.amazonaws.com" },
  "Action": ["s3:GetBucketLocation", "s3:PutObject"],
  "Resource": [
    "arn:aws:s3:::my-guardduty-findings-bucket",
    "arn:aws:s3:::my-guardduty-findings-bucket/*"
  ]
}
```

The KMS key policy must also grant GuardDuty:
```json
{
  "Sid": "GuardDutyEncrypt",
  "Effect": "Allow",
  "Principal": { "Service": "guardduty.amazonaws.com" },
  "Action": ["kms:GenerateDataKey", "kms:Decrypt"],
  "Resource": "*"
}
```

---

## Usage

```bash
cd tf-plans/aws_guardduty

# Download provider and module
terraform init

# Preview changes
terraform plan

# Apply (creates GuardDuty detector and configured resources)
terraform apply

# View detector ID and ARN
terraform output detector_ids
terraform output detector_arns

# Tear down
terraform destroy
```

---

## File Structure

```
tf-plans/aws_guardduty/
├── provider.tf         # Terraform and AWS provider version constraints
├── variables.tf        # Input variable declarations (mirror module variables)
├── locals.tf           # created_date timestamp for tags
├── main.tf             # module "guardduty" call
├── outputs.tf          # Forwards all module outputs
├── terraform.tfvars    # Example variable values
└── README.md           # This file
```

---

## See Also

- [Module documentation](../../modules/security_identity_compliance/aws_guardDuty/README.md)
- [Service overview](../../modules/security_identity_compliance/aws_guardDuty/aws-guardduty.md)
- [AWS GuardDuty documentation](https://docs.aws.amazon.com/guardduty/latest/ug/)
- [GuardDuty Pricing](https://aws.amazon.com/guardduty/pricing/)
