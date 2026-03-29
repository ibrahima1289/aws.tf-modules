locals {
  # Step 1: Record the date when Terraform is run to tag resources consistently.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags shared by all taggable GuardDuty resources.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert input lists to stable maps keyed by .key for use with for_each.
  detectors_map         = { for d in var.detectors : d.key => d }
  filters_map           = { for f in var.filters : f.key => f }
  ip_sets_map           = { for i in var.ip_sets : i.key => i }
  threat_intel_sets_map = { for t in var.threat_intel_sets : t.key => t }
  publishing_dests_map  = { for p in var.publishing_destinations : p.key => p }
  members_map           = { for m in var.members : m.key => m }

  # Step 4: Build a flat feature map for aws_guardduty_detector_feature.
  # Keys are "detector_key-FEATURE_NAME" to ensure uniqueness across detectors.
  # Only the three opt-in features need feature resources; core data sources
  # (CloudTrail management events, VPC Flow Logs, DNS logs) are always on.
  _detector_features = flatten([
    for k, d in local.detectors_map : [
      { detector_key = k, name = "S3_DATA_EVENTS", status = d.enable_s3_logs ? "ENABLED" : "DISABLED" },
      { detector_key = k, name = "EKS_AUDIT_LOGS", status = d.enable_kubernetes ? "ENABLED" : "DISABLED" },
      { detector_key = k, name = "EBS_MALWARE_PROTECTION", status = d.enable_malware_protection ? "ENABLED" : "DISABLED" },
    ]
  ])
  features_map = { for f in local._detector_features : "${f.detector_key}-${f.name}" => f }
}
