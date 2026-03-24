# Variables for AWS Secrets Manager Module

variable "region" {
  description = "AWS region in which to create Secrets Manager secrets."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Secrets Manager resources."
  type        = map(string)
  default     = {}
}

# Secrets definition list.
# Each object represents one secret container with optional value, rotation, policy, and replication.
# Fields per entry:
# - key (string, required)                 : Stable map key for for_each — must be unique across the list.
# - name (string, required)                : The Secrets Manager secret name (path-style recommended, e.g. prod/app/db).
# - description (optional)                 : Human-readable description of what the secret holds.
# - kms_key_id (optional)                  : ARN of a Customer Managed KMS Key. Defaults to AWS-managed key when omitted.
# - recovery_window_in_days (optional, 30) : 0 = force-delete immediately; 7–30 = scheduled deletion window.
# - secret_string (optional)               : Plain-text or JSON string value. Omit if rotation manages the value.
# - rotation_lambda_arn (optional)         : ARN of a Secrets Manager-compatible rotation Lambda.
# - rotation_days (optional, 30)           : How often (in days) the rotation Lambda is invoked (1–365).
# - policy (optional)                      : JSON resource-based policy. Used for cross-account or service access.
# - replica_regions (optional)             : List of { region, kms_key_id } objects for multi-region replication.
# - tags (optional)                        : Per-secret tags merged with global tags.
variable "secrets" {
  description = "List of secret definitions. Each entry creates one aws_secretsmanager_secret and its optional supporting resources."
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

  validation {
    condition     = length([for s in var.secrets : s.key]) == length(toset([for s in var.secrets : s.key]))
    error_message = "Each secret must have a unique 'key'."
  }

  validation {
    condition = alltrue([
      for s in var.secrets : s.recovery_window_in_days == 0 || (s.recovery_window_in_days >= 7 && s.recovery_window_in_days <= 30)
    ])
    error_message = "recovery_window_in_days must be 0 (force-delete) or between 7 and 30."
  }

  validation {
    condition = alltrue([
      for s in var.secrets : s.rotation_days == null || (s.rotation_days >= 1 && s.rotation_days <= 365)
    ])
    error_message = "rotation_days must be between 1 and 365."
  }
}
