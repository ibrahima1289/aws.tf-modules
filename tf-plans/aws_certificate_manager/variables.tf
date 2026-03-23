variable "region" {
  description = "AWS region where ACM resources are managed"
  type        = string
}

variable "tags" {
  description = "Common tags for all ACM resources"
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
}
