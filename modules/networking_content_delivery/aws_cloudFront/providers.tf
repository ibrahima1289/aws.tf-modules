# AWS provider configuration for CloudFront module
terraform {
  required_version = ">= 1.14.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

# Configure AWS provider with the specified region
provider "aws" {
  region = var.region
}
