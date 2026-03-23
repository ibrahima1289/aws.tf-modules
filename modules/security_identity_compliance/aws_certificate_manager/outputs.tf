# Step 1: Return certificate ARNs for all created ACM certificates.
output "certificate_arns" {
  description = "Map of certificate key to ACM certificate ARN"
  value = merge(
    { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.arn },
    { for key, certificate in aws_acm_certificate.private_issued : key => certificate.arn },
    { for key, certificate in aws_acm_certificate.imported_with_chain : key => certificate.arn },
    { for key, certificate in aws_acm_certificate.imported_without_chain : key => certificate.arn }
  )
}

# Step 2: Return certificate statuses for lifecycle visibility.
output "certificate_statuses" {
  description = "Map of certificate key to ACM certificate status"
  value = merge(
    { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.status },
    { for key, certificate in aws_acm_certificate.private_issued : key => certificate.status },
    { for key, certificate in aws_acm_certificate.imported_with_chain : key => certificate.status },
    { for key, certificate in aws_acm_certificate.imported_without_chain : key => certificate.status }
  )
}

# Step 3: Return domain names for ACM-managed renewable certificate entries.
output "managed_certificate_domains" {
  description = "Map of ACM-managed certificate key to primary domain name"
  value = merge(
    { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.domain_name },
    { for key, certificate in aws_acm_certificate.private_issued : key => certificate.domain_name }
  )
}

# Step 4: Return validated certificate ARNs when validation is enabled.
output "validated_certificate_arns" {
  description = "Map of certificate key to certificate ARN validated by aws_acm_certificate_validation"
  value       = { for key, validation in aws_acm_certificate_validation.dns : key => validation.certificate_arn }
}

# Step 5: Return certificates ACM can renew automatically.
output "auto_renewing_certificate_arns" {
  description = "Map of ACM-managed certificate key to certificate ARN for certificates renewed automatically by ACM"
  value = merge(
    { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.arn },
    { for key, certificate in aws_acm_certificate.private_issued : key => certificate.arn }
  )
}
