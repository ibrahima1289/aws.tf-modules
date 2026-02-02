# Plan: Wrapper around the GWLB module
# - Wires common variables and provides a ready-to-apply stack

module "aws_glb" {
  source = "../../modules/compute/aws_elb/aws_glb"

  # Provider & tagging
  region = var.region
  tags   = var.tags

  # Single-GLB (optional, when `glbs` not set)
  glb_name = var.glb_name
  subnets  = var.subnet_ids

  # Access logs and defaults
  access_logs = var.access_logs

  # Target groups and listeners (inject vpc_id)
  target_groups = [for tg in var.target_groups : merge(tg, { vpc_id = var.vpc_id })]
  listeners     = var.listeners

  # Optional: pass multiple GWLBs. Inject `vpc_id` into each nested target group.
  glbs = [
    for g in var.glbs : merge(g, {
      target_groups = [
        for tg in coalesce(try(g.target_groups, []), []) : merge(tg, { vpc_id = var.vpc_id })
      ]
    })
  ]
}
