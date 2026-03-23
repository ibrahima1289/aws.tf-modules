# Step 1: Create one or more ACM public certificates with DNS/EMAIL validation options.
resource "aws_acm_certificate" "amazon_issued" {
  for_each = local.amazon_issued_certificates_map

  domain_name               = each.value.domain_name
  validation_method         = upper(each.value.validation_method)
  subject_alternative_names = each.value.subject_alternative_names
  key_algorithm             = each.value.key_algorithm

  # Step 2: Configure certificate transparency logging only when explicitly provided.
  dynamic "options" {
    for_each = trimspace(each.value.certificate_transparency_logging_preference) != "" ? [1] : []
    content {
      certificate_transparency_logging_preference = upper(each.value.certificate_transparency_logging_preference)
    }
  }

  # Step 3: Merge common tags, resource tags, and Name tag.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.domain_name
  })

  # Step 4: Avoid service disruption when replacing certificates.
  lifecycle {
    create_before_destroy = true
  }
}

# Step 5: Create one or more ACM private CA-issued certificates with managed renewal.
resource "aws_acm_certificate" "private_issued" {
  for_each = local.private_issued_certificates_map

  domain_name               = each.value.domain_name
  certificate_authority_arn = each.value.certificate_authority_arn
  subject_alternative_names = each.value.subject_alternative_names
  key_algorithm             = each.value.key_algorithm

  # Step 6: Merge common tags, resource tags, and Name tag for private-issued certificates.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.domain_name
  })

  # Step 7: Avoid service disruption when rotating private-issued certificates.
  lifecycle {
    create_before_destroy = true
  }
}

# Step 8: Create imported ACM certificates that include a certificate chain.
resource "aws_acm_certificate" "imported_with_chain" {
  for_each = local.imported_certificates_with_chain_map

  certificate_body  = each.value.certificate_body
  private_key       = each.value.private_key
  certificate_chain = each.value.certificate_chain

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.key
  })
}

# Step 9: Create imported ACM certificates that do not include a chain.
resource "aws_acm_certificate" "imported_without_chain" {
  for_each = local.imported_certificates_without_chain_map

  certificate_body = each.value.certificate_body
  private_key      = each.value.private_key

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.key
  })
}

# Step 10: Optionally validate DNS-validated public certificates.
resource "aws_acm_certificate_validation" "dns" {
  for_each = local.validated_certificates_map

  certificate_arn         = aws_acm_certificate.amazon_issued[each.key].arn
  validation_record_fqdns = each.value.validation_record_fqdns
}
