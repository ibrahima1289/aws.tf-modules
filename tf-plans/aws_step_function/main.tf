# Wrapper plan wiring for the Step Functions module
# - Passes `region`, `tags`, and `state_machines` to the module
# - Exposes key outputs for convenience

module "step_function" {
  source = "../../modules/application_integration/aws_step_function"

  region         = var.region
  tags           = var.tags
  state_machines = var.state_machines
}
