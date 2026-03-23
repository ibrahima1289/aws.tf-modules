# Step 1: Return certificate ARNs for all created ACM certificates.
output "certificate_arns" {
  description = "Map of certificate key to ACM certificate ARN"
  value = merge(
    { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.arn },
    { for key, certificate in aws_acm_certificate.imported_with_chain : key => certificate.arn },
    { for key, certificate in aws_acm_certificate.imported_without_chain : key => certificate.arn }
  )
}

# Step 2: Return certificate statuses for lifecycle visibility.
output "certificate_statuses" {
  description = "Map of certificate key to ACM certificate status"
  value = merge(
    { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.status },
    { for key, certificate in aws_acm_certificate.imported_with_chain : key => certificate.status },
    { for key, certificate in aws_acm_certificate.imported_without_chain : key => certificate.status }
  )
}

# Step 3: Return domain names for public certificate entries.
output "public_certificate_domains" {
  description = "Map of public certificate key to primary domain name"
  value       = { for key, certificate in aws_acm_certificate.amazon_issued : key => certificate.domain_name }
}

# Step 4: Return validated certificate ARNs when validation is enabled.
output "validated_certificate_arns" {
  description = "Map of certificate key to certificate ARN validated by aws_acm_certificate_validation"
  value       = { for key, validation in aws_acm_certificate_validation.dns : key => validation.certificate_arn }
}
