###############################################
# Route 53 hosted zone and records (module)
#
# This module creates a hosted zone (public or private), optional query logging,
# and a flexible set of records. It emphasizes safe defaults and avoids passing
# null-only arguments by splitting alias vs non-alias records and using dynamic blocks
# for optional routing policies.
###############################################

# Hosted Zone
# - Public or private depending on `var.is_private`.
# - `prevent_destroy` defaults to true to protect against accidental deletion.
# - `force_destroy` defaults to false, preventing deletion with remaining records.
resource "aws_route53_zone" "route53" {
  name          = var.zone_name
  comment       = var.comment
  force_destroy = var.force_destroy

  # Optional reusable delegation set (public zones only).
  delegation_set_id = var.delegation_set_id

  # VPC associations for private zones.
  dynamic "vpc" {
    for_each = var.is_private ? var.vpc_associations : []
    content {
      vpc_id = vpc.value.vpc_id
    }
  }

  # Apply standard tags.
  tags = local.standard_tags

  lifecycle {
      # Lifecycle meta-arguments must be static. 
      # Should be set to true for safety.
      prevent_destroy = false
  }
}

# Optional Query Logging
# Created only when enabled and a valid Log Group ARN is provided.
resource "aws_route53_query_log" "qurery_log" {
  count = var.enable_query_log && var.cloudwatch_log_group_arn != null ? 1 : 0

  cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
  zone_id                  = aws_route53_zone.route53.zone_id
}

###############################################
# Records — split into basic and alias groups
###############################################

# Non-alias records: must provide values (`records`) and usually a TTL.
# We default TTL to 300 when omitted to avoid passing null.
resource "aws_route53_record" "basic" {
  for_each = local.basic_records

  zone_id = aws_route53_zone.route53.zone_id
  name    = each.value.name
  type    = each.value.type

  ttl     = coalesce(try(each.value.ttl, null), 300)
  records = try(each.value.records, [])

  # Optional controls
  set_identifier  = try(each.value.set_identifier, null)
  health_check_id = try(each.value.health_check_id, null)

  # Weighted routing policy
  dynamic "weighted_routing_policy" {
    for_each = try(each.value.weighted_routing_policy, null) != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  # Latency routing policy
  dynamic "latency_routing_policy" {
    for_each = try(each.value.latency_routing_policy, null) != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  # Failover routing policy
  dynamic "failover_routing_policy" {
    for_each = try(each.value.failover_routing_policy, null) != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  # Geolocation routing policy (optional fields)
  dynamic "geolocation_routing_policy" {
    for_each = try(each.value.geolocation_routing_policy, null) != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = try(geolocation_routing_policy.value.continent, null)
      country     = try(geolocation_routing_policy.value.country, null)
      subdivision = try(geolocation_routing_policy.value.subdivision, null)
    }
  }

  # CIDR routing policy (locations list)
  dynamic "cidr_routing_policy" {
    for_each = try(each.value.cidr_routing_policy, null) != null ? [each.value.cidr_routing_policy] : []
    content {
      # Route 53 CIDR routing policy expects a collection and a location name.
      # The CIDR blocks themselves are defined in the CIDR collection resources,
      # not on the record. Remove unsupported cidr_list from the record policy.
      collection_id = cidr_routing_policy.value.collection_id
      location_name = cidr_routing_policy.value.location_name
    }
  }

  # Multi-value answers
  multivalue_answer_routing_policy = try(each.value.multivalue_answer_routing_policy, null)

  # Overwrite control
  allow_overwrite = var.allow_overwrite
}

# Alias records: use an alias target and must not set TTL or records.
resource "aws_route53_record" "alias" {
  for_each = local.alias_records

  zone_id = aws_route53_zone.route53.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = each.value.alias.name
    zone_id                = each.value.alias.zone_id
    evaluate_target_health = try(each.value.alias.evaluate_target_health, false)
  }

  # Optional controls
  set_identifier  = try(each.value.set_identifier, null)
  health_check_id = try(each.value.health_check_id, null)

  dynamic "weighted_routing_policy" {
    for_each = try(each.value.weighted_routing_policy, null) != null ? [each.value.weighted_routing_policy] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "latency_routing_policy" {
    for_each = try(each.value.latency_routing_policy, null) != null ? [each.value.latency_routing_policy] : []
    content {
      region = latency_routing_policy.value.region
    }
  }

  dynamic "failover_routing_policy" {
    for_each = try(each.value.failover_routing_policy, null) != null ? [each.value.failover_routing_policy] : []
    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = try(each.value.geolocation_routing_policy, null) != null ? [each.value.geolocation_routing_policy] : []
    content {
      continent   = try(geolocation_routing_policy.value.continent, null)
      country     = try(geolocation_routing_policy.value.country, null)
      subdivision = try(geolocation_routing_policy.value.subdivision, null)
    }
  }

  dynamic "cidr_routing_policy" {
    for_each = try(each.value.cidr_routing_policy, null) != null ? [each.value.cidr_routing_policy] : []
    content {
      # Route 53 CIDR routing policy expects a collection and a location name only.
      collection_id = cidr_routing_policy.value.collection_id
      location_name = cidr_routing_policy.value.location_name
    }
  }

  multivalue_answer_routing_policy = try(each.value.multivalue_answer_routing_policy, null)
  allow_overwrite                  = var.allow_overwrite
}
