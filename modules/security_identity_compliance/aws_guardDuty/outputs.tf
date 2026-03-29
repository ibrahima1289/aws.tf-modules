# ── Detector outputs ───────────────────────────────────────────────────────────

output "detector_ids" {
  description = "Map of detector key → GuardDuty detector ID."
  value       = { for k, v in aws_guardduty_detector.detector : k => v.id }
}

output "detector_arns" {
  description = "Map of detector key → GuardDuty detector ARN."
  value       = { for k, v in aws_guardduty_detector.detector : k => v.arn }
}

output "detector_account_ids" {
  description = "Map of detector key → AWS account ID that owns the detector."
  value       = { for k, v in aws_guardduty_detector.detector : k => v.account_id }
}

# ── Filter outputs ─────────────────────────────────────────────────────────────

output "filter_ids" {
  description = "Map of filter key → GuardDuty filter name (used as resource ID)."
  value       = { for k, v in aws_guardduty_filter.filter : k => v.id }
}

# ── IP Set outputs ─────────────────────────────────────────────────────────────

output "ip_set_ids" {
  description = "Map of IP set key → GuardDuty IP set ID."
  value       = { for k, v in aws_guardduty_ipset.ip_set : k => v.id }
}

# ── Threat Intel Set outputs ────────────────────────────────────────────────────

output "threat_intel_set_ids" {
  description = "Map of threat intel set key → GuardDuty threat intel set ID."
  value       = { for k, v in aws_guardduty_threatintelset.threat_intel_set : k => v.id }
}

# ── Publishing Destination outputs ─────────────────────────────────────────────

output "publishing_destination_ids" {
  description = "Map of destination key → GuardDuty publishing destination ID."
  value       = { for k, v in aws_guardduty_publishing_destination.destination : k => v.id }
}

# ── Member outputs ─────────────────────────────────────────────────────────────

output "member_ids" {
  description = "Map of member key → invited member account ID."
  value       = { for k, v in aws_guardduty_member.member : k => v.account_id }
}

output "member_relationship_statuses" {
  description = "Map of member key → current member relationship status."
  value       = { for k, v in aws_guardduty_member.member : k => v.relationship_status }
}
