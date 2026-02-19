// Outputs from the AWS MSK wrapper

output "cluster_arns" {
  description = "Map of cluster keys to MSK cluster ARNs from the module."
  value       = module.aws_msk.cluster_arns
}

output "cluster_names" {
  description = "Map of cluster keys to MSK cluster names from the module."
  value       = module.aws_msk.cluster_names
}

output "bootstrap_brokers" {
  description = "Map of cluster keys to MSK bootstrap brokers from the module."
  value       = module.aws_msk.bootstrap_brokers
}
