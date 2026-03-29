region = "us-east-1"

tags = {
  environment = "production"
  team        = "security"
  project     = "threat-detection"
  managed_by  = "terraform"
}

# ── Detectors ──────────────────────────────────────────────────────────────────
# Pattern 1: Production detector — S3 protection on; EKS and malware opt-in.
# Pattern 2: Full-coverage detector — all three opt-in features enabled
#            (uncomment and add a second entry with a different key).

detectors = [
  {
    # Production account detector — most workloads use this minimal config.
    key                          = "prod"
    enable                       = true
    finding_publishing_frequency = "FIFTEEN_MINUTES" # faster export for production
    enable_s3_logs               = true              # detect suspicious S3 data activity
    enable_kubernetes            = false             # set true if EKS clusters are present
    enable_malware_protection    = false             # set true to enable EC2 EBS malware scans
    tags                         = { tier = "production" }
  }
]

# ── Finding Filters ────────────────────────────────────────────────────────────
# Pattern 1: ARCHIVE low-severity port-probe findings — common internet scanner noise.
# Pattern 2: NOOP tag for informational findings — visible for review but not suppressed.

filters = [
  {
    # Suppress low-severity port-probe findings to reduce SOC alert fatigue.
    key          = "suppress-low-port-probe"
    detector_key = "prod"
    name         = "suppress-low-port-probe"
    description  = "Archives informational port-probe findings (severity ≤ 2) from the internet."
    action       = "ARCHIVE"
    rank         = 1
    criteria = [
      {
        field  = "type"
        equals = ["Recon:EC2/PortProbeUnprotectedPort"]
      },
      {
        field              = "severity"
        less_than_or_equal = "2"
      }
    ]
  }
]

# ── IP Sets ────────────────────────────────────────────────────────────────────
# Upload the trusted IP list to S3 before applying.
# Replace the S3 URI with your actual bucket and object path.

# ip_sets = [
#   {
#     # Corporate VPN and office IP ranges — GuardDuty ignores traffic from these IPs.
#     key          = "corporate-trusted"
#     detector_key = "prod"
#     name         = "corporate-trusted-ips"
#     format       = "TXT"     # one CIDR or IP per line
#     location     = "s3://my-security-bucket/guardduty/trusted-ips.txt"
#     activate     = true
#   }
# ]

# ── Threat Intelligence Sets ───────────────────────────────────────────────────
# Upload the threat feed to S3 before applying.

# threat_intel_sets = [
#   {
#     # Custom threat intelligence feed from a third-party provider.
#     key          = "custom-threat-feed"
#     detector_key = "prod"
#     name         = "custom-threat-intel"
#     format       = "TXT"
#     location     = "s3://my-security-bucket/guardduty/threat-intel.txt"
#     activate     = true
#   }
# ]

# ── Publishing Destinations ────────────────────────────────────────────────────
# Prerequisites before applying:
#   1. S3 bucket must have a bucket policy granting guardduty.amazonaws.com
#      s3:GetBucketLocation and s3:PutObject on the bucket and its objects.
#   2. KMS key must have a key policy granting GuardDuty
#      kms:GenerateDataKey and kms:Decrypt permissions.
# Replace ARNs with actual values.

# publishing_destinations = [
#   {
#     key              = "findings-export"
#     detector_key     = "prod"
#     destination_arn  = "arn:aws:s3:::my-guardduty-findings-bucket"
#     destination_type = "S3"
#     kms_key_arn      = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123def456"
#   }
# ]

# ── Member Accounts ────────────────────────────────────────────────────────────
# This wrapper must be applied from the GuardDuty administrator account.
# Replace account IDs and emails with actual values before applying.
# For AWS Organizations auto-enable, use aws_guardduty_organization_configuration
# instead of individual member invitations.

# members = [
#   {
#     key                        = "dev-account"
#     detector_key               = "prod"
#     account_id                 = "111122223333"          # replace with actual account ID
#     email                      = "dev-root@example.com"
#     invite                     = true
#     disable_email_notification = false
#     invitation_message         = "Please accept the GuardDuty invitation from the security team."
#   },
#   {
#     key                        = "staging-account"
#     detector_key               = "prod"
#     account_id                 = "444455556666"          # replace with actual account ID
#     email                      = "staging-root@example.com"
#     invite                     = true
#     disable_email_notification = false
#     invitation_message         = "Please accept the GuardDuty invitation from the security team."
#   }
# ]
