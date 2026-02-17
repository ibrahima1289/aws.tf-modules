// Input variables for AWS SQS wrapper plan

variable "region" {
  description = "AWS region to deploy SQS queues in."
  type        = string
}

variable "tags" {
  description = "Global tags for all SQS queues."
  type        = map(string)
  default     = {}
}

variable "queues" {
  description = "Map of SQS queues to create. See module README for schema."
  type        = any
}
