# Providers: AWS
# - AWS: configured via `var.region`
# - CreatedDate stamped via Terraform's built-in `timestamp()` function

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure AWS provider for this module using the provided region
provider "aws" {
  region = var.region
}
