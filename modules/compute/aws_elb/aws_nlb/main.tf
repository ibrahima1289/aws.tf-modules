# Module: AWS Network Load Balancer (NLB)
# - Creates NLBs, target groups, and listeners
# - Applies safe defaults and avoids null values using guards and dynamic blocks

# NLB resource(s)
resource "aws_lb" "nlb" {
  # Create one NLB per entry in `nlbs_map`
  for_each = local.nlbs_map

  name                       = each.value.name
  internal                   = try(each.value.internal, false)
  load_balancer_type         = "network"
  subnets                    = each.value.subnets
  enable_deletion_protection = try(each.value.enable_deletion_protection, true)
  ip_address_type            = try(each.value.ip_address_type, "ipv4")
  enable_cross_zone_load_balancing = try(each.value.cross_zone_load_balancing, true)

  # Access logs (only if enabled)
  dynamic "access_logs" {
    for_each = (try(each.value.access_logs.enabled, false) && try(each.value.access_logs.bucket, null) != null) ? [1] : []
    content {
      enabled = true
      bucket  = each.value.access_logs.bucket
      prefix  = try(each.value.access_logs.prefix, null) != null ? each.value.access_logs.prefix : "nlb/"
    }
  }

  # Tags include created_date from locals and any provided tags
  tags = merge(var.tags, try(each.value.tags, {}), {
    Name         = each.value.name,
    created_date = local.created_date
  })
}

# Target groups
resource "aws_lb_target_group" "tg" {
  # Create target groups per NLB; key format: "<nlb_name>:<tg_name>"
  for_each = merge([
    for nlb_name, nlb in local.nlbs_map : {
      for tg in coalesce(try(nlb.target_groups, []), []) :
      "${nlb_name}:${tg.name}" => merge(tg, { nlb_name = nlb_name })
    }
  ]...)

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = each.value.vpc_id
  target_type = try(each.value.target_type, "instance")

  # Preserve client IP only valid for IP targets (guarded)
  preserve_client_ip = try(each.value.target_type, "instance") == "ip" ? try(each.value.preserve_client_ip, false) : null

  # Stickiness (optional; useful for UDP via source_ip)
  dynamic "stickiness" {
    for_each = try(each.value.stickiness, null) != null && try(each.value.stickiness.enabled, false) ? [1] : []
    content {
      enabled  = true
      type     = try(each.value.stickiness.type, "source_ip")
    }
  }

  # Health check (optional); matcher/path only for HTTP/HTTPS
  dynamic "health_check" {
    for_each = try(each.value.health_check, null) != null && try(each.value.health_check.enabled, true) ? [1] : []
    content {
      enabled             = try(each.value.health_check.enabled, true)
      port                = try(each.value.health_check.port, null)
      protocol            = try(each.value.health_check.protocol, "TCP")
      path                = contains(["HTTP", "HTTPS"], try(each.value.health_check.protocol, "TCP")) ? try(each.value.health_check.path, "/") : null
      interval            = try(each.value.health_check.interval, 30)
      timeout             = try(each.value.health_check.timeout, 10)
      healthy_threshold   = try(each.value.health_check.healthy_threshold, 3)
      unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 3)
      matcher             = contains(["HTTP", "HTTPS"], try(each.value.health_check.protocol, "TCP")) ? try(each.value.health_check.matcher, "200-399") : null
    }
  }

  deregistration_delay = try(each.value.deregistration_delay, 300)

  # Tags for target group
  tags = merge(var.tags, try(each.value.tags, {}), {
    created_date = local.created_date
  })
}

# Listeners (default forward action)
resource "aws_lb_listener" "listener" {
  # Create listeners per NLB; key format: "<nlb_name>:<port>"
  for_each = merge([
    for nlb_name, nlb in local.nlbs_map : {
      for l in coalesce(try(nlb.listeners, []), []) :
      "${nlb_name}:${l.port}" => merge(l, { nlb_name = nlb_name })
    }
  ]...)

  load_balancer_arn = aws_lb.nlb[each.value.nlb_name].arn
  port              = each.value.port
  protocol          = each.value.protocol

  # TLS-only attributes guarded
  ssl_policy      = each.value.protocol == "TLS" ? try(each.value.ssl_policy, null) : null
  certificate_arn = each.value.protocol == "TLS" ? try(each.value.certificate_arn, null) : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["${each.value.nlb_name}:${each.value.default_forward_target_group}"].arn
  }

  # Ignore TLS-only attributes when not applicable
  lifecycle {
    ignore_changes = [ssl_policy, certificate_arn]
  }
}
