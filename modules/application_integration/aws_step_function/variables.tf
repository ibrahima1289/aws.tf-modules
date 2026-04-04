// Input variables for AWS Step Functions module

variable "region" {
  description = "AWS region to deploy Step Functions state machines in."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "tags" {
  description = "Global tags applied to all Step Functions resources."
  type        = map(string)
  default     = {}
}

variable "state_machines" {
  description = "Map of Step Functions state machines to create. Keys are logical names; values define configuration."
  type = map(object({
    name                           = string
    role_arn                       = string
    definition                     = string
    type                           = optional(string) # STANDARD or EXPRESS
    logging_enabled                = optional(bool)
    logging_level                  = optional(string)
    logging_include_execution_data = optional(bool)
    logging_log_group_arn          = optional(string)
    tracing_enabled                = optional(bool)
    kms_key_arn                    = optional(string)
    tags                           = optional(map(string))
  }))
  default = {}
}
