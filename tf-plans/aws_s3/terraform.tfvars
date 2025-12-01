region = "us-east-1"

tags = {
  Environment = "dev"
}

bucket_defaults = {
  object_ownership        = "BucketOwnerPreferred"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  versioning_status       = "Enabled"
  sse_enable              = true
  sse_algorithm           = "AES256"
  kms_key_id              = null
  bucket_key_enabled      = false
}

replication_role_arn = null

buckets = [
  {
    name = "my-app-logs-example"
    tags = { Team = "platform" }
    logging = {
      target_bucket = "backend-aws-tfstate"
      target_prefix = "app/"
    }
    lifecycle_rules = [
      {
        id                                 = "log-expiration"
        status                             = "Enabled"
        prefix                             = "app/"
        expiration_days                    = 30
        noncurrent_version_expiration_days = 7
      }
    ]
  }
]
