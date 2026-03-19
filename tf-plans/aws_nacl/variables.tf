variable "region" {
  description = "AWS region where NACL resources will be created"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "nacls" {
  description = "List of Network ACL definitions"
  type = list(object({
    key        = string
    name       = optional(string, "")
    vpc_id     = string
    subnet_ids = optional(list(string), [])
    tags       = optional(map(string), {})
    ingress_rules = optional(list(object({
      rule_number     = number
      protocol        = string
      rule_action     = string
      from_port       = optional(number, 0)
      to_port         = optional(number, 0)
      cidr_block      = optional(string, "")
      ipv6_cidr_block = optional(string, "")
    })), [])
    egress_rules = optional(list(object({
      rule_number     = number
      protocol        = string
      rule_action     = string
      from_port       = optional(number, 0)
      to_port         = optional(number, 0)
      cidr_block      = optional(string, "")
      ipv6_cidr_block = optional(string, "")
    })), [])
  }))
  default = []
}
