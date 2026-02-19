// Locals for MSK module (created date, normalized cluster settings)

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  clusters = {
    for key, c in var.clusters : key => merge(
      {
        // Sensible defaults to avoid nulls
        number_of_broker_nodes                   = 3
        ebs_volume_size                          = 1000
        configuration_arn                        = null
        configuration_revision                   = null
        encryption_at_rest_kms_key_arn           = null
        encryption_in_transit_client_broker      = "TLS"
        encryption_in_transit_in_cluster         = true
        logging_cloudwatch_enabled               = false
        logging_cloudwatch_log_group             = null
        logging_s3_enabled                       = false
        logging_s3_bucket                        = null
        logging_s3_prefix                        = null
        logging_firehose_enabled                 = false
        logging_firehose_stream                  = null
        client_auth_sasl_scram                   = false
        client_auth_sasl_iam                     = false
        client_auth_tls_enabled                  = false
        client_auth_unauthenticated              = false
        enhanced_monitoring                      = "DEFAULT"
        open_monitoring_prometheus_jmx_exporter  = false
        open_monitoring_prometheus_node_exporter = false
        tags                                     = {}
      },
      c
    )
  }
}
