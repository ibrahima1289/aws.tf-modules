// Example terraform.tfvars for AWS DocumentDB wrapper
// Demonstrates three deployment patterns:
//   1. Single-node dev cluster  (active)
//   2. Multi-node production HA cluster with custom parameters  (commented out)
//   3. Restore-from-snapshot cluster  (commented out)

region = "us-east-1"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "DocumentDB"
}

# ---------------------------------------------------------------------------
# DocumentDB Clusters
# ---------------------------------------------------------------------------

clusters = {
  # ---------------------------------------------------------------------------
  # Example 1: Single-node development cluster
  # Minimum viable configuration — one t3.medium instance, standard storage,
  # 1-day backup retention, no deletion protection.
  # ---------------------------------------------------------------------------
  dev-cluster = {
    cluster_identifier = "app-docdb-dev"
    engine_version     = "5.0"
    # Credentials are fetched at plan/apply time from AWS Secrets Manager.
    # The secret must contain JSON: {"username": "...", "password": "..."}
    # Never commit plaintext passwords to version control.
    secret_name    = "docdb/dev-cluster/credentials" # Replace with your secret name or ARN
    instance_class = "db.t3.medium"
    instance_count = 1 # Single-node; no HA failover

    # VPC configuration — replace with real subnet and security group IDs
    subnet_ids             = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
    vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]

    # Storage: encrypted with the AWS-managed key; standard tier
    storage_encrypted = true
    storage_type      = "standard"

    # Backup: short retention for dev; snapshot skipped on deletion
    backup_retention_period = 1
    skip_final_snapshot     = true
    deletion_protection     = false

    # Export audit logs so activity is visible in CloudWatch Logs
    enabled_cloudwatch_logs_exports = ["audit"]

    tags = {
      Name = "app-docdb-dev"
      Type = "development"
    }
  }

  # ---------------------------------------------------------------------------
  # Example 2: Production HA cluster — 3 nodes, I/O-Optimized storage,
  # customer-managed KMS key, custom parameter group, and deletion protection.
  # Uncomment and replace placeholder IDs to use.
  # ---------------------------------------------------------------------------
  # prod-cluster = {
  #   cluster_identifier = "app-docdb-prod"
  #   engine_version     = "5.0"
  #   # Credentials fetched from Secrets Manager at plan/apply time
  #   secret_name        = "docdb/prod-cluster/credentials"
  #   instance_class     = "db.r5.large"
  #   instance_count     = 3 # 1 primary + 2 replicas across 3 AZs
  #
  #   subnet_ids             = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb", "subnet-ccccccccccccccccc"]
  #   vpc_security_group_ids = ["sg-yyyyyyyyyyyyyyyyy"]
  #
  #   # Customer-managed KMS key for storage encryption
  #   storage_encrypted = true
  #   kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  #   # I/O-Optimized storage: ~25% higher instance price but no per-I/O charges
  #   storage_type      = "iopt1"
  #
  #   backup_retention_period      = 7
  #   preferred_backup_window      = "03:00-04:00"
  #   preferred_maintenance_window = "sun:05:00-sun:06:00"
  #   skip_final_snapshot          = false
  #   final_snapshot_identifier    = "app-docdb-prod-final"
  #   deletion_protection          = true # Must be set to false before running terraform destroy
  #
  #   # Custom parameter group: enforce TLS and enable full audit logging
  #   parameter_group_family = "docdb5.0"
  #   parameters = [
  #     {
  #       name         = "tls"
  #       value        = "enabled"
  #       apply_method = "pending-reboot"
  #     },
  #     {
  #       name         = "audit_logs"
  #       value        = "all"
  #       apply_method = "pending-reboot"
  #     }
  #   ]
  #
  #   apply_immediately               = false
  #   auto_minor_version_upgrade      = true
  #   enabled_cloudwatch_logs_exports = ["audit", "profiler"]
  #
  #   tags = {
  #     Name = "app-docdb-prod"
  #     Type = "production"
  #   }
  # }

  # ---------------------------------------------------------------------------
  # Example 3: Restore cluster from an existing snapshot
  # Useful for disaster recovery testing or spinning up a staging environment
  # from a production snapshot.
  # ---------------------------------------------------------------------------
  # restored-cluster = {
  #   cluster_identifier  = "app-docdb-restored"
  #   engine_version      = "5.0"
  #   # Credentials fetched from Secrets Manager at plan/apply time
  #   secret_name         = "docdb/restored-cluster/credentials"
  #   instance_class      = "db.r5.large"
  #   instance_count      = 1
  #   # ARN or identifier of the snapshot to restore from
  #   snapshot_identifier = "arn:aws:rds:us-east-1:123456789012:cluster-snapshot:app-docdb-prod-final"
  #
  #   subnet_ids             = ["subnet-aaaaaaaaaaaaaaaaa", "subnet-bbbbbbbbbbbbbbbbb"]
  #   vpc_security_group_ids = ["sg-zzzzzzzzzzzzzzzzz"]
  #
  #   storage_encrypted   = true
  #   skip_final_snapshot = true
  #   deletion_protection = false
  #
  #   tags = {
  #     Name = "app-docdb-restored"
  #     Type = "restore-test"
  #   }
  # }
}
