// Provision the Secrets Manager secret path for every cluster that uses secret_name.
// On first apply: secret resource is created, then the data source in data.tf reads it.
// On subsequent plans: secret already exists, data source reads it at plan time normally.

# Create the secret path (name/ARN) for each cluster that references a secret_name
resource "aws_secretsmanager_secret" "docdb_credentials" {
  for_each = {
    for key, cluster in var.clusters : key => cluster
    if cluster.secret_name != null
  }

  name        = each.value.secret_name
  description = "Master credentials for DocumentDB cluster ${each.value.cluster_identifier}"

  tags = merge(var.tags, {
    ClusterKey = each.key
  })
}

# Write the initial secret value using credentials supplied via TF_VAR_initial_credentials.
# Only created when a matching entry exists in var.initial_credentials.
# The lifecycle block ensures Terraform never overwrites a value that was rotated externally.
resource "aws_secretsmanager_secret_version" "docdb_credentials" {
  for_each = {
    for key, cluster in var.clusters : key => cluster
    if cluster.secret_name != null && try(var.initial_credentials[key], null) != null
  }

  secret_id = aws_secretsmanager_secret.docdb_credentials[each.key].id

  # Store credentials as JSON — shape expected by the data.tf decoder
  secret_string = jsonencode({
    username = var.initial_credentials[each.key].username
    password = var.initial_credentials[each.key].password
  })

  # Ignore future diffs so Terraform never rolls back externally-rotated passwords
  lifecycle {
    ignore_changes = [secret_string]
  }
}
