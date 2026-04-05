variable "region" {
  description = "AWS region used by the provider"
  type        = string
}

# Controls whether the module creates a new organization or uses an existing one.
variable "create_organization" {
  description = "Set true to create an AWS Organization (management account only); false to use an existing organization"
  type        = bool
  default     = false
}

# Base organization settings used only when create_organization = true.
variable "organization" {
  description = "Organization-level settings"
  type = object({
    feature_set                   = optional(string, "ALL")
    aws_service_access_principals = optional(list(string), [])
    enabled_policy_types          = optional(list(string), ["SERVICE_CONTROL_POLICY"])
  })
  default = {}

  validation {
    condition     = contains(["ALL", "CONSOLIDATED_BILLING"], var.organization.feature_set)
    error_message = "organization.feature_set must be ALL or CONSOLIDATED_BILLING."
  }
}

# Common tags applied to taggable resources created by this module.
variable "tags" {
  description = "Common tags for module resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

# Multiple OUs; use parent_key = ROOT for top-level OUs or another OU key for nesting.
variable "organizational_units" {
  description = "List of organizational units to create"
  type = list(object({
    key        = string
    name       = string
    parent_key = optional(string, "ROOT")
    tags       = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length(distinct([for ou in var.organizational_units : ou.key])) == length(var.organizational_units)
    error_message = "organizational_units keys must be unique."
  }
}

# Multiple member accounts; parent_key can be ROOT or an OU key from organizational_units.
variable "accounts" {
  description = "List of organization member accounts to create"
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

  validation {
    condition     = length(distinct([for a in var.accounts : a.key])) == length(var.accounts)
    error_message = "accounts keys must be unique."
  }

  validation {
    condition = alltrue([
      for a in var.accounts : can(regex("^[^@\n\r\t ]+@[^@\n\r\t ]+\\.[^@\n\r\t ]+$", a.email))
    ])
    error_message = "Each accounts.email value must be a valid email address."
  }

  validation {
    condition = alltrue([
      for a in var.accounts : contains(["ALLOW", "DENY"], a.iam_user_access_to_billing)
    ])
    error_message = "accounts.iam_user_access_to_billing must be ALLOW or DENY."
  }
}

# Multiple organization policies (SCP, TAG_POLICY, BACKUP_POLICY, etc.).
variable "policies" {
  description = "List of organizations policies to create"
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "Managed by Terraform")
    type        = optional(string, "SERVICE_CONTROL_POLICY")
    content     = string
    tags        = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length(distinct([for p in var.policies : p.key])) == length(var.policies)
    error_message = "policies keys must be unique."
  }

  validation {
    condition = alltrue([
      for p in var.policies : contains([
        "SERVICE_CONTROL_POLICY",
        "RESOURCE_CONTROL_POLICY",
        "DECLARATIVE_POLICY_EC2",
        "BACKUP_POLICY",
        "TAG_POLICY",
        "CHATBOT_POLICY",
        "AISERVICES_OPT_OUT_POLICY"
      ], p.type)
    ])
    error_message = "policies.type must be a valid Organizations policy type supported by the AWS provider."
  }

  validation {
    condition     = alltrue([for p in var.policies : can(jsondecode(p.content))])
    error_message = "Each policy content must be valid JSON."
  }
}

# Attach policies to root, OUs, or accounts created by this module.
variable "policy_attachments" {
  description = "List of policy attachments"
  type = list(object({
    key         = string
    policy_key  = string
    target_type = string # ROOT | OU | ACCOUNT
    target_key  = string # ignored for ROOT; OU key for OU; account key for ACCOUNT
  }))
  default = []

  validation {
    condition     = length(distinct([for a in var.policy_attachments : a.key])) == length(var.policy_attachments)
    error_message = "policy_attachments keys must be unique."
  }

  validation {
    condition = alltrue([
      for a in var.policy_attachments : contains(["ROOT", "OU", "ACCOUNT"], a.target_type)
    ])
    error_message = "policy_attachments.target_type must be ROOT, OU, or ACCOUNT."
  }
}
