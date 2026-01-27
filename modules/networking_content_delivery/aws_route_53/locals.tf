###############################################
# Locals and immutable CreatedDate tagging
###############################################

# Standard tags merged into all taggable resources in this module.
locals {
  standard_tags = merge(
    {
      # ISO-8601 created date tag label
      created_date = formatdate("YYYY-MM-DD", timestamp())
      ManagedBy    = "Terraform"
      Module       = "aws_route_53"
    },
    var.tags
  )

  # Partition input records to avoid sending null-only arguments for alias records.
  basic_records = {
    for k, v in var.records : k => v if try(v.alias, null) == null
  }
  alias_records = {
    for k, v in var.records : k => v if try(v.alias, null) != null
  }
}
