# AWS provider configuration for CloudFront module
terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure AWS provider with the specified region
provider "aws" {
  region = var.region
}
