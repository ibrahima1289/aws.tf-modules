// Provider configuration for AWS ElastiCache module

terraform {
  required_version = ">= 6.0, < 7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0, < 7.0"
    }
  }
}

provider "aws" {
  // Use the region provided to the module
  region = var.region
}
