# Plan: Wrapper around the NLB module
# - Wires common variables and provides a ready-to-apply stack

module "aws_nlb" {
  source = "../../modules/compute/aws_elb/aws_nlb"

  # Provider & tagging
  region = var.region
  tags   = var.tags

  # Single-NLB (optional, when `nlbs` not set)
  nlb_name                    = var.nlb_name
  subnets                     = var.subnet_ids

  # Access logs and defaults
  access_logs = var.access_logs

  # Target groups and listeners (inject vpc_id)
  target_groups = [for tg in var.target_groups : merge(tg, { vpc_id = var.vpc_id })]
  listeners     = var.listeners

  # Optional: pass multiple NLBs. Inject `vpc_id` into each nested target group.
  nlbs = [
    for n in var.nlbs : merge(n, {
      target_groups = [
        for tg in coalesce(try(n.target_groups, []), []) : merge(tg, { vpc_id = var.vpc_id })
      ]
    })
  ]
}
