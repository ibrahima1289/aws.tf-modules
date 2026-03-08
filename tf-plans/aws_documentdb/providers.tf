// Terraform provider configuration for AWS DocumentDB wrapper plan

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS provider with the specified region
provider "aws" {
  region = var.region
}
