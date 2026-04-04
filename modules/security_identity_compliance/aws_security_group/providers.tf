terraform {
  # Specify the required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }

  # Specify the required Terraform version
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}