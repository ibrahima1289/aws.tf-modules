variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Tags to apply to all resources. WARNING: Omitting tags will affect cost allocation and compliance visibility."
  type        = map(string)
  default     = {}
  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include Environment and Owner keys for cost allocation and governance."
  }
}
