# Locals: central metadata
# - created_date: YYYY-MM-DD used for tagging
locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  albs_list = length(var.albs) > 0 ? var.albs : []
  albs_map  = { for a in local.albs_list : a.name => a }
}
