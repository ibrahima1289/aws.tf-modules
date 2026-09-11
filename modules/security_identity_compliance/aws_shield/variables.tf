# Variables for AWS Shield Advanced Module

variable "region" {
  description = "AWS region for the AWS provider. Use 'us-east-1' when protecting global resources (CloudFront, Route 53)."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Shield Advanced resources that support tagging."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Shield Advanced Subscription
# ─────────────────────────────────────────────────────────────────────────────

variable "enable_subscription" {
  description = <<-EOT
    Set to true to create or manage the Shield Advanced subscription via Terraform.
    ⚠️  WARNING: Shield Advanced costs $3,000/month minimum with a 1-year commitment.
    Most teams enable it via the console or AWS Organizations and leave this false,
    managing only protections and groups with Terraform.
  EOT
  type        = bool
  default     = false
}

variable "subscription_auto_renew" {
  description = "Controls whether the Shield Advanced subscription auto-renews. ENABLED or DISABLED."
  type        = string
  default     = "DISABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.subscription_auto_renew)
    error_message = "subscription_auto_renew must be 'ENABLED' or 'DISABLED'."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Protections — one per protected resource ARN
# Each object supports:
# - key (string, required)          : Stable map key for for_each — must be unique.
# - name (string, required)         : Friendly name shown in the Shield console.
# - resource_arn (string, required) : ARN of the resource to protect.
#     Supported: ALB, NLB, EIP, CloudFront, Route 53 Hosted Zone, Global Accelerator.
# - tags (optional)                 : Per-protection tags merged with global tags.
# ─────────────────────────────────────────────────────────────────────────────
variable "protections" {
  description = "List of Shield Advanced protection definitions. Each entry protects one AWS resource."
  type = list(object({
    key          = string
    name         = string
    resource_arn = string
    tags         = optional(map(string))
  }))
  default = []

  validation {
    condition     = length([for p in var.protections : p.key]) == length(toset([for p in var.protections : p.key]))
    error_message = "Each protection must have a unique 'key'."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Protection Groups — aggregate multiple protections for joint reporting/management
# Each object supports:
# - key (string, required)                  : Stable map key for for_each — must be unique.
# - protection_group_id (string, required)  : Unique group identifier in Shield.
# - aggregation (string, required)          : SUM | MEAN | MAX — how attack metrics are aggregated.
# - pattern (string, required)              : ALL | BY_RESOURCE_TYPE | ARBITRARY
# - resource_type (string, optional)        : Required when pattern = BY_RESOURCE_TYPE.
#     One of: CLOUDFRONT_DISTRIBUTION | ROUTE_53_HOSTED_ZONE | ELASTIC_IP_ALLOCATION |
#             CLASSIC_LOAD_BALANCER | APPLICATION_LOAD_BALANCER | GLOBAL_ACCELERATOR
# - member_keys (list(string), optional)    : Required when pattern = ARBITRARY.
#     Must reference keys defined in var.protections.
# - tags (optional)                         : Per-group tags merged with global tags.
# ─────────────────────────────────────────────────────────────────────────────
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

  validation {
    condition     = length([for g in var.protection_groups : g.key]) == length(toset([for g in var.protection_groups : g.key]))
    error_message = "Each protection_group must have a unique 'key'."
  }

  validation {
    condition = alltrue([
      for g in var.protection_groups : contains(["SUM", "MEAN", "MAX"], g.aggregation)
    ])
    error_message = "protection_group.aggregation must be one of: SUM, MEAN, MAX."
  }

  validation {
    condition = alltrue([
      for g in var.protection_groups : contains(["ALL", "BY_RESOURCE_TYPE", "ARBITRARY"], g.pattern)
    ])
    error_message = "protection_group.pattern must be one of: ALL, BY_RESOURCE_TYPE, ARBITRARY."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# DRT (DDoS Response Team) Access
# ─────────────────────────────────────────────────────────────────────────────

variable "drt_role_arn" {
  description = "ARN of an IAM role that allows the DRT to act on your behalf during a DDoS event. The role must trust 'shield.amazonaws.com'. Set to null to skip."
  type        = string
  default     = null
}

variable "drt_log_buckets" {
  description = "List of S3 bucket names the DRT should have read access to for attack log analysis. Requires drt_role_arn to be set."
  type        = list(string)
  default     = []
}

# ─────────────────────────────────────────────────────────────────────────────
# Proactive Engagement
# ─────────────────────────────────────────────────────────────────────────────

variable "proactive_engagement_enabled" {
  description = "Set to true to allow the DRT to contact your emergency contacts automatically when an attack is detected."
  type        = bool
  default     = false
}

variable "emergency_contacts" {
  description = "List of emergency contacts for DRT proactive engagement. At least one is required when proactive_engagement_enabled = true."
  type = list(object({
    email_address = string
    phone_number  = optional(string)
    contact_notes = optional(string)
  }))
  default = []
}
