output "bucket_ids" {
  description = "Map of bucket name to bucket ID."
  value       = module.aws_s3.bucket_ids
}

output "bucket_arns" {
  description = "Map of bucket name to bucket ARN."
  value       = module.aws_s3.bucket_arns
}
