# Local values for computed configurations
locals {
  # Auto-detect parameter group family if not provided
  parameter_family_map = {
    "mysql"         = "mysql8.0"
    "postgres"      = "postgres14"
    "mariadb"       = "mariadb10.6"
    "oracle-ee"     = "oracle-ee-19"
    "oracle-se2"    = "oracle-se2-19"
    "oracle-se1"    = "oracle-se1-11.2"
    "oracle-se"     = "oracle-se-11.2"
    "sqlserver-ee"  = "sqlserver-ee-15.0"
    "sqlserver-se"  = "sqlserver-se-15.0"
    "sqlserver-ex"  = "sqlserver-ex-15.0"
    "sqlserver-web" = "sqlserver-web-15.0"
  }

  # Use provided family or auto-detect
  parameter_group_family = var.parameter_group_family != null ? var.parameter_group_family : lookup(local.parameter_family_map, var.engine, "postgres14")

  # Generate DB subnet group name
  db_subnet_group_name = "${var.instance_name_prefix}-subnet-group"

  # Generate parameter group name if custom parameters are provided
  create_parameter_group = length(var.custom_parameters) > 0
  parameter_group_name   = local.create_parameter_group ? "${var.instance_name_prefix}-params" : null
}