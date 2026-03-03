// Input variables for AWS DynamoDB wrapper plan

variable "region" {
  description = "AWS region to use for DynamoDB resources."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all DynamoDB resources."
  type        = map(string)
  default     = {}
}

variable "tables" {
  description = "Map of DynamoDB tables to create (key is a logical name). Supports standard tables with various capacity modes, encryption, streams, and backup settings."
  type = map(object({
    name             = string
    billing_mode     = optional(string) # "PROVISIONED" or "PAY_PER_REQUEST"
    hash_key         = string           # Partition key attribute name
    range_key        = optional(string) # Sort key attribute name
    stream_enabled   = optional(bool)
    stream_view_type = optional(string) # "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES", "KEYS_ONLY"

    # Read/write capacity (for PROVISIONED mode only)
    read_capacity  = optional(number)
    write_capacity = optional(number)

    # Auto-scaling settings (for PROVISIONED mode)
    enable_autoscaling = optional(bool)
    read_min_capacity  = optional(number)
    read_max_capacity  = optional(number)
    read_target_value  = optional(number) # Target utilization percentage (1-100)
    write_min_capacity = optional(number)
    write_max_capacity = optional(number)
    write_target_value = optional(number) # Target utilization percentage (1-100)

    # Attributes (all attributes used in keys or indexes must be defined)
    attributes = list(object({
      name = string
      type = string # "S" (string), "N" (number), or "B" (binary)
    }))

    # Time to Live (TTL) settings
    ttl_enabled        = optional(bool)
    ttl_attribute_name = optional(string)

    # Global Secondary Indexes (GSI)
    global_secondary_indexes = optional(list(object({
      name = string
      key_schema = list(object({ # One HASH entry required; optional RANGE entries
        attribute_name = string
        key_type       = string # "HASH" or "RANGE"
      }))
      projection_type    = string                 # "ALL", "KEYS_ONLY", or "INCLUDE"
      non_key_attributes = optional(list(string)) # Required if projection_type = "INCLUDE"
      read_capacity      = optional(number)       # For PROVISIONED mode
      write_capacity     = optional(number)       # For PROVISIONED mode
    })))

    # Local Secondary Indexes (LSI) - must be defined at table creation
    local_secondary_indexes = optional(list(object({
      name               = string
      range_key          = string
      projection_type    = string                 # "ALL", "KEYS_ONLY", or "INCLUDE"
      non_key_attributes = optional(list(string)) # Required if projection_type = "INCLUDE"
    })))

    # Point-in-time recovery (PITR)
    point_in_time_recovery_enabled = optional(bool)

    # Server-side encryption
    encryption_enabled = optional(bool)
    kms_key_arn        = optional(string) # If not specified, uses AWS-owned key

    # Table class
    table_class = optional(string) # "STANDARD" or "STANDARD_INFREQUENT_ACCESS"

    # Deletion protection
    deletion_protection_enabled = optional(bool)

    # Import settings
    import_table = optional(object({
      input_format = string # "DYNAMODB_JSON", "ION", or "CSV"
      s3_bucket_source = object({
        bucket       = string
        bucket_owner = optional(string)
        key_prefix   = optional(string)
      })
      input_format_options = optional(object({
        csv = optional(object({
          delimiter   = optional(string)
          header_list = optional(list(string))
        }))
      }))
      input_compression_type = optional(string) # "GZIP", "ZSTD", or "NONE"
    }))

    # Replica regions (for global tables)
    replica_regions = optional(list(object({
      region_name            = string
      kms_key_arn            = optional(string)
      propagate_tags         = optional(bool)
      point_in_time_recovery = optional(bool)
    })))

    # Per-resource tags
    tags = optional(map(string))
  }))
  default = {}
}
