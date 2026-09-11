variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (e.g. us-east-1, eu-west-2)."
  }
}

variable "users" {
  description = "List of user objects. Each object supports: name (required), path, force_destroy, permissions_boundary, tags, create_access_key, access_key_pgp_key, access_key_status, access_key_description."
  type = list(object({
    name                   = string
    path                   = optional(string)
    force_destroy          = optional(bool)
    permissions_boundary   = optional(string)
    tags                   = optional(map(string))
    create_access_key      = optional(bool)
    access_key_pgp_key     = optional(string)
    access_key_status      = optional(string)
    access_key_description = optional(string)
  }))
}

variable "groups" {
  description = "List of group objects. Each object supports: name (required), path."
  type = list(object({
    name = string
    path = optional(string)
  }))
}

variable "user_group_memberships" {
  description = "List of user-group membership objects. Each object supports: user (user name), groups (list of group names)."
  type = list(object({
    user   = string
    groups = list(string)
  }))
}

variable "policies" {
  description = "List of policy objects. Each object supports: name (required), path, description, policy_json."
  type = list(object({
    name        = string
    path        = optional(string)
    description = optional(string)
    policy_json = string
  }))
}

variable "group_policy_attachments" {
  description = "List of group-policy attachment objects. Each object supports: group (group name), policy (policy name)."
  type = list(object({
    group  = string
    policy = string
  }))
}

variable "tags" {
  description = "Tags to apply to all users."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}
