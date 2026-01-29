# Note: The policies and config are just for testing purposes.
region = "us-east-1"

tags = {
  Environment = "dev"
}

bucket_defaults = {
  ownership_controls_enable = false
  object_ownership          = null
  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
  versioning_status         = "Enabled"
  sse_enable                = true
  sse_algorithm             = "AES256"
  kms_key_id                = null
  bucket_key_enabled        = true
}

replication_role_arn = null
access_principal_arn = "arn:aws:iam::123456789012:user/*"

buckets = [
  {
    name = "abe-s3-source-bucket-v1"
    logging = {
      target_bucket = "abe-s3-logging-bucket-v1"
      target_prefix = "app/"
    }
    lifecycle_rules = [
      {
        id                                 = "standard-to-ia"
        status                             = "Enabled"
        prefix                             = "/app/data/"
        expiration_days                    = 365
        noncurrent_version_expiration_days = 120
        transitions = [
          {
            storage_class = "STANDARD_IA"
            days          = 30
          },
          {
            storage_class = "DEEP_ARCHIVE"
            days          = 180
          }
        ]
        noncurrent_version_transitions = [
          {
            storage_class   = "GLACIER"
            noncurrent_days = 60
          }
        ]
    }]
    replication = {
      rules = [
        {
          id                               = "replicate-to-destination-bucket"
          priority                         = 1
          status                           = "Enabled"
          prefix                           = "/app/data/"
          destination_bucket_arn           = "arn:aws:s3:::abe-s3-destination-bucket-v1"
          storage_class                    = "STANDARD_IA"
          replication_time_status          = "Enabled"
          replication_time_minutes         = 15
          delete_marker_replication_status = "Enabled"
        }
      ]
    }
    website = {
      index_document = "index.html"
      error_document = "error.html"
    }
    policy_json = <<JSON
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "AllowObjectAccessFromPrincipal",
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::123456789012:user/ibrahima" },
            "Action": [
              "s3:GetObject",
              "s3:GetObjectVersion",
              "s3:PutObject",
              "s3:PutObjectAcl",
              "s3:ReplicateObject",
              "s3:ObjectOwnerOverrideToBucketOwner"
            ],
            "Resource": [
              "arn:aws:s3:::abe-s3-source-bucket-v1/*"
            ]
          },
          {
            "Sid": "AllowListBucketFromPrincipal",
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::123456789012:user/ibrahima" },
            "Action": [
              "s3:ListBucket"
            ],
            "Resource": [
              "arn:aws:s3:::abe-s3-source-bucket-v1"
            ],
            "Condition": {
              "StringLike": {
                "s3:prefix": [
                  "/app/data/*"
                ]
              }
            }
          }
        ]
      }
    JSON
  },
  {
    name = "abe-s3-destination-bucket-v1"
    logging = {
      target_bucket = "abe-s3-logging-bucket-v1"
      target_prefix = "app/"
    }
    policy_json = <<JSON
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "AllowWriteFromAnyPrincipal",
              "Effect": "Allow",
              "Principal": { "AWS": "arn:aws:iam::123456789012:user/ibrahima" },
              "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:ReplicateObject",
                "s3:ObjectOwnerOverrideToBucketOwner"
              ],
              "Resource": [
                "arn:aws:s3:::abe-s3-destination-bucket-v1/*"
              ]
            }
          ]
        }
      JSON
  },
  {
    name = "abe-s3-logging-bucket-v1"
    encryption = {
      enable             = true
      algorithm          = "aws:kms"
      kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      bucket_key_enabled = true
      customer_provided  = false
    }
  }
]
