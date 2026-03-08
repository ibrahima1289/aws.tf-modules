// Example terraform.tfvars for AWS DynamoDB wrapper
// Demonstrates creating multiple DynamoDB tables with various configurations
//
// GSI key_schema: each GSI requires at least one HASH entry.
// An optional RANGE entry may follow. Mirrors the AWS provider >= 6.x argument directly.

region = "us-east-1"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "DynamoDB-Demo"
}

# ---------------------------------------------------------------------------
# DynamoDB Tables
# ---------------------------------------------------------------------------

tables = {
  # Example 1: Simple users table with on-demand billing (pay-per-request)
  users-table = {
    name         = "users-dev"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "userId"

    # Define all attributes used in primary keys or indexes
    attributes = [
      {
        name = "userId"
        type = "S" # String
      },
      {
        name = "email"
        type = "S" # String
      }
    ]

    # Global Secondary Index for querying by email
    global_secondary_indexes = [
      {
        name = "email-index"
        key_schema = [
          {
            attribute_name = "email"
            key_type       = "HASH"
          }
        ]
        projection_type = "ALL" # Include all attributes in the index
      }
    ]

    # Enable streams for triggering Lambda functions on table changes
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    # Enable point-in-time recovery for backup and restore
    point_in_time_recovery_enabled = true

    # Server-side encryption using AWS-managed key
    encryption_enabled = true

    tags = {
      Name = "users-dev"
      Type = "user-data"
    }
  }

  # Example 2: Orders table with composite primary key, LSI, GSI, and TTL
  # orders-table = {
  #   name         = "orders-dev"
  #   billing_mode = "PAY_PER_REQUEST"
  #   hash_key     = "customerId"
  #   range_key    = "orderId"
  #
  #   # Define all attributes used in primary keys or indexes
  #   attributes = [
  #     {
  #       name = "customerId"
  #       type = "S" # String
  #     },
  #     {
  #       name = "orderId"
  #       type = "S" # String
  #     },
  #     {
  #       name = "orderDate"
  #       type = "N" # Number (Unix timestamp)
  #     },
  #     {
  #       name = "status"
  #       type = "S" # String
  #     }
  #   ]
  #
  #   # Local Secondary Index for querying by order date (same partition key)
  #   # LSIs must be defined at table creation; they cannot be added later
  #   local_secondary_indexes = [
  #     {
  #       name            = "orderDate-index"
  #       range_key       = "orderDate"
  #       projection_type = "ALL"
  #     }
  #   ]
  #
  #   # Global Secondary Index for querying orders by status + date
  #   global_secondary_indexes = [
  #     {
  #       name = "status-orderDate-index"
  #       key_schema = [
  #         {
  #           attribute_name = "status"
  #           key_type       = "HASH"
  #         },
  #         {
  #           attribute_name = "orderDate"
  #           key_type       = "RANGE"
  #         }
  #       ]
  #       projection_type = "ALL"
  #     }
  #   ]
  #
  #   # Enable TTL to auto-delete old orders (attribute holds Unix timestamp)
  #   ttl_enabled        = true
  #   ttl_attribute_name = "expiresAt"
  #
  #   # Enable streams for order processing workflows
  #   stream_enabled   = true
  #   stream_view_type = "NEW_IMAGE" # Only capture the new item state
  #
  #   # Enable point-in-time recovery
  #   point_in_time_recovery_enabled = true
  #
  #   # Use Standard Infrequent Access table class for cost savings
  #   table_class = "STANDARD_INFREQUENT_ACCESS"
  #
  #   tags = {
  #     Name = "orders-dev"
  #     Type = "order-data"
  #   }
  # }

  # Example 3: Sessions table with provisioned capacity and autoscaling
  # session-table = {
  #   name         = "sessions-dev"
  #   billing_mode = "PROVISIONED"
  #   hash_key     = "sessionId"
  #
  #   # Initial provisioned capacity (autoscaling will adjust within the bounds)
  #   read_capacity  = 5
  #   write_capacity = 5
  #
  #   # Autoscaling — only applies to PROVISIONED billing_mode tables
  #   enable_autoscaling = true
  #   read_min_capacity  = 5
  #   read_max_capacity  = 100
  #   read_target_value  = 70 # Scale up when read utilization exceeds 70%
  #   write_min_capacity = 5
  #   write_max_capacity = 100
  #   write_target_value = 70 # Scale up when write utilization exceeds 70%
  #
  #   attributes = [
  #     {
  #       name = "sessionId"
  #       type = "S"
  #     }
  #   ]
  #
  #   # Enable TTL for automatic session cleanup
  #   ttl_enabled        = true
  #   ttl_attribute_name = "expiresAt"
  #
  #   # Encryption using a customer-managed KMS key
  #   encryption_enabled = true
  #   kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  #
  #   tags = {
  #     Name = "sessions-dev"
  #     Type = "session-data"
  #   }
  # }

  # Example 4: Global table with multi-region replication (DynamoDB Global Tables V2)
  # global-table = {
  #   name         = "global-users-dev"
  #   billing_mode = "PAY_PER_REQUEST"
  #   hash_key     = "userId"
  #
  #   attributes = [
  #     {
  #       name = "userId"
  #       type = "S"
  #     }
  #   ]
  #
  #   # Streams must be enabled for global table replication
  #   stream_enabled   = true
  #   stream_view_type = "NEW_AND_OLD_IMAGES"
  #
  #   # Replica regions — each creates a full read/write copy of the table
  #   replica_regions = [
  #     {
  #       region_name            = "us-west-2"
  #       propagate_tags         = true
  #       point_in_time_recovery = true
  #     },
  #     {
  #       region_name            = "eu-west-1"
  #       propagate_tags         = true
  #       point_in_time_recovery = true
  #     }
  #   ]
  #
  #   # PITR on the primary region table
  #   point_in_time_recovery_enabled = true
  #
  #   # Prevent accidental deletion of the primary table
  #   deletion_protection_enabled = true
  #
  #   tags = {
  #     Name = "global-users-dev"
  #     Type = "global-data"
  #   }
  # }

  # Example 5: Analytics table with multiple GSIs and projected attributes
  # analytics-table = {
  #   name         = "analytics-events-dev"
  #   billing_mode = "PAY_PER_REQUEST"
  #   hash_key     = "eventId"
  #
  #   # All attributes referenced in primary key or any index must be declared
  #   attributes = [
  #     {
  #       name = "eventId"
  #       type = "S"
  #     },
  #     {
  #       name = "userId"
  #       type = "S"
  #     },
  #     {
  #       name = "timestamp"
  #       type = "N" # Number (Unix milliseconds)
  #     },
  #     {
  #       name = "eventType"
  #       type = "S"
  #     }
  #   ]
  #
  #   # Multiple GSIs using key_schema list syntax
  #   global_secondary_indexes = [
  #     {
  #       # Query all events for a user, sorted by time
  #       name = "userId-timestamp-index"
  #       key_schema = [
  #         {
  #           attribute_name = "userId"
  #           key_type       = "HASH"
  #         },
  #         {
  #           attribute_name = "timestamp"
  #           key_type       = "RANGE"
  #         }
  #       ]
  #       projection_type    = "INCLUDE"
  #       non_key_attributes = ["eventType", "metadata"] # Only projected fields
  #     },
  #     {
  #       # Query event counts by type — keys only to minimise index size
  #       name = "eventType-timestamp-index"
  #       key_schema = [
  #         {
  #           attribute_name = "eventType"
  #           key_type       = "HASH"
  #         },
  #         {
  #           attribute_name = "timestamp"
  #           key_type       = "RANGE"
  #         }
  #       ]
  #       projection_type = "KEYS_ONLY"
  #     }
  #   ]
  #
  #   # Streams for real-time analytics pipelines
  #   stream_enabled   = true
  #   stream_view_type = "NEW_IMAGE"
  #
  #   # TTL for automatic cleanup of events older than 30 days
  #   ttl_enabled        = true
  #   ttl_attribute_name = "expiresAt"
  #
  #   tags = {
  #     Name = "analytics-events-dev"
  #     Type = "analytics-data"
  #   }
  # }
}
