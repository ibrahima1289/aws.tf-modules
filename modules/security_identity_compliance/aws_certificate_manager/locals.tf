locals {
  # Step 1: Generate immutable created date for consistent tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags shared by all ACM resources.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert list input to a stable map keyed by certificate key.
  certificates_map = {
    for certificate in var.certificates : certificate.key => certificate
  }

  # Step 4: Split public and imported certificates for safe argument handling.
  amazon_issued_certificates_map = {
    for key, certificate in local.certificates_map : key => certificate if upper(certificate.type) == "AMAZON_ISSUED"
  }

  imported_certificates_map = {
    for key, certificate in local.certificates_map : key => certificate if upper(certificate.type) == "IMPORTED"
  }

  # Step 5: Split imported certificates by certificate_chain presence to avoid null usage.
  imported_certificates_with_chain_map = {
    for key, certificate in local.imported_certificates_map : key => certificate if trimspace(certificate.certificate_chain) != ""
  }

  imported_certificates_without_chain_map = {
    for key, certificate in local.imported_certificates_map : key => certificate if trimspace(certificate.certificate_chain) == ""
  }

  # Step 6: Select only DNS certificates that should be validated by Terraform.
  validated_certificates_map = {
    for key, certificate in local.amazon_issued_certificates_map : key => certificate if(
      certificate.validate_certificate &&
      upper(certificate.validation_method) == "DNS" &&
      length(certificate.validation_record_fqdns) > 0
    )
  }
}
