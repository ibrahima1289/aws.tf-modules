############################################
# Outputs
############################################

output "route_table_ids" {
  description = "Map of created route table keys to their IDs."
  value       = { for k, rt in aws_route_table.route_table : k => rt.id }
}

output "association_subnet_ids" {
  description = "Map of route table keys to associated subnet IDs."
  value       = {
    for k, rt in aws_route_table.route_table :
    k => [for item in local.rt_assoc_list : item.subnet if item.rt_key == k]
  }
}

output "route_keys" {
  description = "Keys identifying created route entries per route table."
  value       = [for item in local.rt_route_list : item.key]
}
