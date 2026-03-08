// Output values for AWS DocumentDB wrapper plan

# Full cluster details from root module
output "clusters" {
  description = "Map of DocumentDB cluster details (endpoint, reader endpoint, ARN, configuration)."
  value       = module.aws_documentdb.clusters
}

# Cluster ARNs for use in IAM policies and cross-account references
output "cluster_arns" {
  description = "Map of logical cluster keys to their ARNs."
  value       = module.aws_documentdb.cluster_arns
}

# Primary write endpoints — connect your application here for all write operations
output "cluster_endpoints" {
  description = "Map of logical cluster keys to their primary (write) endpoints."
  value       = module.aws_documentdb.cluster_endpoints
}

# Read-only endpoints — route read traffic here to distribute load across replicas
output "reader_endpoints" {
  description = "Map of logical cluster keys to their reader (load-balanced read) endpoints."
  value       = module.aws_documentdb.reader_endpoints
}

# Subnet group details
output "subnet_groups" {
  description = "Map of subnet group IDs and ARNs per cluster."
  value       = module.aws_documentdb.subnet_groups
}

# Custom parameter group details (only present when parameters were defined)
output "parameter_groups" {
  description = "Map of parameter group IDs and ARNs (only clusters with custom parameters)."
  value       = module.aws_documentdb.parameter_groups
}

# Full instance details keyed by "<cluster_key>-<index>"
output "instances" {
  description = "Map of instance details keyed by <cluster_key>-<index>."
  value       = module.aws_documentdb.instances
}
