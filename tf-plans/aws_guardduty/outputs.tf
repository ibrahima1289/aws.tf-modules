# ── GuardDuty wrapper outputs ──────────────────────────────────────────────────
# Forwards all module outputs so they are accessible after apply.

output "detector_ids" {
  description = "Map of detector key → GuardDuty detector ID."
  value       = module.guardduty.detector_ids
}

output "detector_arns" {
  description = "Map of detector key → GuardDuty detector ARN."
  value       = module.guardduty.detector_arns
}

output "detector_account_ids" {
  description = "Map of detector key → AWS account ID that owns the detector."
  value       = module.guardduty.detector_account_ids
}

output "filter_ids" {
  description = "Map of filter key → GuardDuty filter name (resource ID)."
  value       = module.guardduty.filter_ids
}

output "ip_set_ids" {
  description = "Map of IP set key → GuardDuty IP set ID."
  value       = module.guardduty.ip_set_ids
}

output "threat_intel_set_ids" {
  description = "Map of threat intel set key → GuardDuty threat intel set ID."
  value       = module.guardduty.threat_intel_set_ids
}

output "publishing_destination_ids" {
  description = "Map of destination key → GuardDuty publishing destination ID."
  value       = module.guardduty.publishing_destination_ids
}

output "member_ids" {
  description = "Map of member key → invited member account ID."
  value       = module.guardduty.member_ids
}

output "member_relationship_statuses" {
  description = "Map of member key → current member relationship status."
  value       = module.guardduty.member_relationship_statuses
}
