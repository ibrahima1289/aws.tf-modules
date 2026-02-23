# Local values for Aurora module
locals {
  # Generate created date tag in ISO 8601 format
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Common tags to be applied to all Aurora resources
  common_tags = {
    ManagedBy   = "Terraform"
    Module      = "aws_aurora"
    CreatedDate = local.created_date
  }
}
