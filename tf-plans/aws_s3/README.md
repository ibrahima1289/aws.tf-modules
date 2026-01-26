# AWS S3 Plan (Example Stack)

This plan composes the root S3 module and supplies two buckets (source and destination) via `terraform.tfvars`, including lifecycle transitions and an allow-write policy on the destination bucket.

## What It Does
- Creates a source bucket with versioning and lifecycle transitions (STANDARD_IA at 30 days, DEEP_ARCHIVE at 180 days) and noncurrent transitions.
- Optionally configures replication (if you provide a replication role and rules).
- Creates a destination bucket with a bucket policy that allows a specific principal to write objects.

## Files
- `main.tf`: Wires variables to the root module `modules/storage/aws_s3`.
- `variables.tf`: Declares plan inputs (region, tags, bucket_defaults, buckets, replication_role_arn).
- `terraform.tfvars`: Example values providing two buckets and a policy.

## Inputs
- `region` (string): AWS region.
- `tags` (map(string), default={}): Global tags applied via the module.
- `bucket_defaults` (object, default={}): Passed to the module; controls ownership, public access block, versioning, SSE, etc.
- `buckets` (list(object)): Buckets to create; mirrors the module’s schema.
- `replication_role_arn` (string, default=null): Role for replication when `buckets[].replication` is configured.

## Example tfvars
```
region = "us-east-1"

tags = { Environment = "dev" }

bucket_defaults = {
  ownership_controls_enable = false
  object_ownership        = null
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  versioning_status       = "Enabled"
  sse_enable              = true
  sse_algorithm           = "AES256"
  kms_key_id              = null
  bucket_key_enabled      = true
}

replication_role_arn = null

buckets = [
  {
    name = "abe-s3-source-bucket-v1"
    lifecycle_rules = [
      {
        id      = "standard-to-ia"
        status  = "Enabled"
        prefix  = "/app/data/"
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

    replication = {
      rules = [
        {
          id                               = "replicate-to-destination-bucket"
          status                           = "Enabled"
          prefix                           = "/app/data/"
          destination_bucket_arn           = "arn:aws:s3:::abe-s3-destination-bucket-v1"
          storage_class                    = "STANDARD_IA"
          replication_time_status          = null
          replication_time_minutes         = null
          delete_marker_replication_status = "Disabled"
        }
      ]
    }
  },
  {
    name = "abe-s3-destination-bucket-v1"
    policy_json = <<JSON
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Sid": "AllowWriteFromPrincipal",
        "Effect": "Allow",
        "Principal": { "AWS": "arn:aws:iam::123456789012:role/producer" },
        "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ReplicateObject",
          "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource": [
          "arn:aws:s3:::abe-s3-destination-bucket-v1/*"
        ]
      }]
    }
    JSON
      }
  ]
```

## Run
```
terraform init
terraform plan -var-file="tf-plans/aws_s3/terraform.tfvars"
terraform apply -var-file="tf-plans/aws_s3/terraform.tfvars"
```

## Notes
- Lifecycle: `expiration_days` must be greater than all transition `days` values; noncurrent expiration must be greater than all `noncurrent_days` values.
- Public Access Block: If account-level Block Public Access is enabled, avoid using `Principal: "*"` in policies. Use a specific principal ARN instead.
- Replication: Provide either a per-bucket `replication.role_arn` or a plan-level `replication_role_arn`.

## Replication Example
Add a role and rules as shown below. Ensure versioning is enabled in `bucket_defaults` and destination bucket policy allows writes from the role.

```
replication_role_arn = "arn:aws:iam::123456789012:role/s3-replication-role"

buckets = [
  {
    name = "src-bucket"
    replication = {
      rules = [{
        id                     = "to-dest"
        status                 = "Enabled"
        prefix                 = "/app/data/"
        destination_bucket_arn = "arn:aws:s3:::dest-bucket"
        storage_class          = "STANDARD"
      }]
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
```
