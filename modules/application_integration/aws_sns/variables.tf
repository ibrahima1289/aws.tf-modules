// Input variables for AWS SNS module

variable "region" {
  description = "AWS region to use for SNS topics."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Global tags applied to all SNS resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

variable "topics" {
  description = "Map of SNS topics to create (key is a logical name)."
  type = map(object({
    name                        = string
    fifo_topic                  = optional(bool)
    content_based_deduplication = optional(bool)
    display_name                = optional(string)
    kms_master_key_id           = optional(string)
    policy_json                 = optional(string)
    delivery_policy             = optional(string)
    tags                        = optional(map(string))

    // Optional subscriptions for this topic
    subscriptions = optional(list(object({
      protocol             = string
      endpoint             = string
      raw_message_delivery = optional(bool)
      filter_policy        = optional(string)
      redrive_policy_arn   = optional(string) // SQS DLQ ARN for this subscription
    })))
  }))
}
