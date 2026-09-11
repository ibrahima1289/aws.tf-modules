# Provider and Terraform version requirements for the Fargate module.
# Requires Terraform >= 1.3 for optional() in object type definitions.
# Requires AWS provider >= 5.0 for the latest ECS resource attributes.

terraform {
  required_version = ">= 1.14.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}
