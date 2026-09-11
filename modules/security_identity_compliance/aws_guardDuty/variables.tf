# ── Top-level variables ───────────────────────────────────────────────────────

variable "region" {
  description = "AWS region where GuardDuty resources are deployed."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all taggable GuardDuty resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

# ── Detectors ─────────────────────────────────────────────────────────────────

variable "detectors" {
  description = <<-EOT
    List of GuardDuty detectors to create. Each entry maps to one aws_guardduty_detector.
    GuardDuty is typically enabled with one detector per account per region.
    Multiple detectors are useful in multi-region or cross-account module calls.

    Data source notes:
      s3_logs            — monitors S3 object-level API activity for data exfiltration/deletion.
      kubernetes         — analyzes EKS cluster audit logs for container threats.
      malware_protection — scans EBS volumes of EC2 instances with suspicious findings.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Enable or disable the detector. Disabling pauses threat detection but preserves config.
    enable = optional(bool, true)

    # How often GuardDuty exports findings to EventBridge and S3.
    # FIFTEEN_MINUTES, ONE_HOUR, or SIX_HOURS.
    finding_publishing_frequency = optional(string, "SIX_HOURS")

    # Enable S3 protection — monitors S3 data events for threats.
    enable_s3_logs = optional(bool, true)

    # Enable EKS protection — monitors Kubernetes audit logs.
    enable_kubernetes = optional(bool, false)

    # Enable EC2 malware protection — scans EBS volumes on suspicious instances.
    enable_malware_protection = optional(bool, false)

    # Per-detector tags merged with common_tags.
    tags = optional(map(string), {})
  }))

  default = []

  validation {
    condition     = length([for d in var.detectors : d.key]) == length(toset([for d in var.detectors : d.key]))
    error_message = "Each detector must have a unique 'key'."
  }
}

# ── Finding Filters ────────────────────────────────────────────────────────────

variable "filters" {
  description = <<-EOT
    List of GuardDuty finding filters (suppression rules). Each entry maps to one
    aws_guardduty_filter resource attached to the referenced detector.

    action values:
      ARCHIVE — automatically archives (suppresses) matching findings.
      NOOP    — tags matching findings but leaves them visible for review.

    Criteria fields (common examples):
      severity, type, region, accountId, id, createdAt, updatedAt,
      resource.instanceDetails.instanceId, service.additionalInfo.threatListName.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the detector this filter is attached to (must match a detectors[*].key).
    detector_key = string

    # Filter name visible in the GuardDuty console.
    name = string

    # Human-readable description of what the filter suppresses.
    description = optional(string, "")

    # ARCHIVE suppresses matching findings; NOOP marks them without suppressing.
    action = optional(string, "NOOP")

    # Evaluation priority. Lower numbers are evaluated first (1–100).
    rank = optional(number, 1)

    # List of criterion objects evaluated with logical AND.
    criteria = list(object({
      # GuardDuty finding field to evaluate (e.g. "severity", "type", "region").
      field = string

      # String fields: exact match — logical OR across list values.
      equals = optional(list(string))

      # String fields: must NOT equal any of these values.
      not_equals = optional(list(string))

      # Numeric or ISO-8601 date fields: inclusive lower bound.
      greater_than_or_equal = optional(string)

      # Numeric or ISO-8601 date fields: exclusive upper bound.
      less_than = optional(string)

      # Numeric or ISO-8601 date fields: inclusive upper bound.
      less_than_or_equal = optional(string)
    }))
  }))
  default = []
}

# ── IP Sets ────────────────────────────────────────────────────────────────────

variable "ip_sets" {
  description = <<-EOT
    List of trusted IP sets. Each entry maps to one aws_guardduty_ipset resource.
    GuardDuty will not generate findings for traffic from trusted IPs.
    The list file must be stored in an S3 bucket accessible by GuardDuty.

    Supported formats: TXT (one CIDR or IP per line), STIX, OTX_CSV, ALIEN_VAULT,
    PROOF_POINT, FIRE_EYE.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the detector this IP set is attached to.
    detector_key = string

    # Display name for the IP set.
    name = string

    # File format (default TXT).
    format = optional(string, "TXT")

    # S3 URI of the IP list file (e.g. s3://bucket/path/trusted-ips.txt).
    location = string

    # Whether GuardDuty actively uses this list. false = staged but inactive.
    activate = optional(bool, true)
  }))
  default = []
}

# ── Threat Intelligence Sets ───────────────────────────────────────────────────

variable "threat_intel_sets" {
  description = <<-EOT
    List of custom threat intelligence feeds. Each entry maps to one
    aws_guardduty_threatintelset resource.
    GuardDuty generates findings for any traffic involving IPs or domains in these lists,
    augmenting the built-in AWS threat intelligence.
    The list file must be stored in S3.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the detector this threat intel set is attached to.
    detector_key = string

    # Display name for the threat intel set.
    name = string

    # File format (default TXT).
    format = optional(string, "TXT")

    # S3 URI of the threat intelligence file.
    location = string

    # Whether GuardDuty actively evaluates this feed.
    activate = optional(bool, true)
  }))
  default = []
}

# ── Publishing Destinations ────────────────────────────────────────────────────

variable "publishing_destinations" {
  description = <<-EOT
    List of findings publishing destinations. Each entry maps to one
    aws_guardduty_publishing_destination resource that exports findings to S3.

    Prerequisites:
      1. The S3 bucket must have a bucket policy granting guardduty.amazonaws.com
         s3:GetBucketLocation and s3:PutObject permissions.
      2. The KMS key must have a key policy granting GuardDuty
         kms:GenerateDataKey and kms:Decrypt permissions.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the detector this destination is attached to.
    detector_key = string

    # ARN of the target S3 bucket.
    destination_arn = string

    # Destination type — only "S3" is currently supported by AWS.
    destination_type = optional(string, "S3")

    # ARN of the KMS key used to encrypt exported findings in S3.
    kms_key_arn = string
  }))
  default = []
}

# ── Member Accounts ────────────────────────────────────────────────────────────

variable "members" {
  description = <<-EOT
    List of member accounts to invite to GuardDuty. Each entry maps to one
    aws_guardduty_member resource.

    This module must be run from the GuardDuty administrator account.
    For AWS Organizations-managed GuardDuty (auto-enable), use
    aws_guardduty_organization_configuration instead of individual invitations.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the detector on the administrator account.
    detector_key = string

    # AWS account ID of the member account to invite.
    account_id = string

    # Root email address associated with the member account.
    email = string

    # Send an invitation to the member account.
    invite = optional(bool, true)

    # Skip the invitation email — useful when the member will auto-accept via Organizations.
    disable_email_notification = optional(bool, false)

    # Optional message body included in the invitation email.
    invitation_message = optional(string, "You are invited to join GuardDuty managed by the administrator account.")
  }))
  default = []
}
