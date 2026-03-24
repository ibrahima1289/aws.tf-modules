# Outputs for the AWS Elastic Beanstalk wrapper.
# Pass through all module outputs for use in downstream configurations.

output "application_names" {
  description = "Map of application key to Elastic Beanstalk application name."
  value       = module.beanstalk.application_names
}

output "environment_names" {
  description = "Map of environment key to Elastic Beanstalk environment name."
  value       = module.beanstalk.environment_names
}

output "environment_ids" {
  description = "Map of environment key to Elastic Beanstalk environment ID."
  value       = module.beanstalk.environment_ids
}

output "environment_cnames" {
  description = "Map of environment key to Elastic Beanstalk CNAME (load balancer DNS name)."
  value       = module.beanstalk.environment_cnames
}

output "environment_endpoints" {
  description = "Map of environment key to Elastic Beanstalk endpoint URL."
  value       = module.beanstalk.environment_endpoints
}

output "environment_tiers" {
  description = "Map of environment key to environment tier (WebServer or Worker)."
  value       = module.beanstalk.environment_tiers
}
