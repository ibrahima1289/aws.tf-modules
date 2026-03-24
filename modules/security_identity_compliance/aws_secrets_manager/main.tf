# Terraform AWS Secrets Manager Module
# This module creates AWS Secrets Manager secrets with optional static values,
# automatic rotation, resource-based policies, and multi-region replication.
# Supports creating multiple secrets in a single module call via for_each.

# Step 1: Create one or more secret containers from the secrets input list.
# The secret container holds metadata; the value is managed in a separate resource.
resource "aws_secretsmanager_secret" "secret" {
  for_each = local.secrets_map

  name                    = each.value.name
  description             = each.value.description != null ? each.value.description : "Managed by Terraform"
  kms_key_id              = each.value.kms_key_id
  recovery_window_in_days = each.value.recovery_window_in_days

  # Step 2: Optionally replicate the secret to one or more additional AWS regions.
  # Useful for multi-region applications and disaster recovery setups.
  dynamic "replica" {
    for_each = each.value.replica_regions != null ? each.value.replica_regions : []
    content {
      region     = replica.value.region
      kms_key_id = replica.value.kms_key_id
    }
  }

  # Step 3: Merge common tags, per-secret tags, and the Name tag for identification.
  tags = merge(local.common_tags, each.value.tags != null ? each.value.tags : {}, {
    Name = each.value.name
  })
}

# Step 4: Optionally store a static secret string value.
# Only applies to secrets where secret_string is provided.
# Omit secret_string when rotation or an external process manages the value.
resource "aws_secretsmanager_secret_version" "value" {
  for_each = local.secrets_with_string_map

  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = each.value.secret_string

  # Step 5: Prevent Terraform from overwriting values changed externally (e.g. by rotation).
  lifecycle {
    ignore_changes = [secret_string, version_stages]
  }
}

# Step 6: Optionally configure automatic rotation via a Lambda function.
# rotation_lambda_arn must point to a Secrets Manager-compatible rotation Lambda.
resource "aws_secretsmanager_secret_rotation" "rotation" {
  for_each = local.secrets_with_rotation_map

  secret_id           = aws_secretsmanager_secret.secret[each.key].id
  rotation_lambda_arn = each.value.rotation_lambda_arn

  rotation_rules {
    # Step 7: Set how frequently (in days) the rotation Lambda is invoked.
    automatically_after_days = each.value.rotation_days
  }
}

# Step 8: Optionally attach a resource-based policy to control access.
# Useful for cross-account access or fine-grained service-level permissions.
resource "aws_secretsmanager_secret_policy" "policy" {
  for_each = local.secrets_with_policy_map

  secret_arn = aws_secretsmanager_secret.secret[each.key].arn
  policy     = each.value.policy
}
