# AWS GuardDuty Module

Reusable Terraform module for [Amazon GuardDuty](https://docs.aws.amazon.com/guardduty/latest/ug/what-is-guardduty.html) — intelligent, continuous threat detection for your AWS accounts and workloads.

> See [aws-guardduty.md](aws-guardduty.md) for a full service reference, finding types, and integration patterns.

---

## Architecture

```
  ┌──────────────────────────────────────────────────────────────────────────┐
  │                        AWS GuardDuty Module                              │
  │                                                                          │
  │  ┌────────────────────────────────────────────────────────────────────┐  │
  │  │            aws_guardduty_detector  (for_each)                      │  │
  │  │                                                                    │  │
  │  │  Always-on data sources:                                           │  │
  │  │  ─ CloudTrail management events  (API call monitoring)             │  │
  │  │  ─ VPC Flow Logs                 (network traffic analysis)        │  │
  │  │  ─ DNS Query Logs                (domain resolution monitoring)    │  │
  │  │                                                                    │  │
  │  │  Opt-in features (aws_guardduty_detector_feature):                 │  │
  │  │  ─ S3_DATA_EVENTS          (object-level S3 API monitoring)        │  │
  │  │  ─ EKS_AUDIT_LOGS          (Kubernetes control-plane threats)      │  │
  │  │  ─ EBS_MALWARE_PROTECTION  (EC2 EBS volume malware scanning)       │  │
  │  │                                                                    │  │
  │  │  Findings ──────────────────────────────────► Amazon EventBridge   │  │
  │  └────────┬───────────────────────────────────────────────────────────┘  │
  │           │                                                              │
  │     ┌─────┼────────────────────────────────────────┐                     │
  │     ▼     ▼                                        ▼                     │
  │  ┌──────────────────┐  ┌────────────────┐  ┌────────────────────────┐    │
  │  │aws_guardduty_    │  │aws_guardduty_  │  │aws_guardduty_          │    │
  │  │filter            │  │ipset           │  │threatintelset          │    │
  │  │─ NOOP / ARCHIVE  │  │─ trusted IPs   │  │─ known malicious IPs   │    │
  │  │─ ranked criteria │  │─ S3-hosted TXT │  │─ S3-hosted feed        │    │
  │  └──────────────────┘  └────────────────┘  └────────────────────────┘    │
  │           │                                                              │
  │     ┌─────┴──────────────────────────────────────┐                       │
  │     ▼                                            ▼                       │
  │  ┌──────────────────────────────┐  ┌──────────────────────────────────┐  │
  │  │aws_guardduty_publishing_     │  │aws_guardduty_member              │  │
  │  │destination                   │  │─ invite member accounts          │  │
  │  │─ S3 bucket (KMS-encrypted)   │  │─ centralised findings view       │  │
  │  │─ SIEM / long-term retention  │  │─ supports Organizations pattern  │  │
  │  └──────────────────────────────┘  └──────────────────────────────────┘  │
  └──────────────────────────────────────────────────────────────────────────┘
```

---

## Resources Created

| Resource | Description |
|----------|-------------|
| `aws_guardduty_detector` | Core detector; continuously monitors CloudTrail, VPC Flow Logs, and DNS |
| `aws_guardduty_detector_feature` | Enables opt-in features: S3, EKS audit logs, EBS malware protection |
| `aws_guardduty_filter` | Finding suppression rule (ARCHIVE) or tag rule (NOOP) with ranked criteria |
| `aws_guardduty_ipset` | Trusted IP list hosted in S3; GuardDuty skips findings for these IPs |
| `aws_guardduty_threatintelset` | Custom threat feed hosted in S3; generates findings for matching IPs |
| `aws_guardduty_publishing_destination` | Exports all findings to an S3 bucket (KMS-encrypted) |
| `aws_guardduty_member` | Invites member accounts to be centrally monitored |

---

## Usage

```hcl
module "guardduty" {
  source = "../../modules/security_identity_compliance/aws_guardDuty"

  region = "us-east-1"
  tags   = { environment = "production", team = "security" }

  detectors = [
    {
      key                          = "prod"
      enable                       = true
      finding_publishing_frequency = "FIFTEEN_MINUTES"
      enable_s3_logs               = true
      enable_kubernetes            = true
      enable_malware_protection    = false
    }
  ]

  filters = [
    {
      key          = "suppress-port-probe"
      detector_key = "prod"
      name         = "suppress-low-port-probe"
      action       = "ARCHIVE"
      rank         = 1
      criteria = [
        { field = "type",     equals             = ["Recon:EC2/PortProbeUnprotectedPort"] },
        { field = "severity", less_than_or_equal = "2" }
      ]
    }
  ]

  ip_sets = [
    {
      key          = "corporate-vpn"
      detector_key = "prod"
      name         = "corporate-trusted-ips"
      location     = "s3://my-security-bucket/guardduty/trusted-ips.txt"
      activate     = true
    }
  ]

  publishing_destinations = [
    {
      key             = "findings-export"
      detector_key    = "prod"
      destination_arn = "arn:aws:s3:::my-guardduty-findings-bucket"
      kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"
    }
  ]
}
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region where resources are deployed |

---

## Optional Variables

### Top-level

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all taggable resources |
| `detectors` | `list(object)` | `[]` | GuardDuty detector definitions |
| `filters` | `list(object)` | `[]` | Finding filter (suppression rule) definitions |
| `ip_sets` | `list(object)` | `[]` | Trusted IP set definitions |
| `threat_intel_sets` | `list(object)` | `[]` | Custom threat intelligence feed definitions |
| `publishing_destinations` | `list(object)` | `[]` | S3 publishing destination definitions |
| `members` | `list(object)` | `[]` | Member account invitation definitions |

### `detectors` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique `for_each` key |
| `enable` | `bool` | `true` | Enable (`true`) or pause (`false`) the detector |
| `finding_publishing_frequency` | `string` | `"SIX_HOURS"` | Export cadence: `FIFTEEN_MINUTES`, `ONE_HOUR`, `SIX_HOURS` |
| `enable_s3_logs` | `bool` | `true` | Enable S3 data event monitoring |
| `enable_kubernetes` | `bool` | `false` | Enable EKS audit log monitoring |
| `enable_malware_protection` | `bool` | `false` | Enable EC2 EBS malware scanning |
| `tags` | `map(string)` | `{}` | Per-detector tags merged with `common_tags` |

### `filters` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique `for_each` key |
| `detector_key` | `string` | required | Key of the parent detector |
| `name` | `string` | required | Filter name visible in the console |
| `description` | `string` | `""` | Human-readable description |
| `action` | `string` | `"NOOP"` | `ARCHIVE` suppresses; `NOOP` tags only |
| `rank` | `number` | `1` | Evaluation priority (1 = highest, 100 = lowest) |
| `criteria` | `list(object)` | required | List of criterion objects (logical AND) |

#### `criteria` entry fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `field` | `string` | required | GuardDuty finding field (e.g. `severity`, `type`, `region`) |
| `equals` | `list(string)` | `null` | Field must equal any of these values |
| `not_equals` | `list(string)` | `null` | Field must not equal any of these values |
| `greater_than_or_equal` | `string` | `null` | Numeric/date inclusive lower bound |
| `less_than` | `string` | `null` | Numeric/date exclusive upper bound |
| `less_than_or_equal` | `string` | `null` | Numeric/date inclusive upper bound |

### `ip_sets` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique `for_each` key |
| `detector_key` | `string` | required | Key of the parent detector |
| `name` | `string` | required | Display name for the IP set |
| `format` | `string` | `"TXT"` | File format: `TXT`, `STIX`, `OTX_CSV`, `ALIEN_VAULT`, `PROOF_POINT`, `FIRE_EYE` |
| `location` | `string` | required | S3 URI of the IP list file |
| `activate` | `bool` | `true` | Actively use the list in threat analysis |

### `threat_intel_sets` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique `for_each` key |
| `detector_key` | `string` | required | Key of the parent detector |
| `name` | `string` | required | Display name for the feed |
| `format` | `string` | `"TXT"` | File format (same options as `ip_sets`) |
| `location` | `string` | required | S3 URI of the threat feed file |
| `activate` | `bool` | `true` | Actively evaluate the feed |

### `publishing_destinations` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique `for_each` key |
| `detector_key` | `string` | required | Key of the parent detector |
| `destination_arn` | `string` | required | ARN of the target S3 bucket |
| `destination_type` | `string` | `"S3"` | Destination type (only `S3` is supported) |
| `kms_key_arn` | `string` | required | ARN of the KMS key for findings encryption |

### `members` object fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `key` | `string` | required | Unique `for_each` key |
| `detector_key` | `string` | required | Key of the administrator's detector |
| `account_id` | `string` | required | Member AWS account ID |
| `email` | `string` | required | Root email address of the member account |
| `invite` | `bool` | `true` | Send an invitation email |
| `disable_email_notification` | `bool` | `false` | Skip the invitation email |
| `invitation_message` | `string` | see default | Body text included in the invitation email |

---

## Outputs

| Output | Description |
|--------|-------------|
| `detector_ids` | Map of detector key → detector ID |
| `detector_arns` | Map of detector key → detector ARN |
| `detector_account_ids` | Map of detector key → owning AWS account ID |
| `filter_ids` | Map of filter key → filter name (resource ID) |
| `ip_set_ids` | Map of IP set key → IP set ID |
| `threat_intel_set_ids` | Map of threat intel set key → set ID |
| `publishing_destination_ids` | Map of destination key → destination ID |
| `member_ids` | Map of member key → invited account ID |
| `member_relationship_statuses` | Map of member key → relationship status |

---

## Notes

- GuardDuty uses **one detector per account per region**. Multiple `detectors` entries in this module are useful for multi-region deployments via aliased providers or cross-account Terraform configurations.
- Core data sources (CloudTrail management events, VPC Flow Logs, DNS logs) are **always enabled** when the detector is active — they are not configurable as opt-in/opt-out.
- Opt-in features (`S3_DATA_EVENTS`, `EKS_AUDIT_LOGS`, `EBS_MALWARE_PROTECTION`) are managed by `aws_guardduty_detector_feature` resources, replacing the deprecated `datasources` block (deprecated in AWS provider ≥ 5.0).
- IP set and threat intel set files must exist in the S3 bucket **before `terraform apply`**; GuardDuty validates the file location at creation time.
- The `publishing_destination` S3 bucket requires a bucket policy granting `guardduty.amazonaws.com` the `s3:GetBucketLocation` and `s3:PutObject` permissions.
- Member account invitations require the administrator account to have GuardDuty enabled; member accounts do not need GuardDuty pre-enabled.
- For AWS Organizations with auto-enable, use `aws_guardduty_organization_configuration` instead of individual `members` entries.

---

## See Also

- [Wrapper plan](../../../tf-plans/aws_guardduty/README.md)
- [Service overview](aws-guardduty.md)
- [AWS GuardDuty documentation](https://docs.aws.amazon.com/guardduty/latest/ug/)
- [Terraform aws_guardduty_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector)
- [Terraform aws_guardduty_detector_feature](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature)
- [Terraform aws_guardduty_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_filter)
- [GuardDuty Pricing](https://aws.amazon.com/guardduty/pricing/)
