###############################################
# Providers configuration for the Route 53 module
###############################################

terraform {
  # Use modern Terraform and AWS provider features
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
# Note: Provider configuration is expected to be passed from the caller.
# This module does not define a local provider configuration so it can be
# safely used with module-level for_each/count/depends_on.
