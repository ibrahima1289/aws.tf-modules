# Locals: central metadata
# - created_date: YYYY-MM-DD used for tagging across resources
# - nlbs_list/map: unified multi-NLB configuration
locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  nlbs_list = length(var.nlbs) > 0 ? var.nlbs : []
  nlbs_map  = { for n in local.nlbs_list : n.name => n }
}
