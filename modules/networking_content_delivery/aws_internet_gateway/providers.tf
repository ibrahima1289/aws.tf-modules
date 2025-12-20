############################################
# Providers
############################################

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Provider is parameterized via `var.region`
provider "aws" {
  region = var.region
}
