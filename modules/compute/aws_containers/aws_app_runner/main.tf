# This module (aws_app_runner) is not yet implemented.
# The terraform_data precondition below prevents silent no-op deployments by
# failing loudly at plan time rather than applying with zero resources created.

resource "terraform_data" "not_implemented" {
  lifecycle {
    precondition {
      condition     = var.region == "__not_implemented__"
      error_message = "The aws_app_runner module is not yet implemented. Remove this module call until implementation is complete."
    }
  }
}
