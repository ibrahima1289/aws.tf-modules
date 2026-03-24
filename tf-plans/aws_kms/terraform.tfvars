region = "ca-central-1"

tags = {
  Environment = "dev"
}

keys = [
  {
    name                    = "app-key"
    description             = "Application encryption key"
    key_usage               = "ENCRYPT_DECRYPT"
    key_spec                = "SYMMETRIC_DEFAULT"
    enable_key_rotation     = true
    aliases                 = ["app-key"]
    deletion_window_in_days = 7
    tags                    = { Team = "platform" }
  },
  {
    name                    = "signing-key"
    key_usage               = "SIGN_VERIFY"
    key_spec                = "RSA_2048"
    aliases                 = ["signing-key"]
    multi_region            = true
    deletion_window_in_days = 7
    tags                    = { Team = "security" }
  },
  {
    name                    = "legacy-key"
    description             = "Legacy key pending scheduled deletion"
    key_usage               = "ENCRYPT_DECRYPT"
    key_spec                = "SYMMETRIC_DEFAULT"
    enable_key_rotation     = false
    aliases                 = ["legacy-key"]
    deletion_window_in_days = 30
    tags                    = { Team = "platform", Status = "deprecated" }
  },
  {
    name        = "external-key"
    description = "External key imported into AWS KMS"
    key_usage   = "ENCRYPT_DECRYPT"
    key_spec    = "SYMMETRIC_DEFAULT"
    origin      = "EXTERNAL"
    aliases     = ["external-key"]
    tags        = { Team = "third-party" }
  }
]

grants = [
  {
    name              = "app-decrypt"
    key_name          = "app-key"
    grantee_principal = "arn:aws:iam::123456789012:role/aws-ecr-role"
    operations        = ["Decrypt", "Encrypt", "GenerateDataKey"]
  },
  {
    name              = "signing-verify"
    key_name          = "signing-key"
    grantee_principal = "arn:aws:iam::123456789012:user/alice"
    operations        = ["Verify"]
    constraints = {
      encryption_context_subset = {
        "Department" = "Security"
      }
    }
  }
]
