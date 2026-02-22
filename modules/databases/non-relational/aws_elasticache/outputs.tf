// Output values from AWS ElastiCache module

# ---------------------------------------------------------------------------
# Cluster Outputs
# ---------------------------------------------------------------------------

output "cluster_ids" {
  description = "Map of logical cluster names to their cluster IDs"
  value       = { for k, v in aws_elasticache_cluster.cluster : k => v.cluster_id }
}

output "cluster_addresses" {
  description = "Map of logical cluster names to their cache cluster addresses"
  value       = { for k, v in aws_elasticache_cluster.cluster : k => v.cache_nodes[0].address }
}

output "cluster_configuration_endpoints" {
  description = "Map of logical cluster names to their configuration endpoints (Memcached only)"
  value       = { for k, v in aws_elasticache_cluster.cluster : k => v.configuration_endpoint }
}

output "cluster_arns" {
  description = "Map of logical cluster names to their ARNs"
  value       = { for k, v in aws_elasticache_cluster.cluster : k => v.arn }
}

# ---------------------------------------------------------------------------
# Replication Group Outputs
# ---------------------------------------------------------------------------

output "replication_group_ids" {
  description = "Map of logical replication group names to their IDs"
  value       = { for k, v in aws_elasticache_replication_group.replication_group : k => v.id }
}

output "replication_group_arns" {
  description = "Map of logical replication group names to their ARNs"
  value       = { for k, v in aws_elasticache_replication_group.replication_group : k => v.arn }
}

output "replication_group_primary_endpoints" {
  description = "Map of logical replication group names to their primary endpoint addresses"
  value       = { for k, v in aws_elasticache_replication_group.replication_group : k => v.primary_endpoint_address }
}

output "replication_group_reader_endpoints" {
  description = "Map of logical replication group names to their reader endpoint addresses"
  value       = { for k, v in aws_elasticache_replication_group.replication_group : k => v.reader_endpoint_address }
}

output "replication_group_configuration_endpoints" {
  description = "Map of logical replication group names to their configuration endpoint addresses (cluster mode enabled)"
  value       = { for k, v in aws_elasticache_replication_group.replication_group : k => v.configuration_endpoint_address }
}

output "replication_group_member_clusters" {
  description = "Map of logical replication group names to their member cluster IDs"
  value       = { for k, v in aws_elasticache_replication_group.replication_group : k => v.member_clusters }
}
