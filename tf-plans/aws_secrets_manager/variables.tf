variable "region" {
  description = "AWS region where Secrets Manager secrets will be created."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Secrets Manager resources."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "List of secret definitions. Each entry creates one secret and its optional supporting resources."
  type = list(object({
    key                     = string
    name                    = string
    description             = optional(string)
    kms_key_id              = optional(string)
    recovery_window_in_days = optional(number, 30)
    secret_string           = optional(string)
    rotation_lambda_arn     = optional(string)
    rotation_days           = optional(number, 30)
    policy                  = optional(string)
    replica_regions = optional(list(object({
      region     = string
      kms_key_id = optional(string)
    })))
    tags = optional(map(string))
  }))
}
