# Local values for RDS module
locals {
  # Generate created date tag in ISO 8601 format
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Common tags to be applied to all RDS instances
  common_tags = {
    ManagedBy   = "Terraform"
    Module      = "aws_rds"
    CreatedDate = local.created_date
  }
}
