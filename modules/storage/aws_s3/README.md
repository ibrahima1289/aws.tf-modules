# AWS S3 Terraform Module

This module creates AWS S3 buckets with comprehensive configuration options:
- Bucket creation with global and per-bucket tags
- Ownership controls
- Public access blocks
- Versioning
- Server-side encryption (SSE with AES256 or KMS)
- Logging
- Lifecycle rules
- Optional ACLs
- Optional bucket policies
- Optional replication configuration

## Requirements
- Terraform >= 1.0
- AWS Provider >= 4.0

## Inputs
Required
- `region` (string): AWS region.
- `buckets` (list(object)): Bucket definitions.
  - `name` (string): Bucket name.

Optional
- `tags` (map(string), default={}): Global tags applied to all resources.
- `buckets[].acl` (string, default=null): Bucket ACL.
- `buckets[].policy_json` (string, default=null): Bucket policy JSON.
- `buckets[].tags` (map(string), default=null): Per-bucket tags.
- `buckets[].logging` (object, default=null): `{ target_bucket (string), target_prefix (string?) }`.
- `buckets[].lifecycle_rules` (list(object), default=[]): Each rule supports:
  - `id` (string)
  - `status` (string)
  - `prefix` (string?, default=null)
  - `tags` (map(string)?, default=null)
  - `expiration_days` (number?, default=null)
  - `noncurrent_version_expiration_days` (number?, default=null)
- `buckets[].replication` (object, default=null): `{ rules: [{ id (string), status (string), prefix (string?), destination_bucket_arn (string), storage_class (string?), replication_time_status (string?), replication_time_minutes (number?), delete_marker_replication_status (string?) }] }`.
- `bucket_defaults` (object, default={}): Defaults for bucket settings:
  - `object_ownership` (string?, default="BucketOwnerPreferred")
  - `block_public_acls` (bool?, default=true)
  - `block_public_policy` (bool?, default=true)
  - `ignore_public_acls` (bool?, default=true)
  - `restrict_public_buckets` (bool?, default=true)
  - `versioning_status` (string?, default="Disabled")
  - `sse_enable` (bool?, default=true)
  - `sse_algorithm` (string?, default="AES256")
  - `kms_key_id` (string?, default=null)
  - `bucket_key_enabled` (bool?, default=false)
- `replication_role_arn` (string, default=null): IAM role ARN for replication (required only if replication is configured).

## Outputs
- `bucket_ids`: Map of bucket name to bucket ID.
- `bucket_arns`: Map of bucket name to bucket ARN.

## Tags
All resources include a `created_date` tag sourced from `locals.created_date` and set to the current date in `YYYY-MM-DD` format.

## Usage
```
module "aws_s3" {
  source  = "../../modules/storage/aws_s3"
  region  = var.region
  tags    = { Environment = "dev" }
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
  buckets = [
    {
      name = "my-app-logs"
      tags = { Team = "platform" }
      logging = {
        target_bucket = "my-central-logs"
        target_prefix = "app/"
      }
      lifecycle_rules = [
        {
          id                          = "log-expiration"
          status                      = "Enabled"
          prefix                      = "app/"
          expiration_days             = 30
          noncurrent_version_expiration_days = 7
        }
      ]
    },
    {
      name = "my-app-data"
      acl  = "private"
      policy_json = jsonencode({
        Version = "2012-10-17",
        Statement = [{
          Effect   = "Allow",
          Action   = ["s3:GetObject"],
          Resource = ["arn:aws:s3:::my-app-data/*"],
          Principal = { AWS = "*" }
        }]
      })
    }
  ]
}
```
