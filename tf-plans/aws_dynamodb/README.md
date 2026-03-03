# AWS DynamoDB Wrapper

This wrapper provides a simplified interface to the AWS DynamoDB root module. It demonstrates how to create and manage DynamoDB tables with various configurations including on-demand and provisioned billing, indexes, streams, and global tables.

## Quick Start

1. Configure your variables in `terraform.tfvars` (see examples below)
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Usage Examples

The [terraform.tfvars](terraform.tfvars) file includes examples for:
- **Simple on-demand table**: Basic table with GSI and streams
- **Composite primary key**: Table with partition and sort keys, LSI and GSI
- **Provisioned capacity**: Table with auto-scaling for predictable workloads
- **Global table**: Multi-region replication for global applications
- **Analytics table**: Advanced indexing with projected attributes

## Configuration

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region to deploy DynamoDB resources |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `tables` | `map(object)` | `{}` | Map of DynamoDB tables to create |

See the [root module README](../../modules/databases/non-relational/aws_dynamodb/README.md) for detailed variable documentation.

## Example: Simple On-Demand Table

```hcl
region = "us-east-1"

tables = {
  users = {
    name         = "users-dev"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "userId"

    attributes = [
      {
        name = "userId"
        type = "S"
      },
      {
        name = "email"
        type = "S"
      }
    ]

    # GSI for querying by email
    global_secondary_indexes = [
      {
        name            = "email-index"
        hash_key        = "email"
        projection_type = "ALL"
      }
    ]

    # Enable streams for Lambda triggers
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    # Enable PITR for backups
    point_in_time_recovery_enabled = true
  }
}
```

## Example: Table with Composite Key and Indexes

```hcl
region = "us-east-1"

tables = {
  orders = {
    name         = "orders-prod"
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
        name = "orderDate"
        type = "N"
      },
      {
        name = "status"
        type = "S"
      }
    ]

    # LSI for querying orders by date
    local_secondary_indexes = [
      {
        name            = "orderDate-index"
        range_key       = "orderDate"
        projection_type = "ALL"
      }
    ]

    # GSI for querying by status
    global_secondary_indexes = [
      {
        name            = "status-index"
        hash_key        = "status"
        range_key       = "orderDate"
        projection_type = "ALL"
      }
    ]

    # TTL for automatic cleanup
    ttl_enabled        = true
    ttl_attribute_name = "expiresAt"

    # Enable streams
    stream_enabled   = true
    stream_view_type = "NEW_IMAGE"

    # Use IA table class for cost savings
    table_class = "STANDARD_INFREQUENT_ACCESS"
  }
}
```

## Example: Provisioned Capacity with Auto-Scaling

```hcl
region = "us-east-1"

tables = {
  sessions = {
    name         = "sessions-prod"
    billing_mode = "PROVISIONED"
    hash_key     = "sessionId"

    attributes = [
      {
        name = "sessionId"
        type = "S"
      }
    ]

    # Provisioned capacity
    read_capacity  = 10
    write_capacity = 10

    # Auto-scaling configuration
    enable_autoscaling = true
    read_min_capacity  = 10
    read_max_capacity  = 500
    read_target_value  = 70  # Target 70% utilization
    write_min_capacity = 10
    write_max_capacity = 500
    write_target_value = 70

    # Customer-managed KMS key
    encryption_enabled = true
    kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

    # TTL for session cleanup
    ttl_enabled        = true
    ttl_attribute_name = "expiresAt"
  }
}
```

## Example: Global Table with Multi-Region Replication

```hcl
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

    # Replica regions
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

    # Streams required for global tables
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    # Enable deletion protection
    deletion_protection_enabled = true

    # Enable PITR
    point_in_time_recovery_enabled = true
  }
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `tables` | Full details of all created tables |
| `table_arns` | Map of table names to ARNs |
| `table_ids` | Map of table names to IDs |
| `stream_arns` | Map of stream ARNs (for tables with streams) |
| `read_autoscaling_targets` | Read auto-scaling target details |
| `write_autoscaling_targets` | Write auto-scaling target details |

## Key Features Demonstrated

### Billing Modes

- **On-Demand (PAY_PER_REQUEST)**: Best for unpredictable or variable workloads
- **Provisioned (PROVISIONED)**: Best for predictable workloads with auto-scaling

### Indexes

- **Global Secondary Index (GSI)**: Query with different partition/sort keys
- **Local Secondary Index (LSI)**: Alternative sort key with same partition key

### Advanced Features

- **DynamoDB Streams**: Capture table changes for event-driven architectures
- **Time to Live (TTL)**: Automatic item expiration
- **Point-in-Time Recovery (PITR)**: Backup and restore to any point in last 35 days
- **Global Tables**: Multi-region active-active replication
- **Auto-Scaling**: Automatic capacity adjustment based on utilization
- **Encryption**: AWS-owned or customer-managed KMS keys

## Common Use Cases

### E-commerce Application

```hcl
tables = {
  # Products catalog
  products = {
    name         = "products"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "productId"
    # ... attributes and indexes
  }

  # Customer orders
  orders = {
    name         = "orders"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "customerId"
    range_key    = "orderId"
    # ... composite key for efficient customer queries
  }

  # Shopping carts (with TTL)
  carts = {
    name         = "carts"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "cartId"
    ttl_enabled  = true
    ttl_attribute_name = "expiresAt"
    # ... auto-cleanup abandoned carts
  }
}
```

### Serverless Web Application

```hcl
tables = {
  # User profiles
  users = {
    name         = "users"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "userId"
    # ... GSI for email lookup
  }

  # Session storage
  sessions = {
    name         = "sessions"
    billing_mode = "PROVISIONED"
    hash_key     = "sessionId"
    enable_autoscaling = true
    # ... provisioned with auto-scaling for cost optimization
  }

  # Application logs
  logs = {
    name         = "logs"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "logId"
    ttl_enabled  = true
    ttl_attribute_name = "expiresAt"
    # ... TTL for automatic log rotation
  }
}
```

## Best Practices

1. **Choose the Right Billing Mode**:
   - Use **On-Demand** for new applications or unpredictable traffic
   - Use **Provisioned** with auto-scaling for predictable, steady workloads

2. **Design Efficient Indexes**:
   - Only create indexes you'll actually query
   - Use `KEYS_ONLY` or `INCLUDE` projection to reduce storage costs
   - Remember: LSI must be created at table creation time

3. **Enable Streams for Event-Driven Architectures**:
   - Trigger Lambda functions on table changes
   - Required for global tables

4. **Use TTL for Automatic Cleanup**:
   - Store Unix epoch timestamps in the TTL attribute
   - Reduces storage costs by auto-deleting expired items

5. **Enable PITR for Production Tables**:
   - Provides continuous backups for 35 days
   - Protect against accidental deletes or application bugs

6. **Security**:
   - Always enable encryption (default: AWS-owned keys)
   - Use customer-managed KMS keys for compliance requirements
   - Enable deletion protection for critical tables

## Troubleshooting

### Common Issues

1. **Attribute not defined**: Only define attributes used in keys or indexes
2. **LSI creation failed**: LSI can only be created at table creation time
3. **Global table replication failed**: Ensure streams are enabled with `NEW_AND_OLD_IMAGES`
4. **Auto-scaling not working**: Verify `billing_mode = PROVISIONED` and capacity values are set

## Related Resources

- [Root Module Documentation](../../modules/databases/non-relational/aws_dynamodb/README.md)
- [AWS DynamoDB Documentation](https://docs.aws.amazon.com/dynamodb/)
- [DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [DynamoDB Pricing](https://aws.amazon.com/dynamodb/pricing/)
- [DynamoDB Overview](../../modules/databases/non-relational/aws_dynamodb/aws-dynamodb.md)

## License

This wrapper is part of the aws.tf-modules repository and is licensed under the terms specified in the [LICENSE](../../LICENSE) file.
