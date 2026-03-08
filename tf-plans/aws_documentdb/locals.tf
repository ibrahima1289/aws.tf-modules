locals {
  # Resolve master credentials for every cluster from one of three sources (in priority order):
  #   1. Inline master_username / master_password provided directly in the clusters variable
  #   2. The managed aws_secretsmanager_secret_version resource (created by secrets.tf)
  #   3. Error at apply time if neither is available (coalesce raises an error on all-null inputs)
  #
  # Referencing the resource directly (not a data source) avoids plan-time read failures:
  # on first apply the value is "known after apply"; on later plans it is known from state.
  clusters_resolved = {
    for key, cluster in var.clusters : key => merge(
      cluster,
      {
        # Priority: (1) inline value → (2) Secrets Manager resource → (3) null (fails in root module)
        # Conditional chain avoids coalesce(), which errors when all arguments are null.
        # try() returns null when the secret version resource has no instance for this key
        # (i.e. initial_credentials was not supplied); on first apply with initial_credentials
        # set the value is "known after apply" and resolves correctly at apply time.
        master_username = (
          cluster.master_username != null
          ? cluster.master_username
          : cluster.secret_name != null
          ? try(jsondecode(aws_secretsmanager_secret_version.docdb_credentials[key].secret_string)["username"], null)
          : null
        )
        master_password = (
          cluster.master_password != null
          ? cluster.master_password
          : cluster.secret_name != null
          ? try(jsondecode(aws_secretsmanager_secret_version.docdb_credentials[key].secret_string)["password"], null)
          : null
        )
      }
    )
  }
}