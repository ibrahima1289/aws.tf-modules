# Map outputs for created CloudFront distributions

# Distribution outputs
output "distribution_ids" {
  description = "Map of distribution key to CloudFront distribution ID"
  value       = { for k, v in aws_cloudfront_distribution.distribution : k => v.id }
}

output "distribution_arns" {
  description = "Map of distribution key to CloudFront distribution ARN"
  value       = { for k, v in aws_cloudfront_distribution.distribution : k => v.arn }
}

output "distribution_domain_names" {
  description = "Map of distribution key to CloudFront domain name (e.g., d111111abcdef8.cloudfront.net)"
  value       = { for k, v in aws_cloudfront_distribution.distribution : k => v.domain_name }
}

output "distribution_hosted_zone_ids" {
  description = "Map of distribution key to Route 53 zone ID (for alias records)"
  value       = { for k, v in aws_cloudfront_distribution.distribution : k => v.hosted_zone_id }
}

output "distribution_statuses" {
  description = "Map of distribution key to current deployment status"
  value       = { for k, v in aws_cloudfront_distribution.distribution : k => v.status }
}

output "distribution_etags" {
  description = "Map of distribution key to ETag (for conditional requests)"
  value       = { for k, v in aws_cloudfront_distribution.distribution : k => v.etag }
}
