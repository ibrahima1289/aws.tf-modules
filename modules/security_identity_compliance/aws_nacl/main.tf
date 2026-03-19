# Create one or more Network ACLs.
resource "aws_network_acl" "nacl" {
  for_each = local.nacls_map

  vpc_id = each.value.vpc_id

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name != "" ? each.value.name : each.value.key
  })
}

# Associate each NACL with one or more subnets.
resource "aws_network_acl_association" "association" {
  for_each = local.subnet_associations_map

  subnet_id      = each.value.subnet_id
  network_acl_id = aws_network_acl.nacl[each.value.nacl_key].id
}

# Create IPv4 ingress rules for each NACL.
resource "aws_network_acl_rule" "ingress_ipv4" {
  for_each = local.ingress_ipv4_rules_map

  network_acl_id = aws_network_acl.nacl[each.value.nacl_key].id
  egress         = false
  rule_number    = each.value.rule_number
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Create IPv6 ingress rules for each NACL.
resource "aws_network_acl_rule" "ingress_ipv6" {
  for_each = local.ingress_ipv6_rules_map

  network_acl_id  = aws_network_acl.nacl[each.value.nacl_key].id
  egress          = false
  rule_number     = each.value.rule_number
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  ipv6_cidr_block = each.value.ipv6_cidr_block
  from_port       = each.value.from_port
  to_port         = each.value.to_port
}

# Create IPv4 egress rules for each NACL.
resource "aws_network_acl_rule" "egress_ipv4" {
  for_each = local.egress_ipv4_rules_map

  network_acl_id = aws_network_acl.nacl[each.value.nacl_key].id
  egress         = true
  rule_number    = each.value.rule_number
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

# Create IPv6 egress rules for each NACL.
resource "aws_network_acl_rule" "egress_ipv6" {
  for_each = local.egress_ipv6_rules_map

  network_acl_id  = aws_network_acl.nacl[each.value.nacl_key].id
  egress          = true
  rule_number     = each.value.rule_number
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  ipv6_cidr_block = each.value.ipv6_cidr_block
  from_port       = each.value.from_port
  to_port         = each.value.to_port
}
