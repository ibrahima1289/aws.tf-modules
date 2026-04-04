terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
  required_version = ">= 1.14.0, < 2.0.0"
}

# Configure the AWS provider; region is driven by the caller-supplied variable.
provider "aws" {
  region = var.region
}
