locals {
  # Record the date when Terraform is run to tag resources
  created_date = formatdate("YYYY-MM-DD", timestamp())
}