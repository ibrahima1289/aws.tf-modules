# Step 1: Expose ACM certificate ARNs.
output "certificate_arns" {
  description = "Map of certificate key to ACM certificate ARN"
  value       = module.certificate_manager.certificate_arns
}

# Step 2: Expose ACM certificate statuses.
output "certificate_statuses" {
  description = "Map of certificate key to ACM certificate status"
  value       = module.certificate_manager.certificate_statuses
}

# Step 3: Expose domains for ACM-managed certificates.
output "managed_certificate_domains" {
  description = "Map of ACM-managed certificate key to primary domain name"
  value       = module.certificate_manager.managed_certificate_domains
}

# Step 4: Expose validated certificate ARNs.
output "validated_certificate_arns" {
  description = "Map of certificate key to certificate ARN validated by Terraform"
  value       = module.certificate_manager.validated_certificate_arns
}

# Step 5: Expose auto-renewing ACM certificate ARNs.
output "auto_renewing_certificate_arns" {
  description = "Map of ACM-managed certificate key to certificate ARN renewed automatically by ACM"
  value       = module.certificate_manager.auto_renewing_certificate_arns
}
