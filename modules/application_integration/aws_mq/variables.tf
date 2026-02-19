// Input variables for AWS MQ module

variable "region" {
  description = "AWS region to use for Amazon MQ brokers."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Amazon MQ resources."
  type        = map(string)
  default     = {}
}

variable "brokers" {
  description = "Map of Amazon MQ brokers to create (key is a logical name)."
  type = map(object({
    broker_name        = string
    engine_type        = string # e.g. "ActiveMQ" or "RabbitMQ"
    engine_version     = string
    host_instance_type = string

    # Networking
    subnet_ids      = list(string)
    security_groups = list(string)

    # Deployment and behavior
    deployment_mode            = optional(string) # SINGLE_INSTANCE | ACTIVE_STANDBY_MULTI_AZ | CLUSTER_MULTI_AZ
    publicly_accessible        = optional(bool)
    auto_minor_version_upgrade = optional(bool)
    apply_immediately          = optional(bool)
    storage_type               = optional(string) # EBS | EFS (depending on engine)

    # Authentication strategy
    authentication_strategy = optional(string) # SIMPLE | LDAP

    # Encryption options
    kms_key_id        = optional(string)
    use_aws_owned_key = optional(bool)

    # Maintenance window
    maintenance_day_of_week = optional(string) # e.g. MONDAY
    maintenance_time_of_day = optional(string) # HH:MM in 24h
    maintenance_time_zone   = optional(string) # e.g. UTC

    # Logs
    general_logs_enabled = optional(bool)
    audit_logs_enabled   = optional(bool)

    # Users (at least one required per broker)
    users = list(object({
      username       = string
      password       = string
      console_access = optional(bool)
      groups         = optional(list(string))
    }))

    # Per-broker tags
    tags = optional(map(string))
  }))
}
