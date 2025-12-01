# Terraform AWS IAM Module
# This module creates IAM users, groups, policies, attaches the policy to the groups, adds users to groups, and can optionally create access keys for users.

# Create multiple IAM users
resource "aws_iam_user" "user" {
  for_each             = { for u in var.users : u.name => u }
  name                 = each.value.name
  path                 = lookup(each.value, "path", "/")
  force_destroy        = lookup(each.value, "force_destroy", false)
  permissions_boundary = lookup(each.value, "permissions_boundary", null)
  tags                 = merge(var.tags, lookup(each.value, "tags", {}))
}

# Create multiple IAM groups
resource "aws_iam_group" "group" {
  for_each = { for g in var.groups : g.name => g }
  name     = each.value.name
  path     = lookup(each.value, "path", "/")
}

# Add users to groups (user_group_memberships)
resource "aws_iam_user_group_membership" "group_membership" {
  for_each = { for assoc in var.user_group_memberships : "${assoc.user}_${join("_", assoc.groups)}" => assoc }
  user     = aws_iam_user.user[each.value.user].name
  groups   = [for g in each.value.groups : aws_iam_group.group[g].name]
}

# Create custom IAM policies
resource "aws_iam_policy" "policy" {
  for_each    = { for p in var.policies : p.name => p }
  name        = each.value.name
  path        = lookup(each.value, "path", "/")
  description = lookup(each.value, "description", "")
  policy      = each.value.policy_json
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "policy_attachment" {
  for_each   = { for attach in var.group_policy_attachments : "${attach.group}_${attach.policy}" => attach }
  group      = aws_iam_group.group[each.value.group].name
  policy_arn = aws_iam_policy.policy[each.value.policy].arn
}

# Optionally create access keys for users
resource "aws_iam_access_key" "user_key" {
  for_each   = { for u in var.users : u.name => u if lookup(u, "create_access_key", false) }
  user       = aws_iam_user.user[each.key].name
  pgp_key    = lookup(each.value, "access_key_pgp_key", null)
  status     = lookup(each.value, "access_key_status", "Active")
  depends_on = [aws_iam_user.user]
  lifecycle {
    create_before_destroy = true
  }
}

# Store the access key secret in AWS Secrets Manager
resource "aws_secretsmanager_secret" "access_key_secret" {
  for_each = aws_iam_access_key.user_key
  name     = "iam-access-key-secret-${each.key}"
}

resource "aws_secretsmanager_secret_version" "access_key_secret_version" {
  for_each      = aws_iam_access_key.user_key
  secret_id     = aws_secretsmanager_secret.access_key_secret[each.key].id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.user_key[each.key].id
    secret_access_key = aws_iam_access_key.user_key[each.key].secret
  })
}
