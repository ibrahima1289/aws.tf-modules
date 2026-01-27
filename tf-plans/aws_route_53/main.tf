###############################################
# Wrapper plan for the Route 53 module
###############################################

module "route53" {
  source = "../../modules/networking_content_delivery/aws_route_53"

  # Create one module instance per zone entry.
  for_each = var.zones

  zone_name                = each.value.zone_name
  is_private               = try(each.value.is_private, false)
  comment                  = try(each.value.comment, "Managed by Terraform")
  force_destroy            = try(each.value.force_destroy, false)
  delegation_set_id        = try(each.value.delegation_set_id, null)
  vpc_associations         = try(each.value.vpc_associations, [])
  enable_query_log         = try(each.value.enable_query_log, false)
  cloudwatch_log_group_arn = try(each.value.cloudwatch_log_group_arn, null)
  allow_overwrite          = try(each.value.allow_overwrite, false)
  tags                     = try(each.value.tags, {})
  records                  = try(each.value.records, {})
}

