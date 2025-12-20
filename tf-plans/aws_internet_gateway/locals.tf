locals {
  # Used to stamp resources with creation date
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
