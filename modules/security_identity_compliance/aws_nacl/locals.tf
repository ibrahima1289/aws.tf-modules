locals {
  # Step 1: Generate immutable created date for consistent tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Apply shared tags everywhere this module supports tags.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert top-level list to map for stable for_each keys.
  nacls_map = { for nacl in var.nacls : nacl.key => nacl }

  # Step 4: Build subnet association map for multi-subnet support per NACL.
  subnet_associations_map = {
    for item in flatten([
      for nacl in var.nacls : [
        for subnet_id in nacl.subnet_ids : {
          key       = "${nacl.key}|${subnet_id}"
          nacl_key  = nacl.key
          subnet_id = subnet_id
        }
      ]
    ]) : item.key => item
  }

  # Step 5: Flatten IPv4/IPv6 ingress and egress rules into dedicated maps.
  ingress_ipv4_rules_map = {
    for item in flatten([
      for nacl in var.nacls : [
        for rule in nacl.ingress_rules : {
          key             = "${nacl.key}|ingress|${rule.rule_number}|ipv4"
          nacl_key        = nacl.key
          rule_number     = rule.rule_number
          protocol        = lower(rule.protocol)
          rule_action     = lower(rule.rule_action)
          from_port       = rule.from_port
          to_port         = rule.to_port
          cidr_block      = rule.cidr_block
          ipv6_cidr_block = rule.ipv6_cidr_block
        }
      ]
    ]) : item.key => item if trimspace(item.cidr_block) != ""
  }

  ingress_ipv6_rules_map = {
    for item in flatten([
      for nacl in var.nacls : [
        for rule in nacl.ingress_rules : {
          key             = "${nacl.key}|ingress|${rule.rule_number}|ipv6"
          nacl_key        = nacl.key
          rule_number     = rule.rule_number
          protocol        = lower(rule.protocol)
          rule_action     = lower(rule.rule_action)
          from_port       = rule.from_port
          to_port         = rule.to_port
          cidr_block      = rule.cidr_block
          ipv6_cidr_block = rule.ipv6_cidr_block
        }
      ]
    ]) : item.key => item if trimspace(item.ipv6_cidr_block) != ""
  }

  egress_ipv4_rules_map = {
    for item in flatten([
      for nacl in var.nacls : [
        for rule in nacl.egress_rules : {
          key             = "${nacl.key}|egress|${rule.rule_number}|ipv4"
          nacl_key        = nacl.key
          rule_number     = rule.rule_number
          protocol        = lower(rule.protocol)
          rule_action     = lower(rule.rule_action)
          from_port       = rule.from_port
          to_port         = rule.to_port
          cidr_block      = rule.cidr_block
          ipv6_cidr_block = rule.ipv6_cidr_block
        }
      ]
    ]) : item.key => item if trimspace(item.cidr_block) != ""
  }

  egress_ipv6_rules_map = {
    for item in flatten([
      for nacl in var.nacls : [
        for rule in nacl.egress_rules : {
          key             = "${nacl.key}|egress|${rule.rule_number}|ipv6"
          nacl_key        = nacl.key
          rule_number     = rule.rule_number
          protocol        = lower(rule.protocol)
          rule_action     = lower(rule.rule_action)
          from_port       = rule.from_port
          to_port         = rule.to_port
          cidr_block      = rule.cidr_block
          ipv6_cidr_block = rule.ipv6_cidr_block
        }
      ]
    ]) : item.key => item if trimspace(item.ipv6_cidr_block) != ""
  }
}
