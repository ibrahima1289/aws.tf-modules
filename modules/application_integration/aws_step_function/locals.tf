// Locals to normalize inputs and avoid null values

locals {
  // Single created date string reused across all resources
  created_date = formatdate("YYYY-MM-DD", timestamp())

  // Normalize state machine configurations with safe defaults
  state_machines = {
    for key, sm in var.state_machines :
    key => merge(
      {
        type                           = "STANDARD" # Default to STANDARD, can be EXPRESS if specified
        logging_enabled                = false
        logging_level                  = "ERROR" # Default to ERROR, can be DEBUG, INFO, or ALL if logging_enabled is true
        logging_include_execution_data = false
        logging_log_group_arn          = null
        tracing_enabled                = false
        kms_key_arn                    = null
        tags                           = {}
      },
      sm
    )
  }
}
