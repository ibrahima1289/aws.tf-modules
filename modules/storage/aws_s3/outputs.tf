output "bucket_ids" {
  description = "Map of bucket name to bucket ID."
  value       = { for k, b in aws_s3_bucket.s3_bucket : k => b.id }
}

output "bucket_arns" {
  description = "Map of bucket name to bucket ARN."
  value       = { for k, b in aws_s3_bucket.s3_bucket : k => b.arn }
}
