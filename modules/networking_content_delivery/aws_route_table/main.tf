############################################
# AWS Route Tables (Single or Multiple)
# - Creates one or more route tables in a VPC
# - Supports routes to IGW, NAT, TGW, VPC Peering, ENI, Instance, Egress-only, Local GW, VPC Endpoint, Prefix Lists
# - Associates each table to subnets by explicit IDs or by group (public/private)
# - Optionally set one table as the VPC's main route table
# - No data sources; all IDs provided via variables
#
# Required:
# - `vpc_id`
# - `region`
############################################

locals {
  # Normalize route table definitions without using multi-line ternary
  rt_defs = merge(
    length(var.route_tables) > 0 ? { for idx, rt in var.route_tables : coalesce(try(rt.name, null), "rt-${idx}") => rt } : {},
    length(var.route_tables) == 0 ? {
      (var.name != null ? var.name : "rt-0") = {
        name        = var.name
        tags        = var.tags
        routes      = var.routes
        subnet_ids  = var.subnet_ids
        set_as_main = var.set_as_main
      }
    } : {}
  )

  # Build a flattened list of routes across all route tables
  rt_route_list = flatten([
    for rt_key, rt in local.rt_defs : [
      for idx, r in try(rt.routes, []) : {
        key    = "${rt_key}:${tostring(idx)}"
        rt_key = rt_key
        route  = r
      }
    ]
  ])

  # Determine associations per route table, resolving subnet group or explicit subnet_ids
  rt_assoc_list = flatten([
    for rt_key, rt in local.rt_defs : [
      for s in(
        length(coalesce(try(rt.subnet_ids, []), [])) > 0
        ? coalesce(try(rt.subnet_ids, []), [])
        : (
          try(rt.subnet_group, null) == "public" ? var.public_subnet_ids : (
            try(rt.subnet_group, null) == "private" ? var.private_subnet_ids : []
          )
        )
        ) : {
        key    = "${rt_key}:${s}"
        rt_key = rt_key
        subnet = s
      }
    ]
  ])

  # Identify the main route table key (first one with set_as_main = true)
  rt_main_keys = [for rt_key, rt in local.rt_defs : rt_key if try(rt.set_as_main, false)]
  main_rt_key  = length(local.rt_main_keys) > 0 ? local.rt_main_keys[0] : null
}

# Route Tables
resource "aws_route_table" "route_table" {
  for_each = local.rt_defs

  vpc_id = var.vpc_id

  tags = merge(
    local.base_tags,
    try(each.value.name, null) != null ? { Name = each.value.name } : {},
    try(each.value.tags, {}),
  )
}

# Routes
resource "aws_route" "routes" {
  for_each = { for item in local.rt_route_list : item.key => item }

  route_table_id              = aws_route_table.route_table[each.value.rt_key].id
  destination_cidr_block      = try(each.value.route.destination_cidr_block, null)
  destination_ipv6_cidr_block = try(each.value.route.destination_ipv6_cidr_block, null)
  destination_prefix_list_id  = try(each.value.route.destination_prefix_list_id, null)

  # Only one of the following target attributes should be set per route
  gateway_id                = try(each.value.route.gateway_id, null)
  nat_gateway_id            = try(each.value.route.nat_gateway_id, null)
  transit_gateway_id        = try(each.value.route.transit_gateway_id, null)
  vpc_peering_connection_id = try(each.value.route.vpc_peering_connection_id, null)
  egress_only_gateway_id    = try(each.value.route.egress_only_gateway_id, null)
  network_interface_id      = try(each.value.route.network_interface_id, null)
  local_gateway_id          = try(each.value.route.local_gateway_id, null)
  vpc_endpoint_id           = try(each.value.route.vpc_endpoint_id, null)
}

# Associations
resource "aws_route_table_association" "subnets" {
  for_each = { for item in local.rt_assoc_list : item.key => item }

  subnet_id      = each.value.subnet
  route_table_id = aws_route_table.route_table[each.value.rt_key].id
}

# Main Route Table Association
resource "aws_main_route_table_association" "main" {
  count          = local.main_rt_key != null ? 1 : 0
  vpc_id         = var.vpc_id
  route_table_id = aws_route_table.route_table[local.main_rt_key].id
}
############################################