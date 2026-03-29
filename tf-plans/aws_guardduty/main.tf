# ── GuardDuty wrapper — module invocation ─────────────────────────────────────
# Calls the GuardDuty root module, forwarding all variables from terraform.tfvars.
# The created_date tag is injected by this wrapper's locals so the module
# receives a fully merged tag map on every apply.
module "guardduty" {
  source = "../../modules/security_identity_compliance/aws_guardDuty"

  # AWS region forwarded from var.region.
  region = var.region

  # Merge caller-supplied tags with the auto-generated created_date stamp.
  tags = merge(var.tags, {
    created_date = local.created_date
  })

  # GuardDuty detectors — one per account per region is the typical production pattern.
  detectors = var.detectors

  # Finding filters — suppress or tag known false-positive finding types.
  filters = var.filters

  # Trusted IP sets — corporate VPN, known scanners, office ranges, etc.
  ip_sets = var.ip_sets

  # Custom threat intelligence feeds — augment AWS built-in threat intel.
  threat_intel_sets = var.threat_intel_sets

  # S3 publishing destinations for long-term findings storage or SIEM ingestion.
  publishing_destinations = var.publishing_destinations

  # Member accounts monitored centrally by this administrator account.
  members = var.members
}
