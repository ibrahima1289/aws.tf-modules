variable "region" {
  description = "AWS region where ACM resources are managed"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all ACM resources"
  type        = map(string)
  default     = {}
}

variable "certificates" {
  description = "List of ACM certificate definitions"
  type = list(object({
    key                                         = string
    type                                        = optional(string, "AMAZON_ISSUED")
    domain_name                                 = optional(string, "")
    validation_method                           = optional(string, "DNS")
    subject_alternative_names                   = optional(list(string), [])
    key_algorithm                               = optional(string, "RSA_2048")
    certificate_transparency_logging_preference = optional(string, "")
    certificate_body                            = optional(string, "")
    private_key                                 = optional(string, "")
    certificate_chain                           = optional(string, "")
    validate_certificate                        = optional(bool, false)
    validation_record_fqdns                     = optional(list(string), [])
    tags                                        = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length(distinct([for c in var.certificates : c.key])) == length(var.certificates)
    error_message = "Each certificate key must be unique."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : contains(["AMAZON_ISSUED", "IMPORTED"], upper(c.type))
    ])
    error_message = "type must be AMAZON_ISSUED or IMPORTED."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : upper(c.type) == "IMPORTED" || trimspace(c.domain_name) != ""
    ])
    error_message = "domain_name is required when type is AMAZON_ISSUED."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : upper(c.type) == "IMPORTED" || contains(["DNS", "EMAIL"], upper(c.validation_method))
    ])
    error_message = "validation_method must be DNS or EMAIL for AMAZON_ISSUED certificates."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : upper(c.type) == "IMPORTED" || contains(["RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], c.key_algorithm)
    ])
    error_message = "key_algorithm must be one of RSA_1024, RSA_2048, RSA_3072, RSA_4096, EC_prime256v1, EC_secp384r1, EC_secp521r1."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : upper(c.type) == "IMPORTED" || trimspace(c.certificate_body) == ""
    ])
    error_message = "certificate_body is only valid when type is IMPORTED."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : upper(c.type) == "IMPORTED" || trimspace(c.private_key) == ""
    ])
    error_message = "private_key is only valid when type is IMPORTED."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : upper(c.type) == "AMAZON_ISSUED" || (trimspace(c.certificate_body) != "" && trimspace(c.private_key) != "")
    ])
    error_message = "certificate_body and private_key are required when type is IMPORTED."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : trimspace(c.certificate_transparency_logging_preference) == "" || contains(["ENABLED", "DISABLED"], upper(c.certificate_transparency_logging_preference))
    ])
    error_message = "certificate_transparency_logging_preference must be ENABLED, DISABLED, or empty."
  }

  validation {
    condition = alltrue([
      for c in var.certificates : !c.validate_certificate || (
        upper(c.type) == "AMAZON_ISSUED" &&
        upper(c.validation_method) == "DNS" &&
        length(c.validation_record_fqdns) > 0
      )
    ])
    error_message = "validate_certificate requires AMAZON_ISSUED + DNS + non-empty validation_record_fqdns."
  }
}
