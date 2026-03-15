# ─── Trail ARNs ──────────────────────────────────────────────────────────────
output "trail_arns" {
  description = "Map of trail name to ARN"
  value       = { for k, t in aws_cloudtrail.trail : k => t.arn }
}

# ─── Trail IDs ───────────────────────────────────────────────────────────────
output "trail_ids" {
  description = "Map of trail name to resource ID"
  value       = { for k, t in aws_cloudtrail.trail : k => t.id }
}

# ─── Trail Home Regions ───────────────────────────────────────────────────────
output "trail_home_regions" {
  description = "Map of trail name to home region (the region in which the trail was created)"
  value       = { for k, t in aws_cloudtrail.trail : k => t.home_region }
}
