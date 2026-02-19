// Input variables for AWS MSK wrapper plan

variable "region" {
  description = "AWS region to deploy MSK clusters in."
  type        = string
}

variable "tags" {
  description = "Global tags for all MSK resources."
  type        = map(string)
  default     = {}
}

variable "clusters" {
  description = "Map of MSK clusters to create. See module README for schema."
  type        = any
}