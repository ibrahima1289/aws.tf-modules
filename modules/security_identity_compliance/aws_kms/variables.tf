# Variables for AWS KMS Module

variable "region" {
  description = "AWS region in which to create KMS keys."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all KMS resources."
  type        = map(string)
  default     = {}
}

# KMS keys definition list
# Each object supports:
# - name (string, required): Logical name for tagging and lookups
# - description (optional)
# - key_usage (optional): ENCRYPT_DECRYPT | SIGN_VERIFY
# - key_spec (optional): SYMMETRIC_DEFAULT | RSA_2048 | RSA_3072 | RSA_4096 | ECC_NIST_P256 | ECC_NIST_P384 | ECC_NIST_P521 | ECC_SECG_P256K1 | HMAC_224 | HMAC_256 | HMAC_384 | HMAC_512
# - policy_json (optional)
# - deletion_window_in_days (optional)
# - enable_key_rotation (optional; true only for SYMMETRIC_DEFAULT)
# - is_enabled (optional)
# - multi_region (optional)
# - bypass_policy_lockout_safety_check (optional)
# - aliases (optional list of strings): alias names without the alias/ prefix
# - tags (optional map)
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

# KMS grants configuration
# Each grant object supports:
# - name (string, required): A unique name for the grant resource
# - key_name (string, required): Matches an entry in var.keys.name
# - grantee_principal (string, required): IAM principal ARN receiving the grant
# - operations (list(string), required): e.g., ["Encrypt","Decrypt","GenerateDataKey"]
# - retiring_principal (optional string)
# - encryption_context_equals (optional map)
# - encryption_context_subset (optional map)
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
