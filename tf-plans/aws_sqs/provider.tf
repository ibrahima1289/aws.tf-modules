// Terraform provider configuration for AWS SQS resources.
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  // Use the region provided by the wrapper variables
  region = var.region
}