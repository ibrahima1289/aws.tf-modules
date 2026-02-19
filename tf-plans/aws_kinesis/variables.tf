// Input variables for AWS Kinesis wrapper plan

variable "region" {
  description = "AWS region to deploy Kinesis streams in."
  type        = string
}

variable "tags" {
  description = "Global tags for all Kinesis resources."
  type        = map(string)
  default     = {}
}

variable "streams" {
  description = "Map of Kinesis streams to create. See module README for schema."
  type        = any
}

variable "firehoses" {
  description = "Map of Kinesis Firehose delivery streams to create. See module README for schema."
  type        = any
  default     = {}
}
