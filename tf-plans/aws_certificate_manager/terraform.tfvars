# Step 1: Set region for this wrapper plan.
region = "us-east-1"

# Step 2: Define global tags used across ACM resources.
tags = {
  project     = "edge-security"
  environment = "dev"
  owner       = "cloud-team"
}

# Step 3: Create multiple ACM certificates.
certificates = [
  {
    key                                         = "public-web"
    type                                        = "AMAZON_ISSUED"
    domain_name                                 = "example.com"
    validation_method                           = "DNS"
    subject_alternative_names                   = ["www.example.com", "api.example.com"]
    key_algorithm                               = "RSA_2048"
    certificate_transparency_logging_preference = "ENABLED"
    validate_certificate                        = false
    validation_record_fqdns                     = []
    tags = {
      workload = "frontend"
    }
  },
  {
    key                                         = "internal-api"
    type                                        = "AMAZON_ISSUED"
    domain_name                                 = "internal.example.com"
    validation_method                           = "EMAIL"
    subject_alternative_names                   = []
    key_algorithm                               = "RSA_2048"
    certificate_transparency_logging_preference = "DISABLED"
    validate_certificate                        = false
    validation_record_fqdns                     = []
    tags = {
      workload = "backend"
    }
  }

  # {
  #   key                                         = "imported-cert"
  #   type                                        = "IMPORTED"
  #   certificate_body                            = file("${path.module}/certs/imported_cert.pem")
  #   private_key                                 = file("${path.module}/certs/imported_key.pem")
  #   certificate_chain                           = file("${path.module}/certs/imported_chain.pem")
  #   validate_certificate                        = false
  #   validation_record_fqdns                     = []
  #   tags = {
  #     workload = "legacy"
  #   }
  # }
]
