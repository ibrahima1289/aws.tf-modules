// Locals for AWS DynamoDB module (created date, normalized table settings)

locals {
  # CreatedDate tag to track when resources were provisioned
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Normalize table settings with sensible defaults to avoid null values
  tables = {
    for key, t in var.tables : key => merge(
      {
        // Default settings to avoid nulls in the resource
        billing_mode     = "PAY_PER_REQUEST"
        range_key        = null
        stream_enabled   = false
        stream_view_type = null

        read_capacity  = null
        write_capacity = null

        enable_autoscaling = false
        read_min_capacity  = null
        read_max_capacity  = null
        read_target_value  = 70
        write_min_capacity = null
        write_max_capacity = null
        write_target_value = 70

        ttl_enabled        = false
        ttl_attribute_name = null

        global_secondary_indexes = []
        local_secondary_indexes  = []

        point_in_time_recovery_enabled = false

        encryption_enabled = true
        kms_key_arn        = null

        table_class = "STANDARD"

        deletion_protection_enabled = false

        import_table = null

        replica_regions = []

        tags = {}
      },
      t
    )
  }

  # Flatten GSI autoscaling targets for easy iteration
  gsi_autoscaling_targets = merge([
    for table_key, table in local.tables : {
      for gsi in(table.enable_autoscaling && table.billing_mode == "PROVISIONED" ? coalesce(table.global_secondary_indexes, []) : []) :
      "${table_key}/${gsi.name}/read" => {
        table_name = table.name
        index_name = gsi.name
        type       = "read"
        min        = table.read_min_capacity
        max        = table.read_max_capacity
        target     = table.read_target_value
      }
      if gsi.read_capacity != null
    }
  ]...)

  gsi_write_autoscaling_targets = merge([
    for table_key, table in local.tables : {
      for gsi in(table.enable_autoscaling && table.billing_mode == "PROVISIONED" ? coalesce(table.global_secondary_indexes, []) : []) :
      "${table_key}/${gsi.name}/write" => {
        table_name = table.name
        index_name = gsi.name
        type       = "write"
        min        = table.write_min_capacity
        max        = table.write_max_capacity
        target     = table.write_target_value
      }
      if gsi.write_capacity != null
    }
  ]...)
}
