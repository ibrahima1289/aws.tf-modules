// Outputs from the AWS Kinesis wrapper

output "stream_arns" {
  description = "Map of stream keys to Kinesis stream ARNs from the module."
  value       = module.aws_kinesis.stream_arns
}

output "stream_names" {
  description = "Map of stream keys to Kinesis stream names from the module."
  value       = module.aws_kinesis.stream_names
}

output "stream_ids" {
  description = "Map of stream keys to Kinesis stream IDs from the module."
  value       = module.aws_kinesis.stream_ids
}

output "firehose_arns" {
  description = "Map of firehose keys to Kinesis Firehose delivery stream ARNs from the module."
  value       = module.aws_kinesis.firehose_arns
}

output "firehose_names" {
  description = "Map of firehose keys to Kinesis Firehose delivery stream names from the module."
  value       = module.aws_kinesis.firehose_names
}
