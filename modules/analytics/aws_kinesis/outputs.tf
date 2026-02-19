// Outputs for AWS Kinesis Streams and Firehose module

output "stream_arns" {
  description = "Map of stream keys to Kinesis stream ARNs."
  value       = { for k, s in aws_kinesis_stream.kinesis : k => s.arn }
}

output "stream_names" {
  description = "Map of stream keys to Kinesis stream names."
  value       = { for k, s in aws_kinesis_stream.kinesis : k => s.name }
}

output "stream_ids" {
  description = "Map of stream keys to Kinesis stream IDs."
  value       = { for k, s in aws_kinesis_stream.kinesis : k => s.id }
}

output "firehose_arns" {
  description = "Map of firehose keys to Kinesis Firehose delivery stream ARNs."
  value       = { for k, f in aws_kinesis_firehose_delivery_stream.firehose : k => f.arn }
}

output "firehose_names" {
  description = "Map of firehose keys to Kinesis Firehose delivery stream names."
  value       = { for k, f in aws_kinesis_firehose_delivery_stream.firehose : k => f.name }
}
