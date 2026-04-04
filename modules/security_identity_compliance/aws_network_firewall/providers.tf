terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
  required_version = ">= 1.14.0, < 2.0.0"
}

# Configure the AWS provider for the target region.
# region is driven by var.region so every resource lands in the correct AWS region.
provider "aws" {
  region = var.region
}
