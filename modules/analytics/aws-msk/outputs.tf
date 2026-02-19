// Outputs for AWS MSK module

output "cluster_arns" {
  description = "Map of cluster keys to MSK cluster ARNs."
  value       = { for k, c in aws_msk_cluster.msk : k => c.arn }
}

output "cluster_names" {
  description = "Map of cluster keys to MSK cluster names."
  value       = { for k, c in aws_msk_cluster.msk : k => c.cluster_name }
}

output "bootstrap_brokers" {
  description = "Map of cluster keys to MSK bootstrap broker strings."
  value       = { for k, c in aws_msk_cluster.msk : k => c.bootstrap_brokers }
}
