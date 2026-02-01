# Module: AWS Application Load Balancer
# - Creates an ALB, target groups, listeners, and optional listener rules
# - Applies safe defaults and avoids null values using dynamic blocks

# ALB resource
resource "aws_lb" "alb" {
  # Create one ALB per entry in `albs_map`
  for_each = local.albs_map

  name                       = each.value.name
  internal                   = try(each.value.internal, false)
  load_balancer_type         = "application"
  security_groups            = try(each.value.security_groups, [])
  subnets                    = each.value.subnets
  enable_deletion_protection = try(each.value.enable_deletion_protection, true)
  enable_http2               = try(each.value.enable_http2, true)
  drop_invalid_header_fields = try(each.value.drop_invalid_header_fields, true)
  ip_address_type            = try(each.value.ip_address_type, "ipv4")
  idle_timeout               = try(each.value.idle_timeout, 60)

  # Access logs (only if enabled)
  dynamic "access_logs" {
    for_each = (try(each.value.access_logs.enabled, false) && try(each.value.access_logs.bucket, null) != null) ? [1] : []
    content {
      enabled = true
      bucket  = each.value.access_logs.bucket
      prefix  = try(each.value.access_logs.prefix, null) != null ? each.value.access_logs.prefix : "alb/"
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
  # Create target groups per ALB; key format: "<alb_name>:<tg_name>"
  for_each = merge([
    for alb_name, alb in local.albs_map : {
      for tg in coalesce(try(alb.target_groups, []), []) :
      "${alb_name}:${tg.name}" => merge(tg, { alb_name = alb_name })
    }
  ]...)

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = each.value.vpc_id
  target_type = try(each.value.target_type, "instance")

  # Stickiness (optional)
  dynamic "stickiness" {
    for_each = try(each.value.stickiness, null) != null && try(each.value.stickiness.enabled, false) ? [1] : []
    content {
      enabled         = true
      type            = try(each.value.stickiness.type, "lb_cookie")
      cookie_duration = try(each.value.stickiness.duration, 86400)
    }
  }

  # Health check (optional)
  dynamic "health_check" {
    for_each = try(each.value.health_check, null) != null && try(each.value.health_check.enabled, true) ? [1] : []
    content {
      enabled             = try(each.value.health_check.enabled, true)
      path                = try(each.value.health_check.path, "/")
      interval            = try(each.value.health_check.interval, 30)
      timeout             = try(each.value.health_check.timeout, 5)
      healthy_threshold   = try(each.value.health_check.healthy_threshold, 5)
      unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 2)
      matcher             = try(each.value.health_check.matcher, "200-399")
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
  # Create listeners per ALB; key format: "<alb_name>:<port>"
  for_each = merge([
    for alb_name, alb in local.albs_map : {
      for l in coalesce(try(alb.listeners, []), []) :
      "${alb_name}:${l.port}" => merge(l, { alb_name = alb_name })
    }
  ]...)

  load_balancer_arn = aws_lb.alb[each.value.alb_name].arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "HTTPS" ? try(each.value.ssl_policy, "ELBSecurityPolicy-2016-08") : null
  certificate_arn   = each.value.protocol == "HTTPS" ? try(each.value.certificate_arn, null) : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["${each.value.alb_name}:${each.value.default_forward_target_group}"].arn
  }

  lifecycle {
    ignore_changes = [ssl_policy, certificate_arn]
  }
}

# Listener rules (optional)
resource "aws_lb_listener_rule" "rule" {
  # Create rules per listener per ALB; key: "<alb_name>:<port>-<priority>"
  for_each = merge([
    for alb_name, alb in local.albs_map : merge([
      for l in coalesce(try(alb.listeners, []), []) : {
        for r in coalesce(try(l.additional_rules, []), []) :
        "${alb_name}:${l.port}-${r.priority}" => {
          alb_name = alb_name
          listener = l
          rule     = r
        }
      }
    ]...)
  ]...)

  listener_arn = aws_lb_listener.listener["${each.value.alb_name}:${each.value.listener.port}"].arn
  priority     = each.value.rule.priority

  dynamic "condition" {
    for_each = [1]
    content {
      dynamic "host_header" {
        for_each = try(length(try(each.value.rule.conditions.host_headers, [])), 0) > 0 ? [1] : []
        content {
          values = each.value.rule.conditions.host_headers
        }
      }
      dynamic "path_pattern" {
        for_each = try(length(try(each.value.rule.conditions.path_patterns, [])), 0) > 0 ? [1] : []
        content {
          values = each.value.rule.conditions.path_patterns
        }
      }
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["${each.value.alb_name}:${each.value.rule.action_forward_target_group}"].arn
  }
}
