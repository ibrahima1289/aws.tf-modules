terraform {
  # Specify the required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }

  # Specify the required Terraform version
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}