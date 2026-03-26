# Variables for AWS EventBridge wrapper
# Mirror the module variable types exactly.

variable "region" {
  description = "AWS region where EventBridge resources are deployed."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all EventBridge resources."
  type        = map(string)
  default     = {}
}

variable "event_buses" {
  description = "List of custom event bus definitions. See module README for full schema."
  type = list(object({
    key         = string
    name        = string
    policy_json = optional(string)
    tags        = optional(map(string), {})
  }))
  default = []
}

variable "archives" {
  description = "List of event archive definitions. See module README for full schema."
  type = list(object({
    key              = string
    name             = string
    description      = optional(string, "")
    bus_key          = optional(string)
    event_source_arn = optional(string)
    retention_days   = optional(number, 0)
    event_pattern    = optional(string)
  }))
  default = []
}
