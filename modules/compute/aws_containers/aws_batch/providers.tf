# Providers: AWS for Batch resources
# Region configured via var.region

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure AWS provider using the provided region
provider "aws" {
  region = var.region
}
