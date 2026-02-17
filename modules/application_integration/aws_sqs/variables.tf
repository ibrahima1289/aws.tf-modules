// Input variables for AWS SQS module

variable "region" {
  description = "AWS region to use for the SQS queues."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all SQS resources."
  type        = map(string)
  default     = {}
}

variable "queues" {
  description = "Map of SQS queues to create (key is a logical name)."
  type = map(object({
    name                        = string
    fifo_queue                  = optional(bool)
    content_based_deduplication = optional(bool)
    delay_seconds               = optional(number)
    maximum_message_size        = optional(number)
    message_retention_seconds   = optional(number)
    receive_wait_time_seconds   = optional(number)
    visibility_timeout_seconds  = optional(number)

    # Dead-letter queue configuration
    redrive_policy = optional(object({
      dead_letter_target_arn = string
      max_receive_count      = number
    }))

    # Server-side encryption
    kms_master_key_id                 = optional(string)
    kms_data_key_reuse_period_seconds = optional(number)

    # Optional policy JSON to attach to the queue
    policy_json = optional(string)

    # Per-queue tags
    tags = optional(map(string))
  }))
}
