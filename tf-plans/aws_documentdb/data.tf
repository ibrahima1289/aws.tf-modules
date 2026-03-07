// data.tf — intentionally empty.
//
// Credentials are no longer read via a data source because data sources are
// evaluated at plan time, which fails when the secret does not yet exist.
//
// Instead, main.tf locals reference the managed resource
// aws_secretsmanager_secret_version.docdb_credentials[key] directly:
//   - First apply  : value is "(known after apply)" → plan shows it, apply succeeds.
//   - Later plans  : resource is in state → value is fully known at plan time.
