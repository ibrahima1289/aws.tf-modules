// Input variables for AWS SNS wrapper plan

variable "region" {
  description = "AWS region to deploy SNS topics in."
  type        = string
}

variable "tags" {
  description = "Global tags for all SNS resources."
  type        = map(string)
  default     = {}
}

variable "topics" {
  description = "Map of SNS topics to create. See module README for schema."
  type        = any
}
