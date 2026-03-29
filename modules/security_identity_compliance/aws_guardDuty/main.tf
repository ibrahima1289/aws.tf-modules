# ── AWS GuardDuty Module ───────────────────────────────────────────────────────
# Creates GuardDuty detectors with optional finding filters (suppression rules),
# trusted IP sets, custom threat intelligence sets, findings publishing
# destinations (S3), and member account associations.
# All resource types support multiple instances via for_each.

# ── Step 1: GuardDuty Detectors ────────────────────────────────────────────────
# The detector is the core GuardDuty resource — one per account per region.
# It continuously monitors CloudTrail management events, VPC Flow Logs, and DNS
# logs automatically. Additional features are managed via detector_feature resources.
resource "aws_guardduty_detector" "detector" {
  for_each = local.detectors_map

  # Enable or disable threat detection; disabling preserves configuration but stops analysis.
  enable = each.value.enable

  # Controls how frequently GuardDuty exports findings to EventBridge and S3.
  finding_publishing_frequency = each.value.finding_publishing_frequency

  # Merge common tags, per-detector tags, and a Name tag for console identification.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.key
  })
}

# ── Step 2: Optional Detector Features ────────────────────────────────────────
# Manages opt-in data sources per detector via aws_guardduty_detector_feature.
# Core sources (CloudTrail management events, VPC Flow Logs, DNS logs) are always on.
#
# Managed features:
#   S3_DATA_EVENTS        — monitors S3 object-level API activity.
#   EKS_AUDIT_LOGS        — analyzes Kubernetes audit logs for container threats.
#   EBS_MALWARE_PROTECTION — scans EBS volumes on EC2 instances with suspicious findings.
resource "aws_guardduty_detector_feature" "feature" {
  for_each = local.features_map

  # Attach each feature to its parent detector via the detector_key.
  detector_id = aws_guardduty_detector.detector[each.value.detector_key].id

  # Feature name (S3_DATA_EVENTS, EKS_AUDIT_LOGS, or EBS_MALWARE_PROTECTION).
  name = each.value.name

  # ENABLED or DISABLED — sourced from the corresponding detector variable flag.
  status = each.value.status
}

# ── Step 3: Finding Filters ────────────────────────────────────────────────────
# Filters automatically suppress (ARCHIVE) or flag (NOOP) findings that match
# all specified criteria. Use ARCHIVE for confirmed false positives to reduce noise.
# Multiple criteria within a single filter are evaluated with logical AND.
resource "aws_guardduty_filter" "filter" {
  for_each = local.filters_map

  # Attach to the correct detector using the caller-provided detector_key.
  detector_id = aws_guardduty_detector.detector[each.value.detector_key].id

  name        = each.value.name
  description = each.value.description

  # ARCHIVE suppresses matching findings; NOOP tags them without hiding them.
  action = each.value.action

  # Lower rank = higher priority when multiple filters match the same finding (1–100).
  rank = each.value.rank

  # Build one criterion block per entry in the criteria list (evaluated with logical AND).
  finding_criteria {
    dynamic "criterion" {
      for_each = each.value.criteria
      content {
        field                 = criterion.value.field
        equals                = criterion.value.equals
        not_equals            = criterion.value.not_equals
        greater_than_or_equal = criterion.value.greater_than_or_equal
        less_than             = criterion.value.less_than
        less_than_or_equal    = criterion.value.less_than_or_equal
      }
    }
  }
}

# ── Step 4: Trusted IP Sets ────────────────────────────────────────────────────
# GuardDuty will not generate findings for traffic that originates from IPs in
# trusted IP sets (e.g., corporate VPN ranges, known internal security scanners).
# The IP list file must exist in S3 before this resource is applied.
resource "aws_guardduty_ipset" "ip_set" {
  for_each = local.ip_sets_map

  # Attach to the referenced detector.
  detector_id = aws_guardduty_detector.detector[each.value.detector_key].id

  name     = each.value.name
  format   = each.value.format
  location = each.value.location

  # activate = false stages the list without enabling real-time evaluation.
  activate = each.value.activate
}

# ── Step 5: Threat Intelligence Sets ──────────────────────────────────────────
# Custom threat feeds augment the built-in AWS threat intelligence.
# GuardDuty generates findings for any traffic involving IPs in these lists.
# The threat feed file must exist in S3 before this resource is applied.
resource "aws_guardduty_threatintelset" "threat_intel_set" {
  for_each = local.threat_intel_sets_map

  # Attach to the referenced detector.
  detector_id = aws_guardduty_detector.detector[each.value.detector_key].id

  name     = each.value.name
  format   = each.value.format
  location = each.value.location

  # activate = false stages the feed without activating real-time evaluation.
  activate = each.value.activate
}

# ── Step 6: Publishing Destinations ────────────────────────────────────────────
# Export all current and future findings to an S3 bucket for long-term retention,
# SIEM ingestion, or cross-account security analysis.
# Prerequisite: S3 bucket policy and KMS key policy must allow GuardDuty access.
resource "aws_guardduty_publishing_destination" "destination" {
  for_each = local.publishing_dests_map

  # Attach to the referenced detector.
  detector_id = aws_guardduty_detector.detector[each.value.detector_key].id

  # ARN of the target S3 bucket — must have a GuardDuty-compatible bucket policy.
  destination_arn  = each.value.destination_arn
  destination_type = each.value.destination_type

  # KMS key for server-side encryption of exported findings in S3.
  kms_key_arn = each.value.kms_key_arn
}

# ── Step 7: Member Accounts ────────────────────────────────────────────────────
# Invite member accounts to be monitored centrally by this administrator account.
# All findings from accepted members are forwarded to the administrator's detector.
# This module must be applied from the GuardDuty administrator account.
resource "aws_guardduty_member" "member" {
  for_each = local.members_map

  # Administrator account's detector ID.
  detector_id = aws_guardduty_detector.detector[each.value.detector_key].id

  account_id = each.value.account_id
  email      = each.value.email

  # Sends an invitation to the member account's root email address.
  invite = each.value.invite

  # Skip the invitation email when the member will auto-accept (e.g. via Organizations).
  disable_email_notification = each.value.disable_email_notification

  # Message body included in the invitation email sent to the member account.
  invitation_message = each.value.invitation_message
}
