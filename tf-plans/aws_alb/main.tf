# Plan: Wrapper around the ALB module
# - Wires common variables and provides a ready-to-apply stack

module "aws_alb" {
  source = "../../modules/compute/aws_elb/aws_alb"

  # Provider & tagging
  region  = var.region
  tags    = var.tags
  lb_name = var.lb_name

  # ALB configuration
  subnets         = var.subnet_ids
  security_groups = var.alb_security_group_ids

  # Access logs and safe defaults
  access_logs = var.access_logs

  # Optional: pass multiple ALBs. Inject `vpc_id` into each nested target group.
  albs = [
    for a in var.albs : merge(a, {
      target_groups = [
        for tg in try(a.target_groups, []) : merge(tg, { vpc_id = var.vpc_id })
      ]
    })
  ]
}
