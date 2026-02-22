// Output values from AWS ElastiCache wrapper

output "cluster_ids" {
  description = "Map of logical cluster names to their cluster IDs"
  value       = module.aws_elasticache.cluster_ids
}

output "cluster_addresses" {
  description = "Map of logical cluster names to their cache cluster addresses"
  value       = module.aws_elasticache.cluster_addresses
}

output "cluster_configuration_endpoints" {
  description = "Map of logical cluster names to their configuration endpoints (Memcached only)"
  value       = module.aws_elasticache.cluster_configuration_endpoints
}

output "cluster_arns" {
  description = "Map of logical cluster names to their ARNs"
  value       = module.aws_elasticache.cluster_arns
}

output "replication_group_ids" {
  description = "Map of logical replication group names to their IDs"
  value       = module.aws_elasticache.replication_group_ids
}

output "replication_group_arns" {
  description = "Map of logical replication group names to their ARNs"
  value       = module.aws_elasticache.replication_group_arns
}

output "replication_group_primary_endpoints" {
  description = "Map of logical replication group names to their primary endpoint addresses"
  value       = module.aws_elasticache.replication_group_primary_endpoints
}

output "replication_group_reader_endpoints" {
  description = "Map of logical replication group names to their reader endpoint addresses"
  value       = module.aws_elasticache.replication_group_reader_endpoints
}

output "replication_group_configuration_endpoints" {
  description = "Map of logical replication group names to their configuration endpoint addresses (cluster mode enabled)"
  value       = module.aws_elasticache.replication_group_configuration_endpoints
}

output "replication_group_member_clusters" {
  description = "Map of logical replication group names to their member cluster IDs"
  value       = module.aws_elasticache.replication_group_member_clusters
}
