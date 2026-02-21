# Expose CloudFront module outputs

# Distribution IDs
output "distribution_ids" {
  description = "Map of distribution key to CloudFront distribution ID"
  value       = module.cloudfront.distribution_ids
}

# Distribution ARNs
output "distribution_arns" {
  description = "Map of distribution key to CloudFront distribution ARN"
  value       = module.cloudfront.distribution_arns
}

# Distribution domain names
output "distribution_domain_names" {
  description = "Map of distribution key to CloudFront domain name"
  value       = module.cloudfront.distribution_domain_names
}

# Distribution hosted zone IDs (for Route 53 alias records)
output "distribution_hosted_zone_ids" {
  description = "Map of distribution key to Route 53 zone ID"
  value       = module.cloudfront.distribution_hosted_zone_ids
}

# Distribution statuses
output "distribution_statuses" {
  description = "Map of distribution key to deployment status"
  value       = module.cloudfront.distribution_statuses
}

# Distribution ETags
output "distribution_etags" {
  description = "Map of distribution key to ETag"
  value       = module.cloudfront.distribution_etags
}
