# Step 1: Call the reusable AWS WAF v2 module.
module "waf" {
  source = "../../modules/security_identity_compliance/aws_waf"

  # Step 2: Set region and inject created_date into the global tags.
  # For CLOUDFRONT-scoped Web ACLs, region must be "us-east-1".
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass IP sets — reusable address lists referenced by Web ACL rules.
  ip_sets = var.ip_sets

  # Step 4: Pass regex pattern sets — reusable PCRE patterns for custom matching.
  regex_pattern_sets = var.regex_pattern_sets

  # Step 5: Pass the full list of Web ACL definitions including rules, associations,
  # and logging configuration.
  web_acls = var.web_acls
}
