# tf-plans/aws_network_firewall/main.tf
# Wrapper that invokes the aws_network_firewall root module.
# All variable values are supplied via terraform.tfvars.

module "aws_network_firewall" {
  source = "../../modules/security_identity_compliance/aws_network_firewall"

  region = var.region
  tags   = var.tags

  # Rule groups define the traffic-matching logic (stateless and stateful).
  rule_groups = var.rule_groups

  # Policies bind rule groups together and set default actions.
  policies = var.policies

  # Firewalls deploy endpoints into VPC subnets and associate a policy.
  firewalls = var.firewalls
}
