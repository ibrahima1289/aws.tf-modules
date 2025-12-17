locals {
  # ISO-8601 created date tag label
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Base tags merged into all resources
  base_tags = merge(var.tags, {
    created_date = local.created_date
  })
}
