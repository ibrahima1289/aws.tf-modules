// Locals for AWS MQ module (created date, normalized broker settings)

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  brokers = {
    for key, b in var.brokers : key => merge(
      {
        // Sensible defaults to avoid nulls in the resource
        deployment_mode            = "SINGLE_INSTANCE"
        publicly_accessible        = false
        auto_minor_version_upgrade = true
        apply_immediately          = true
        storage_type               = "EBS"
        authentication_strategy    = "SIMPLE"

        subnet_ids      = []
        security_groups = []

        kms_key_id        = null
        use_aws_owned_key = true

        maintenance_day_of_week = null
        maintenance_time_of_day = null
        maintenance_time_zone   = null

        general_logs_enabled = false
        audit_logs_enabled   = false

        tags = {}
      },
      b,
      {
        // Normalize user-level optional fields to avoid nulls
        users = [
          for u in b.users : merge(
            {
              console_access = false
              groups         = []
            },
            u
          )
        ]
      }
    )
  }
}
