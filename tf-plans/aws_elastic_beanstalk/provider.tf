# Provider and Terraform version constraints for the Elastic Beanstalk wrapper.
# Mirrors the module's required_version and required_providers.

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
