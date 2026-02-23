# Terraform configuration for AWS Aurora deployment
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure AWS provider
provider "aws" {
  region = var.region
}
