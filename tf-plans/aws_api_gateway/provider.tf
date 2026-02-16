# Providers: AWS and Time for wrapper plan

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Wrapper passes region down to the module
provider "aws" {
  region = var.region
}
