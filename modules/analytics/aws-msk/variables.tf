// Input variables for AWS MSK module

variable "region" {
  description = "AWS region to use for MSK clusters."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all MSK resources."
  type        = map(string)
  default     = {}
}

variable "clusters" {
  description = "Map of MSK clusters to create (key is a logical name)."
  type = map(object({
    cluster_name           = string
    kafka_version          = string
    number_of_broker_nodes = optional(number)

    # Broker node group configuration
    instance_type   = string
    client_subnets  = list(string)
    security_groups = list(string)
    ebs_volume_size = optional(number)

    # Optional configuration
    configuration_arn      = optional(string)
    configuration_revision = optional(number)

    # Encryption
    encryption_at_rest_kms_key_arn      = optional(string)
    encryption_in_transit_client_broker = optional(string) # e.g. "TLS", "TLS_PLAINTEXT"
    encryption_in_transit_in_cluster    = optional(bool)

    # Logging (CloudWatch, S3, Firehose)
    logging_cloudwatch_enabled   = optional(bool)
    logging_cloudwatch_log_group = optional(string)

    logging_s3_enabled = optional(bool)
    logging_s3_bucket  = optional(string)
    logging_s3_prefix  = optional(string)

    logging_firehose_enabled = optional(bool)
    logging_firehose_stream  = optional(string)

    # Client authentication
    client_auth_sasl_scram      = optional(bool)
    client_auth_sasl_iam        = optional(bool)
    client_auth_tls_enabled     = optional(bool)
    client_auth_unauthenticated = optional(bool)

    # Monitoring
    enhanced_monitoring = optional(string) # DEFAULT | PER_BROKER | PER_TOPIC_PER_BROKER | PER_TOPIC_PER_PARTITION

    open_monitoring_prometheus_jmx_exporter  = optional(bool)
    open_monitoring_prometheus_node_exporter = optional(bool)

    tags = optional(map(string))
  }))
}
