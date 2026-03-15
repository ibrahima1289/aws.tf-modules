# ─── Trail ARNs ──────────────────────────────────────────────────────────────
output "trail_arns" {
  description = "Map of trail name to ARN"
  value       = module.cloudtrail.trail_arns
}

# ─── Trail IDs ───────────────────────────────────────────────────────────────
output "trail_ids" {
  description = "Map of trail name to resource ID"
  value       = module.cloudtrail.trail_ids
}

# ─── Trail Home Regions ───────────────────────────────────────────────────────
output "trail_home_regions" {
  description = "Map of trail name to home region"
  value       = module.cloudtrail.trail_home_regions
}
