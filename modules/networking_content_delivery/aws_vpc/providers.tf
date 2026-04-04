terraform {
  # Specify the required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }

  # Specify the required Terraform version
  required_version = ">= 1.14.0, < 2.0.0"
}

provider "aws" {
  region = var.region
}
