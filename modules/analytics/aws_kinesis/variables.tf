// Input variables for AWS Kinesis Streams and Firehose module

variable "region" {
  description = "AWS region to use for Kinesis streams."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Kinesis resources."
  type        = map(string)
  default     = {}
}

variable "streams" {
  description = "Map of Kinesis streams to create (key is a logical name)."
  type = map(object({
    name                   = string
    stream_mode            = optional(string) # "PROVISIONED" or "ON_DEMAND"
    shard_count            = optional(number)
    retention_period_hours = optional(number)
    shard_level_metrics    = optional(list(string))

    encryption_enabled = optional(bool)
    kms_key_arn        = optional(string)

    tags = optional(map(string))
  }))
}

variable "firehoses" {
  description = "Map of Kinesis Firehose delivery streams to create (key is a logical name)."
  type = map(object({
    name        = string
    destination = string # e.g. "s3", "extended_s3", "http_endpoint", "redshift" (extended_s3)

    role_arn = string

    s3_bucket_arn      = optional(string)
    s3_prefix          = optional(string)
    s3_buffer_size     = optional(number)
    s3_buffer_interval = optional(number)

    kms_key_arn = optional(string)

    # Basic HTTP endpoint config (when destination = "http_endpoint")
    http_endpoint_url             = optional(string)
    http_endpoint_name            = optional(string)
    http_endpoint_access_key      = optional(string)
    http_endpoint_buffer_size     = optional(number)
    http_endpoint_buffer_interval = optional(number)

    tags = optional(map(string))
  }))
  default = {}
}
