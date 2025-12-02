variable "region" {
  description = "AWS region where KMS keys will be created."
  type        = string
}

variable "tags" {
  description = "Global tags applied to KMS resources."
  type        = map(string)
  default     = {}
}

variable "keys" {
  description = "List of KMS key definitions and optional settings."
  type = list(object({
    name                               = string
    description                        = optional(string)
    key_usage                          = optional(string)
    key_spec                           = optional(string)
    policy_json                        = optional(string)
    deletion_window_in_days            = optional(number)
    enable_key_rotation                = optional(bool)
    is_enabled                         = optional(bool)
    multi_region                       = optional(bool)
    bypass_policy_lockout_safety_check = optional(bool)
    aliases                            = optional(list(string))
    tags                               = optional(map(string))
  }))
}

variable "grants" {
  description = "List of KMS grant definitions bound to keys."
  type = list(object({
    name                      = string
    key_name                  = string
    grantee_principal         = string
    operations                = list(string)
    retiring_principal        = optional(string)
    encryption_context_equals = optional(map(string))
    encryption_context_subset = optional(map(string))
  }))
  default = []
}
