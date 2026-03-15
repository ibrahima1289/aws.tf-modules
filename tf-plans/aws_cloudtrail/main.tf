module "cloudtrail" {
  source = "../../modules/monitoring/aws_cloudtrail"

  region = var.region

  # Common tags merged with the wrapper-level created_date stamp
  tags = merge(var.tags, { created_date = local.created_date })

  # ── Trails ─────────────────────────────────────────────────────
  # Each entry in this list creates one aws_cloudtrail resource.
  trails = var.trails
}
