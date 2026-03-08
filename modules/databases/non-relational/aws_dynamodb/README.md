# AWS DynamoDB Terraform Module

This module creates and manages AWS DynamoDB tables with support for multiple tables, various capacity modes, encryption, streams, global secondary indexes (GSI), local secondary indexes (LSI), and advanced features like global tables and auto-scaling.

## Features

- **Multi-Table Support**: Create multiple DynamoDB tables from a single module
- **Flexible Billing**: On-Demand (pay-per-request) or Provisioned capacity with auto-scaling
- **Indexes**: Global Secondary Indexes (GSI) and Local Secondary Indexes (LSI)
- **Streams**: DynamoDB Streams for capturing table changes
- **Encryption**: Server-side encryption with AWS-owned or customer-managed KMS keys
- **Time to Live (TTL)**: Automatic item expiration based on timestamp attribute
- **Point-in-Time Recovery (PITR)**: Backup and restore capabilities
- **Global Tables**: Multi-region replication for globally distributed applications
- **Auto-Scaling**: Automatic capacity scaling for provisioned tables
- **Table Classes**: Standard or Standard Infrequent Access (IA) for cost optimization
- **Import from S3**: Import existing data from S3 buckets
- **Consistent Tagging**: Automatically adds `CreatedDate` tag to all resources

## Architecture

This module provides a flexible, multi-table DynamoDB deployment pattern with comprehensive feature support:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        DynamoDB Module Architecture                     │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│ Input: tables map                                                       │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                    │
│ │   Table 1    │  │   Table 2    │  │   Table N    │                    │
│ │   (users)    │  │   (orders)   │  │  (sessions)  │                    │
│ └──────────────┘  └──────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ DynamoDB Tables (aws_dynamodb_table)                                    │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Table Configuration                                                 │ │
│ │ • Partition Key (hash_key) [Required]                               │ │
│ │ • Sort Key (range_key) [Optional]                                   │ │
│ │ • Attributes (only for keys/indexes)                                │ │
│ │ • Billing Mode: PAY_PER_REQUEST or PROVISIONED                      │ │
│ │ • Table Class: STANDARD or STANDARD_INFREQUENT_ACCESS               │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Indexes                                                             │ │
│ │ • Global Secondary Indexes (GSI) - Different partition/sort keys    │ │
│ │ • Local Secondary Indexes (LSI) - Same partition, different sort    │ │
│ │ • Projection: ALL, KEYS_ONLY, or INCLUDE                            │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Streams & Events                                                    │ │
│ │ • DynamoDB Streams (NEW_IMAGE, OLD_IMAGE, etc.)                     │ │
│ │ • Stream ARN → Lambda Functions, Kinesis, etc.                      │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Data Lifecycle                                                      │ │
│ │ • Time to Live (TTL) - Automatic item expiration                    │ │
│ │ • Point-in-Time Recovery (PITR) - 35-day continuous backups         │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Security                                                            │ │
│ │ • Server-side Encryption (AWS-owned or customer-managed KMS)        │ │
│ │ • Deletion Protection                                               │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Global Tables (Multi-Region Replication)                            │ │
│ │ ┌─────────────┐    ┌─────────────┐    ┌─────────────┐               │ │
│ │ │ us-east-1   │◄──►│ us-west-2   │◄──►│ eu-west-1   │               │ │
│ │ │  (Primary)  │    │  (Replica)  │    │  (Replica)  │               │ │
│ │ └─────────────┘    └─────────────┘    └─────────────┘               │ │
│ │ • Active-Active replication                                         │ │
│ │ • Cross-region data sync                                            │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Auto-Scaling (for PROVISIONED billing mode)                             │
│                                                                         │
│ ┌──────────────────────────────┐  ┌──────────────────────────────┐      │
│ │ Table Capacity               │  │ GSI Capacity                 │      │
│ │ • Read Capacity Units (RCU)  │  │ • Read Capacity Units (RCU)  │      │
│ │ • Write Capacity Units (WCU) │  │ • Write Capacity Units (WCU) │      │
│ │ • Target Tracking (70%)      │  │ • Target Tracking (70%)      │      │
│ │ • Min/Max Capacity           │  │ • Min/Max Capacity           │      │
│ └──────────────────────────────┘  └──────────────────────────────┘      │
│                                                                         │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ aws_appautoscaling_target                                           │ │
│ │ aws_appautoscaling_policy (TargetTrackingScaling)                   │ │
│ │ • Monitors DynamoDB*CapacityUtilization CloudWatch metrics          │ │
│ │ • Automatically scales capacity based on utilization                │ │
│ └─────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────────┐
│ Outputs                                                                 │
│ • table_arns - Map of table ARNs                                        │
│ • table_ids - Map of table IDs                                          │
│ • stream_arns - Map of stream ARNs (for tables with streams enabled)    │
│ • read_autoscaling_targets - Auto-scaling target details                │
│ • write_autoscaling_targets - Auto-scaling target details               │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Architectural Patterns

1. **Map-Based Multi-Resource Creation**: Create multiple tables from a single `tables` map variable, each with independent configuration.

2. **Conditional Auto-Scaling**: Auto-scaling resources are only created when `billing_mode = PROVISIONED` and `enable_autoscaling = true`.

3. **Dynamic Index Support**: GSI and LSI are created using dynamic blocks, allowing flexible index configuration without null values.

4. **Stream Integration**: Stream ARNs are exposed for integration with Lambda, Kinesis, or other event-driven services.

5. **Safe Defaults**: All optional attributes have sensible defaults defined in `locals.tf` to avoid Terraform null value errors.

6. **Consistent Tagging**: All tables automatically receive a `CreatedDate` tag plus global and per-table custom tags.

### Data Flow

```
Write Request → DynamoDB Table → [Stream Enabled?] → DynamoDB Stream → Lambda/Kinesis
                       ↓
                  [TTL Enabled?] → Automatic Deletion (expired items)
                       ↓
                  [PITR Enabled?] → Continuous Backup (35 days)
                       ↓
                  [Global Table?] → Cross-Region Replication
                       ↓
                [Provisioned Mode?] → Auto-Scaling (monitors utilization)
```

## Usage

### Basic Table with On-Demand Billing

```hcl
module "dynamodb" {
  source = "../../modules/databases/non-relational/aws_dynamodb"

  region = "us-east-1"

  tables = {
    users = {
      name         = "users-dev"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "userId"

      attributes = [
        {
          name = "userId"
          type = "S" # String
        }
      ]

      point_in_time_recovery_enabled = true
      encryption_enabled            = true
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

### Table with Composite Primary Key and Global Secondary Index

```hcl
module "dynamodb" {
  source = "../../modules/databases/non-relational/aws_dynamodb"

  region = "us-east-1"

  tables = {
    orders = {
      name         = "orders-dev"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "customerId"
      range_key    = "orderId"

      attributes = [
        {
          name = "customerId"
          type = "S"
        },
        {
          name = "orderId"
          type = "S"
        },
        {
          name = "status"
          type = "S"
        }
      ]

      # GSI for querying by status
      global_secondary_indexes = [
        {
          name            = "status-index"
          hash_key        = "status"
          projection_type = "ALL"
        }
      ]

      # Enable streams for order processing
      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"

      # TTL for auto-cleanup after 90 days
      ttl_enabled        = true
      ttl_attribute_name = "expiresAt"
    }
  }
}
```

### Table with Provisioned Capacity and Auto-Scaling

```hcl
module "dynamodb" {
  source = "../../modules/databases/non-relational/aws_dynamodb"

  region = "us-east-1"

  tables = {
    sessions = {
      name         = "sessions-dev"
      billing_mode = "PROVISIONED"
      hash_key     = "sessionId"

      attributes = [
        {
          name = "sessionId"
          type = "S"
        }
      ]

      # Provisioned capacity
      read_capacity  = 5
      write_capacity = 5

      # Auto-scaling configuration
      enable_autoscaling = true
      read_min_capacity  = 5
      read_max_capacity  = 100
      read_target_value  = 70  # Target 70% utilization
      write_min_capacity = 5
      write_max_capacity = 100
      write_target_value = 70

      # Encryption with customer-managed KMS key
      encryption_enabled = true
      kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }
  }
}
```

### Global Table with Multi-Region Replication

```hcl
module "dynamodb" {
  source = "../../modules/databases/non-relational/aws_dynamodb"

  region = "us-east-1"

  tables = {
    global-users = {
      name         = "global-users-prod"
      billing_mode = "PAY_PER_REQUEST"
      hash_key     = "userId"

      attributes = [
        {
          name = "userId"
          type = "S"
        }
      ]

      # Replica regions for global table
      replica_regions = [
        {
          region_name            = "us-west-2"
          propagate_tags         = true
          point_in_time_recovery = true
        },
        {
          region_name            = "eu-west-1"
          propagate_tags         = true
          point_in_time_recovery = true
        }
      ]

      # Enable streams (required for global tables)
      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"

      # Enable deletion protection for production
      deletion_protection_enabled = true

      point_in_time_recovery_enabled = true
    }
  }
}
```

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region to deploy DynamoDB resources |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `tables` | `map(object)` | `{}` | Map of DynamoDB tables to create (see Table Variables below) |

## Table Variables (for `tables` map)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | `string` | Yes | - | Table name (unique within AWS account and region) |
| `hash_key` | `string` | Yes | - | Attribute name for the partition key |
| `billing_mode` | `string` | No | `PAY_PER_REQUEST` | Billing mode: `PROVISIONED` or `PAY_PER_REQUEST` |
| `range_key` | `string` | No | `null` | Attribute name for the sort key (optional) |
| `attributes` | `list(object)` | Yes | - | List of attribute definitions (see Attributes below) |
| `read_capacity` | `number` | No | `null` | Read capacity units (required if `billing_mode = PROVISIONED`) |
| `write_capacity` | `number` | No | `null` | Write capacity units (required if `billing_mode = PROVISIONED`) |
| `stream_enabled` | `bool` | No | `false` | Enable DynamoDB Streams |
| `stream_view_type` | `string` | No | `null` | Stream view type: `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES`, `KEYS_ONLY` |
| `ttl_enabled` | `bool` | No | `false` | Enable Time to Live (TTL) |
| `ttl_attribute_name` | `string` | No | `null` | Attribute name containing TTL timestamp (Unix epoch time) |
| `point_in_time_recovery_enabled` | `bool` | No | `false` | Enable point-in-time recovery (PITR) for backups |
| `encryption_enabled` | `bool` | No | `true` | Enable server-side encryption |
| `kms_key_arn` | `string` | No | `null` | KMS key ARN for encryption (uses AWS-owned key if not specified) |
| `table_class` | `string` | No | `STANDARD` | Table class: `STANDARD` or `STANDARD_INFREQUENT_ACCESS` |
| `deletion_protection_enabled` | `bool` | No | `false` | Enable deletion protection |
| `global_secondary_indexes` | `list(object)` | No | `[]` | List of GSI definitions (see GSI Variables below) |
| `local_secondary_indexes` | `list(object)` | No | `[]` | List of LSI definitions (see LSI Variables below) |
| `replica_regions` | `list(object)` | No | `[]` | List of replica regions for global tables (see Replica Variables below) |
| `import_table` | `object` | No | `null` | Import table from S3 (see Import Variables below) |
| `tags` | `map(string)` | No | `{}` | Additional tags for this table |

### Auto-Scaling Variables (for `billing_mode = PROVISIONED`)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `enable_autoscaling` | `bool` | No | `false` | Enable auto-scaling for provisioned capacity |
| `read_min_capacity` | `number` | No | `null` | Minimum read capacity units for auto-scaling |
| `read_max_capacity` | `number` | No | `null` | Maximum read capacity units for auto-scaling |
| `read_target_value` | `number` | No | `70` | Target utilization percentage (1-100) for read capacity |
| `write_min_capacity` | `number` | No | `null` | Minimum write capacity units for auto-scaling |
| `write_max_capacity` | `number` | No | `null` | Maximum write capacity units for auto-scaling |
| `write_target_value` | `number` | No | `70` | Target utilization percentage (1-100) for write capacity |

### Attribute Variables

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | `string` | Yes | Attribute name |
| `type` | `string` | Yes | Attribute type: `S` (string), `N` (number), or `B` (binary) |

**Note**: Only define attributes that are used in keys or indexes. DynamoDB is schemaless for non-key attributes.

### Global Secondary Index (GSI) Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | `string` | Yes | - | Index name |
| `hash_key` | `string` | Yes | - | Partition key attribute name |
| `range_key` | `string` | No | `null` | Sort key attribute name |
| `projection_type` | `string` | Yes | - | Projection type: `ALL`, `KEYS_ONLY`, or `INCLUDE` |
| `non_key_attributes` | `list(string)` | No | `null` | Attributes to include (required if `projection_type = INCLUDE`) |
| `read_capacity` | `number` | No | `null` | Read capacity (for `PROVISIONED` mode only) |
| `write_capacity` | `number` | No | `null` | Write capacity (for `PROVISIONED` mode only) |

### Local Secondary Index (LSI) Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `name` | `string` | Yes | - | Index name |
| `range_key` | `string` | Yes | - | Sort key attribute name (partition key is same as table) |
| `projection_type` | `string` | Yes | - | Projection type: `ALL`, `KEYS_ONLY`, or `INCLUDE` |
| `non_key_attributes` | `list(string)` | No | `null` | Attributes to include (required if `projection_type = INCLUDE`) |

**Note**: LSI can only be created at table creation time and cannot be modified later.

### Replica Region Variables (for Global Tables)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `region_name` | `string` | Yes | - | AWS region for the replica |
| `kms_key_arn` | `string` | No | `null` | KMS key ARN for replica encryption |
| `propagate_tags` | `bool` | No | `false` | Propagate tags to replica |
| `point_in_time_recovery` | `bool` | No | `false` | Enable PITR for replica |

### Import Table Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `input_format` | `string` | Yes | - | Input format: `DYNAMODB_JSON`, `ION`, or `CSV` |
| `s3_bucket_source` | `object` | Yes | - | S3 bucket source configuration (see below) |
| `input_format_options` | `object` | No | `null` | Format-specific options (CSV only) |
| `input_compression_type` | `string` | No | `null` | Compression type: `GZIP`, `ZSTD`, or `NONE` |

#### S3 Bucket Source Variables

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `bucket` | `string` | Yes | - | S3 bucket name |
| `bucket_owner` | `string` | No | `null` | S3 bucket owner account ID |
| `key_prefix` | `string` | No | `null` | S3 key prefix for import files |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `tables` | `map(object)` | Map of all table details (ARN, ID, stream ARN, etc.) |
| `table_arns` | `map(string)` | Map of table names to ARNs |
| `table_ids` | `map(string)` | Map of table names to IDs |
| `stream_arns` | `map(string)` | Map of stream ARNs for tables with streams enabled |
| `read_autoscaling_targets` | `map(object)` | Map of read auto-scaling target details |
| `write_autoscaling_targets` | `map(object)` | Map of write auto-scaling target details |

## Examples

See the [terraform.tfvars](../../../tf-plans/aws_dynamodb/terraform.tfvars) file in the wrapper directory for comprehensive examples including:

- Simple on-demand table with GSI
- Composite primary key with LSI and GSI
- Provisioned capacity with auto-scaling
- Global table with multi-region replication
- Analytics table with projected attributes

## Important Notes

1. **Attributes**: Only define attributes that are used as keys or in indexes. DynamoDB is schemaless for other attributes.

2. **Local Secondary Indexes**: LSI can only be created at table creation time and share the same partition key as the table.

3. **Global Tables**: Require streams to be enabled with `NEW_AND_OLD_IMAGES` view type.

4. **Billing Modes**:
   - **On-Demand**: Best for unpredictable workloads. Pay per request.
   - **Provisioned**: Best for predictable workloads. Lower cost with auto-scaling.

5. **Auto-Scaling**: Only applicable for `PROVISIONED` billing mode. Automatically adjusts capacity based on utilization.

6. **Capacity Units**:
   - **1 RCU** = 1 strongly consistent read/sec (up to 4 KB) or 2 eventually consistent reads/sec
   - **1 WCU** = 1 write/sec (up to 1 KB)

7. **TTL**: The TTL attribute must contain a Unix epoch timestamp (number of seconds since January 1, 1970).

8. **Encryption**: AWS-owned keys are free; customer-managed KMS keys incur additional charges.

## Related Resources

- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [DynamoDB Overview](aws-dynamodb.md)

## License

This module is licensed under the terms specified in the [LICENSE](../../../../LICENSE) file.
