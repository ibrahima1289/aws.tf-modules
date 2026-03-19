variable "region" {
  description = "AWS region where NACL resources are managed"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all NACL resources"
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

  validation {
    condition     = length(distinct([for n in var.nacls : n.key])) == length(var.nacls)
    error_message = "Each NACL key must be unique."
  }

  validation {
    condition = alltrue([
      for n in var.nacls : length(distinct([for r in n.ingress_rules : r.rule_number])) == length(n.ingress_rules)
    ])
    error_message = "Ingress rule_number values must be unique per NACL."
  }

  validation {
    condition = alltrue([
      for n in var.nacls : length(distinct([for r in n.egress_rules : r.rule_number])) == length(n.egress_rules)
    ])
    error_message = "Egress rule_number values must be unique per NACL."
  }

  validation {
    condition = alltrue(flatten([
      for n in var.nacls : [
        for r in concat(n.ingress_rules, n.egress_rules) : contains(["allow", "deny"], lower(r.rule_action))
      ]
    ]))
    error_message = "rule_action must be ALLOW or DENY for every rule."
  }

  validation {
    condition = alltrue(flatten([
      for n in var.nacls : [
        for r in concat(n.ingress_rules, n.egress_rules) : (trimspace(r.cidr_block) != "") != (trimspace(r.ipv6_cidr_block) != "")
      ]
    ]))
    error_message = "Each rule must set exactly one of cidr_block or ipv6_cidr_block."
  }

  validation {
    condition = alltrue(flatten([
      for n in var.nacls : [
        for r in concat(n.ingress_rules, n.egress_rules) : r.from_port <= r.to_port
      ]
    ]))
    error_message = "from_port must be less than or equal to to_port."
  }
}
