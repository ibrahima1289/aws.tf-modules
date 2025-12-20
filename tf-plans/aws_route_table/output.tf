output "route_table_ids" {
  description = "Map of created route table keys to IDs"
  value       = module.route_table.route_table_ids
}
