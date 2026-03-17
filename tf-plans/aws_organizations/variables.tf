variable "region" {
  description = "AWS region used by provider"
  type        = string
}

# Keep default false for safety in existing environments.
variable "create_organization" {
  description = "Set true to create an AWS Organization; false to use existing"
  type        = bool
  default     = false
}

# Organization-level settings when create_organization = true.
variable "organization" {
  description = "Organization settings"
  type = object({
    feature_set                   = optional(string, "ALL")
    aws_service_access_principals = optional(list(string), [])
    enabled_policy_types          = optional(list(string), ["SERVICE_CONTROL_POLICY"])
  })
  default = {}
}

# Common resource tags.
variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Multiple organizational units.
variable "organizational_units" {
  description = "List of organizational units"
  type = list(object({
    key        = string
    name       = string
    parent_key = optional(string, "ROOT")
    tags       = optional(map(string), {})
  }))
  default = []
}

# Multiple member accounts.
variable "accounts" {
  description = "List of organization member accounts"
  type = list(object({
    key                        = string
    name                       = string
    email                      = string
    parent_key                 = optional(string, "ROOT")
    role_name                  = optional(string, "OrganizationAccountAccessRole")
    iam_user_access_to_billing = optional(string, "ALLOW")
    close_on_deletion          = optional(bool, false)
    tags                       = optional(map(string), {})
  }))
  default = []
}

# Multiple organizations policies.
variable "policies" {
  description = "List of organizations policies"
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "Managed by Terraform")
    type        = optional(string, "SERVICE_CONTROL_POLICY")
    content     = string
    tags        = optional(map(string), {})
  }))
  default = []
}

# Policy attachments to ROOT, OU, or ACCOUNT.
variable "policy_attachments" {
  description = "List of policy attachments"
  type = list(object({
    key         = string
    policy_key  = string
    target_type = string
    target_key  = string
  }))
  default = []
}
