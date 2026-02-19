# Example terraform.tfvars for AWS MQ wrapper

region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

brokers = {
  # Basic ActiveMQ broker with minimal configuration
  example_mq_basic = {
    broker_name        = "example-mq-basic"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.m5.large"

    subnet_ids      = ["subnet-aaa", "subnet-bbb"]
    security_groups = ["sg-aaa"]

    users = [
      {
        username = "app-user"
        password = "CHANGE_ME_STRONG_PASSWORD" # replace with a secure value or use TF vars
      }
    ]
  }

  # ActiveMQ broker with encryption, custom maintenance window, and logs enabled
  example_mq_full = {
    broker_name        = "example-mq-full"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.m5.large"

    subnet_ids      = ["subnet-aaa", "subnet-bbb"]
    security_groups = ["sg-aaa", "sg-bbb"]

    deployment_mode            = "ACTIVE_STANDBY_MULTI_AZ"
    publicly_accessible        = false
    auto_minor_version_upgrade = true
    apply_immediately          = true
    storage_type               = "EBS"

    authentication_strategy = "SIMPLE"

    kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000" # replace with your KMS key
    use_aws_owned_key = false

    maintenance_day_of_week = "SUNDAY"
    maintenance_time_of_day = "02:00"
    maintenance_time_zone   = "UTC"

    general_logs_enabled = true
    audit_logs_enabled   = true

    users = [
      {
        username       = "admin-user"
        password       = "CHANGE_ME_STRONG_PASSWORD" # replace securely
        console_access = true
        groups         = ["admins"]
      },
      {
        username = "consumer-user"
        password = "CHANGE_ME_STRONG_PASSWORD" # replace securely
        groups   = ["consumers"]
      }
    ]

    tags = {
      Environment = "prod"
      Purpose     = "messaging-platform"
    }
  }
}
