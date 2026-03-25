locals {
  # Compute a one-time created_date stamp merged into var.tags before passing to the module.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # ── Named queries ─────────────────────────────────────────────────────────
  # Defined here (not in terraform.tfvars) so that SQL strings can be loaded
  # from readable .sql template files via file().  The workgroup_key and
  # database_key values must match entries in var.workgroups and var.databases.
  named_queries_config = [

    # Query 1: Monthly cost report — top services by unblended cost.
    # Targets the Cost and Usage Report (CUR) table in the analytics database.
    {
      key           = "cost_report"
      name          = "Monthly Cost Report — Top Services"
      workgroup_key = "primary"
      database_key  = "analytics"
      description   = "Top 10 AWS services by unblended cost for the current month."
      query         = file("${path.module}/templates/cost-report.sql")
    },

    # Query 2: Security audit — recent IAM API calls from CloudTrail logs.
    {
      key           = "security_audit"
      name          = "Security Audit — IAM Activity"
      workgroup_key = "primary"
      database_key  = "analytics"
      description   = "IAM API calls recorded in CloudTrail logs over the last 30 days."
      query         = file("${path.module}/templates/security-audit.sql")
    }
  ]
}
