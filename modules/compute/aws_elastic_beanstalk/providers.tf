# Provider and Terraform version requirements for the Elastic Beanstalk module.
# Requires Terraform >= 1.3 for optional() in object type definitions.
# Requires AWS provider >= 5.0 for the latest resource attributes and defaults.

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
