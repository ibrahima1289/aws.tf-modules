# Locals: central metadata
# - created_date: YYYY-MM-DD used for tagging across resources
# - glbs_list/map: unified multi-GLB configuration
locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  glbs_list = length(var.glbs) > 0 ? var.glbs : []
  glbs_map  = { for g in local.glbs_list : g.name => g }
}
