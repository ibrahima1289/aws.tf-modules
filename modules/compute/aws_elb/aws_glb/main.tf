# Module: AWS Gateway Load Balancer (GWLB)
# - Creates GWLBs, target groups, and listeners
# - Applies safe defaults and avoids null values using guards and dynamic blocks

# GWLB resource(s)
resource "aws_lb" "glb" {
	# Create one GWLB per entry in `glbs_map`
	for_each = local.glbs_map

	name                       = each.value.name
	internal                   = try(each.value.internal, false)
	load_balancer_type         = "gateway"
	subnets                    = each.value.subnets
	enable_deletion_protection = try(each.value.enable_deletion_protection, true)

	# Access logs (only if enabled)
	dynamic "access_logs" {
		for_each = (try(each.value.access_logs.enabled, false) && try(each.value.access_logs.bucket, null) != null) ? [1] : []
		content {
			enabled = true
			bucket  = each.value.access_logs.bucket
			prefix  = try(each.value.access_logs.prefix, null) != null ? each.value.access_logs.prefix : "gwlb/"
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
	# Create target groups per GWLB; key format: "<glb_name>:<tg_name>"
	for_each = merge([
		for glb_name, glb in local.glbs_map : {
			for tg in coalesce(try(glb.target_groups, []), []) :
			"${glb_name}:${tg.name}" => merge(tg, { glb_name = glb_name })
		}
	]...)

	name        = each.value.name
	port        = each.value.port
	protocol    = each.value.protocol
	vpc_id      = each.value.vpc_id
	target_type = try(each.value.target_type, "ip")

	# Health check (optional) — GWLB supports TCP health checks
	dynamic "health_check" {
		for_each = try(each.value.health_check, null) != null && try(each.value.health_check.enabled, true) ? [1] : []
		content {
			enabled             = try(each.value.health_check.enabled, true)
			port                = try(each.value.health_check.port, null)
			protocol            = try(each.value.health_check.protocol, "TCP")
			interval            = try(each.value.health_check.interval, 30)
			timeout             = try(each.value.health_check.timeout, 10)
			healthy_threshold   = try(each.value.health_check.healthy_threshold, 3)
			unhealthy_threshold = try(each.value.health_check.unhealthy_threshold, 3)
		}
	}

	# Tags for target group
	tags = merge(var.tags, try(each.value.tags, {}), {
		created_date = local.created_date
	})
}

# Listeners (default forward action)
resource "aws_lb_listener" "listener" {
	# Create listeners per GWLB; key format: "<glb_name>:<port>"
	for_each = merge([
		for glb_name, glb in local.glbs_map : {
			for l in coalesce(try(glb.listeners, []), []) :
			"${glb_name}:${l.port}" => merge(l, { glb_name = glb_name })
		}
	]...)

	load_balancer_arn = aws_lb.glb[each.value.glb_name].arn
	port              = each.value.port
	protocol          = each.value.protocol

	default_action {
		type             = "forward"
		target_group_arn = aws_lb_target_group.tg["${each.value.glb_name}:${each.value.default_forward_target_group}"].arn
	}
}
