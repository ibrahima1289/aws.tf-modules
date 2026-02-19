# Wrapper inputs: region, tags, and state machines to create

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Global tags applied to module resources"
}

# Pass-through inputs for the module
variable "state_machines" {
  type = map(object({
    name                           = string
    role_arn                       = string
    definition                     = string
    type                           = optional(string)
    logging_enabled                = optional(bool)
    logging_level                  = optional(string)
    logging_include_execution_data = optional(bool)
    logging_log_group_arn          = optional(string)
    tracing_enabled                = optional(bool)
    kms_key_arn                    = optional(string)
    tags                           = optional(map(string))
  }))
  default     = {}
  description = "State machines to create"
}
