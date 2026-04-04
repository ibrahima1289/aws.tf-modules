terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.3"
}

# Configure the AWS provider; region is driven by the caller-supplied variable.
provider "aws" {
  region = var.region
}
