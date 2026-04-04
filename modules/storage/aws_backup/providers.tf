# Provider and Terraform version requirements for the AWS Backup module.
# Requires Terraform >= 1.3 for optional() in object type definitions.
# Requires AWS provider >= 5.0 for the latest Backup resource attributes.

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}
