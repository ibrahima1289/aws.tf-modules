variable "region" {
  description = "AWS region for the AWS provider. Use 'us-east-1' when protecting CloudFront or Route 53 resources."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Shield Advanced resources."
  type        = map(string)
  default     = {}
}

variable "enable_subscription" {
  description = "Set to true to manage the Shield Advanced subscription via Terraform. WARNING: $3,000/month minimum commitment."
  type        = bool
  default     = false
}

variable "subscription_auto_renew" {
  description = "Shield Advanced subscription auto-renewal. ENABLED or DISABLED."
  type        = string
  default     = "ENABLED"
}

variable "protections" {
  description = "List of Shield Advanced protection definitions."
  type = list(object({
    key          = string
    name         = string
    resource_arn = string
    tags         = optional(map(string))
  }))
  default = []
}

variable "protection_groups" {
  description = "List of Shield Advanced protection group definitions."
  type = list(object({
    key                 = string
    protection_group_id = string
    aggregation         = string
    pattern             = string
    resource_type       = optional(string)
    member_keys         = optional(list(string))
    tags                = optional(map(string))
  }))
  default = []
}

variable "drt_role_arn" {
  description = "IAM role ARN for DRT access. Must trust shield.amazonaws.com."
  type        = string
  default     = null
}

variable "drt_log_buckets" {
  description = "S3 bucket names the DRT can access for attack log analysis."
  type        = list(string)
  default     = []
}

variable "proactive_engagement_enabled" {
  description = "Enable DRT proactive engagement on attack detection."
  type        = bool
  default     = false
}

variable "emergency_contacts" {
  description = "Emergency contacts for DRT proactive engagement."
  type = list(object({
    email_address = string
    phone_number  = optional(string)
    contact_notes = optional(string)
  }))
  default = []
}
