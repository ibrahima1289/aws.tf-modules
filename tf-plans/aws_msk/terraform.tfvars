# Example terraform.tfvars for AWS MSK wrapper

region = "us-east-1"
tags = {
  Environment = "dev"
  Team        = "platform"
}

clusters = {
  # Basic MSK cluster with default security and monitoring
  example_msk_basic = {
    cluster_name           = "example-msk-basic"
    kafka_version          = "3.6.0"
    number_of_broker_nodes = 3
    instance_type          = "kafka.m5.large"
    client_subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    security_groups        = ["sg-aaa"]
    ebs_volume_size        = 1000
  }

  # MSK cluster with encryption, logging, client authentication, and open monitoring
  example_msk_full = {
    cluster_name           = "example-msk-full"
    kafka_version          = "3.6.0"
    number_of_broker_nodes = 6
    instance_type          = "kafka.m5.xlarge"
    client_subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    security_groups        = ["sg-aaa", "sg-bbb"]
    ebs_volume_size        = 2000

    configuration_arn      = "arn:aws:kafka:us-east-1:123456789012:configuration/example-config/00000000-0000-0000-0000-000000000000" # replace with your config ARN
    configuration_revision = 1

    encryption_at_rest_kms_key_arn      = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000" # replace with your KMS key ARN
    encryption_in_transit_client_broker = "TLS"
    encryption_in_transit_in_cluster    = true

    logging_cloudwatch_enabled   = true
    logging_cloudwatch_log_group = "/aws/msk/example-full"

    logging_s3_enabled = true
    logging_s3_bucket  = "my-msk-logs-bucket" # replace with your bucket
    logging_s3_prefix  = "msk/logs/"

    logging_firehose_enabled = true
    logging_firehose_stream  = "msk-logs-stream" # replace with your Firehose stream

    client_auth_sasl_scram      = true
    client_auth_sasl_iam        = false
    client_auth_tls_enabled     = true
    client_auth_unauthenticated = false
    enhanced_monitoring         = "PER_BROKER"

    open_monitoring_prometheus_jmx_exporter  = true
    open_monitoring_prometheus_node_exporter = true

    tags = {
      Environment = "prod"
      Purpose     = "streaming-platform"
    }
  }
}
