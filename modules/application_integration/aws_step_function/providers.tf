// Provider configuration for AWS Step Functions module

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
  // AWS region where Step Functions state machines will be created
  region = var.region
}
