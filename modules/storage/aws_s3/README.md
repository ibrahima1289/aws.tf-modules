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
- `buckets[].encryption` (object, default=null): Per-bucket SSE settings. Overrides module defaults when set.
  - `enable` (bool?, default=false)
  - `algorithm` (string?, default="AES256") — `AES256` or `aws:kms`
  - `kms_key_id` (string?, default=null) — required when `algorithm = "aws:kms"`
  - `bucket_key_enabled` (bool?, default=false)
  - `customer_provided` (bool?, default=false) — when true, the module will NOT set bucket-level SSE. SSE-C is applied per-object via client request headers.
- `buckets[].logging` (object, default=null): `{ target_bucket (string), target_prefix (string?) }`.
- `buckets[].lifecycle_rules` (list(object), default=[]): Each rule supports:
  - `id` (string)
  - `status` (string)
  - `prefix` (string?, default=null)
  - `tags` (map(string)?, default=null)
  - `expiration_days` (number?, default=null)
  - `noncurrent_version_expiration_days` (number?, default=null)
  - `transitions` (list(object)?, default=[]): `{ storage_class (string), days (number) }`
  - `noncurrent_version_transitions` (list(object)?, default=[]): `{ storage_class (string), noncurrent_days (number) }`
  - Allowed storage classes: `STANDARD`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER_IR`, `GLACIER`, `DEEP_ARCHIVE`.
- `buckets[].replication` (object, default=null): `{ rules: [{ id (string), status (string), prefix (string?), destination_bucket_arn (string), storage_class (string?), replication_time_status (string?), replication_time_minutes (number?), delete_marker_replication_status (string?) }] }`.
- `bucket_defaults` (object, default={}): Defaults for bucket settings:
  - `ownership_controls_enable` (bool?, default=true)
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
- `replication_role_arn` (string, default=null): IAM role ARN for replication (required when replication rules exist and bucket-level `role_arn` is not specified).

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
    mfa_delete_status       = "Disabled"
    sse_enable              = true
    sse_algorithm           = "AES256"
    kms_key_id              = null
    bucket_key_enabled      = false
  }
  buckets = [
    {
      name = "my-app-logs"
      # Example: Override to SSE-KMS for this bucket
      encryption = {
        enable             = true
        algorithm          = "aws:kms"
        kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
        bucket_key_enabled = true
      }

    ## Replication

    To enable replication from a source bucket to a destination bucket:

    - Ensure versioning is enabled on both buckets (`bucket_defaults.versioning_status = "Enabled"`).
    - Provide an IAM role with S3 replication permissions either via `replication_role_arn` (module-level) or `buckets[].replication.role_arn` (per-bucket).
    - Attach a bucket policy to the destination bucket allowing the replication role to write objects and override ownership.

    Example:

    ```
    module "aws_s3" {
      source  = "../../modules/storage/aws_s3"
      region  = var.region
      bucket_defaults = {
        versioning_status = "Enabled"
      }

      replication_role_arn = "arn:aws:iam::123456789012:role/s3-replication-role"

      buckets = [
        {
          name = "src-bucket"
          replication = {
            rules = [
              {
                id                     = "to-dest"
                status                 = "Enabled"
                destination_bucket_arn = "arn:aws:s3:::dest-bucket"
                storage_class          = "STANDARD"
              }
            ]
          }
        },
        {
          name = "dest-bucket"
          policy_json = <<JSON
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": { "AWS": "arn:aws:iam::123456789012:role/s3-replication-role" },
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ReplicateObject",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource": ["arn:aws:s3:::dest-bucket/*"]
      }]
    }
    JSON
        }
      ]
    }
    ```

    Notes:
    - Replication role must trust S3 and have permissions to read from source and write to destination.
    - Destination bucket policy must allow the replication role actions shown above.
    - If account-level S3 Block Public Access is enabled, avoid public principals (`"*"`).
      tags = { Team = "platform" }
      logging = {
        target_bucket = "my-central-logs"
        target_prefix = "app/"
      }
      lifecycle_rules = [
        {
          id      = "log-expiration"
          status  = "Enabled"
          prefix  = "app/"
          transitions = [
            { storage_class = "STANDARD_IA", days = 30 },
            { storage_class = "DEEP_ARCHIVE", days = 180 }
          ]
          expiration_days = 365
          noncurrent_version_transitions = [
            { storage_class = "GLACIER", noncurrent_days = 60 }
          ]
          noncurrent_version_expiration_days = 120
        }
      ]
    },
    {
      name = "my-app-data"
      acl  = "private"
      policy_json = <<JSON
        {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Action": ["s3:GetObject"],
            "Resource": ["arn:aws:s3:::my-app-data/*"],
            "Principal": { "AWS": "arn:aws:iam::123456789012:role/consumer" }
          }]
        }
      JSON
    }
  ]
}
```

### Notes on SSE-KMS
- When `algorithm = "aws:kms"`, provide a valid `kms_key_id` ARN and ensure the key policy allows S3 to use the key and the caller to encrypt/decrypt as required.
- If `bucket_defaults.sse_enable = true` and `buckets[].encryption.enable = true`, the per-bucket encryption settings take precedence for that bucket.

For a practical example, see the wrapper plan’s encryption section in [tf-plans/aws_s3/README.md](aws.tf-modules/tf-plans/aws_s3/README.md).

### Notes on SSE-C (Customer-Provided Keys)
- SSE-C cannot be configured as a bucket default. It is applied on a per-object basis by clients setting `x-amz-server-side-encryption-customer-algorithm: AES256` and related headers.
- AWS services (e.g., S3 server access logging) cannot use customer-provided keys; use SSE-S3 or SSE-KMS for logging buckets.
- To require SSE-C for uploads, include a bucket policy that denies `s3:PutObject` unless the SSE-C header is present. Example statement (merge with your existing policy):

```
{
  "Sid": "DenyMissingSSECHeader",
  "Effect": "Deny",
  "Principal": { "AWS": "arn:aws:iam::123456789012:role/producer" },
  "Action": "s3:PutObject",
  "Resource": ["arn:aws:s3:::your-bucket/*"],
  "Condition": {
    "StringEquals": {
      "s3:x-amz-server-side-encryption-customer-algorithm": "AES256"
    }
  }
}
```

## Client-Side Encryption (CSE)
Client-side encryption is performed by your application before uploading data to S3.

- Enforcement: S3 cannot enforce CSE via bucket policy because it cannot verify the payload is encrypted.
- How to implement: Use your language's crypto library or AWS Encryption SDK to encrypt data locally, then `PutObject` the ciphertext. Store non-sensitive metadata (algorithm, nonce, tag) to support decryption.
- Examples:
  - Python: see [tf-plans/aws_s3/examples-client-side-encryption/cse-python/README.md](aws.tf-modules/tf-plans/aws_s3/examples-client-side-encryption/cse-python/README.md).
  - Node.js: see [tf-plans/aws_s3/examples-client-side-encryption/cse-node/README.md](aws.tf-modules/tf-plans/aws_s3/examples-client-side-encryption/cse-node/README.md).
