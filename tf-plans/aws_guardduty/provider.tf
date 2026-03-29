# ── GuardDuty wrapper — provider and version constraints ─────────────────────
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.3"
}

# Region is supplied by var.region and forwarded through the module call.
provider "aws" {
  region = var.region
}
