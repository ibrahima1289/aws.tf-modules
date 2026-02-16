# Providers: AWS and Time
# - AWS: configured via `var.region`
# - Time: used to stamp `CreatedDate` via time_static

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Configure AWS provider for this module using the provided region
provider "aws" {
  region = var.region
}
