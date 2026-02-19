// Input variables for AWS MQ wrapper plan

variable "region" {
  description = "AWS region to deploy Amazon MQ brokers in."
  type        = string
}

variable "tags" {
  description = "Global tags for all Amazon MQ resources."
  type        = map(string)
  default     = {}
}

variable "brokers" {
  description = "Map of Amazon MQ brokers to create. See module README for schema."
  type        = any
}
