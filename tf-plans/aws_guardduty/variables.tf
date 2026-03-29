# ── GuardDuty wrapper variables ───────────────────────────────────────────────
# These mirror the root module's input variables so that terraform.tfvars can
# supply values without modifying main.tf.

variable "region" {
  description = "AWS region where GuardDuty resources are deployed."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all taggable GuardDuty resources."
  type        = map(string)
  default     = {}
}

variable "detectors" {
  description = "List of GuardDuty detectors."
  type = list(object({
    key                          = string
    enable                       = optional(bool, true)
    finding_publishing_frequency = optional(string, "SIX_HOURS")
    enable_s3_logs               = optional(bool, true)
    enable_kubernetes            = optional(bool, false)
    enable_malware_protection    = optional(bool, false)
    tags                         = optional(map(string), {})
  }))
  default = []
}

variable "filters" {
  description = "List of GuardDuty finding filters (suppression rules)."
  type = list(object({
    key          = string
    detector_key = string
    name         = string
    description  = optional(string, "")
    action       = optional(string, "NOOP")
    rank         = optional(number, 1)
    criteria = list(object({
      field                 = string
      equals                = optional(list(string))
      not_equals            = optional(list(string))
      greater_than_or_equal = optional(string)
      less_than             = optional(string)
      less_than_or_equal    = optional(string)
    }))
  }))
  default = []
}

variable "ip_sets" {
  description = "List of trusted IP sets."
  type = list(object({
    key          = string
    detector_key = string
    name         = string
    format       = optional(string, "TXT")
    location     = string
    activate     = optional(bool, true)
  }))
  default = []
}

variable "threat_intel_sets" {
  description = "List of custom threat intelligence feeds."
  type = list(object({
    key          = string
    detector_key = string
    name         = string
    format       = optional(string, "TXT")
    location     = string
    activate     = optional(bool, true)
  }))
  default = []
}

variable "publishing_destinations" {
  description = "List of S3 publishing destinations for findings export."
  type = list(object({
    key              = string
    detector_key     = string
    destination_arn  = string
    destination_type = optional(string, "S3")
    kms_key_arn      = string
  }))
  default = []
}

variable "members" {
  description = "List of member accounts to invite to GuardDuty."
  type = list(object({
    key                        = string
    detector_key               = string
    account_id                 = string
    email                      = string
    invite                     = optional(bool, true)
    disable_email_notification = optional(bool, false)
    invitation_message         = optional(string, "You are invited to join GuardDuty managed by the administrator account.")
  }))
  default = []
}
