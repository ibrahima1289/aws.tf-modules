# Wrapper variables for aws_network_firewall tf-plan.
# These mirror the root module variables exactly so that terraform.tfvars
# values flow straight through to the module without transformation.

variable "region" {
  description = "AWS region in which to deploy Network Firewall resources."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "rule_groups" {
  description = "List of Network Firewall rule group definitions."
  type = list(object({
    key               = string
    name              = string
    type              = string
    capacity          = number
    description       = optional(string, "")
    rules_source_type = string

    stateless_rules = optional(list(object({
      priority          = number
      actions           = list(string)
      sources           = optional(list(string), ["0.0.0.0/0"])
      destinations      = optional(list(string), ["0.0.0.0/0"])
      protocols         = optional(list(number), [])
      source_ports      = optional(list(object({ from_port = number, to_port = number })), [])
      destination_ports = optional(list(object({ from_port = number, to_port = number })), [])
      tcp_flags         = optional(list(object({ flags = list(string), masks = list(string) })), [])
    })))

    rules_string = optional(string)

    domain_list = optional(object({
      generated_rules_type = string
      target_types         = list(string)
      targets              = list(string)
    }))

    stateful_rules = optional(list(object({
      action           = string
      protocol         = string
      source           = string
      source_port      = string
      destination      = string
      destination_port = string
      direction        = string
      rule_options = list(object({
        keyword  = string
        settings = optional(list(string), [])
      }))
    })))

    ip_sets = optional(list(object({
      key        = string
      definition = list(string)
    })), [])

    port_sets = optional(list(object({
      key        = string
      definition = list(string)
    })), [])

    rule_order = optional(string)
    tags       = optional(map(string), {})
  }))
  default = []
}

variable "policies" {
  description = "List of Network Firewall policy definitions."
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "")

    stateless_default_actions          = optional(list(string), ["aws:forward_to_sfe"])
    stateless_fragment_default_actions = optional(list(string), ["aws:forward_to_sfe"])

    stateless_rule_group_references = optional(list(object({
      key          = optional(string)
      resource_arn = optional(string)
      priority     = number
    })), [])

    stateful_rule_group_references = optional(list(object({
      key             = optional(string)
      resource_arn    = optional(string)
      priority        = optional(number)
      override_action = optional(string)
    })), [])

    stateful_engine_options  = optional(object({ rule_order = string }))
    stateful_default_actions = optional(list(string), [])
    policy_variables         = optional(map(list(string)))

    tls_inspection_configuration_arn = optional(string)
    tags                             = optional(map(string), {})
  }))
  default = []
}

variable "firewalls" {
  description = "List of Network Firewall definitions."
  type = list(object({
    key    = string
    name   = string
    vpc_id = string

    subnet_ids = list(string)

    firewall_policy_arn               = optional(string)
    firewall_policy_key               = optional(string)
    delete_protection                 = optional(bool, false)
    subnet_change_protection          = optional(bool, false)
    firewall_policy_change_protection = optional(bool, false)
    description                       = optional(string, "")

    encryption_configuration = optional(object({
      type   = string
      key_id = optional(string)
    }))

    logging = optional(object({
      destinations = list(object({
        log_type             = string
        log_destination_type = string
        log_destination      = map(string)
      }))
    }))

    tags = optional(map(string), {})
  }))
}
