# Outputs for the AWS Elastic Beanstalk Module.

output "application_names" {
  description = "Map of application key to Elastic Beanstalk application name."
  value       = { for k, v in aws_elastic_beanstalk_application.app : k => v.name }
}

output "environment_names" {
  description = "Map of environment key to Elastic Beanstalk environment name."
  value       = { for k, v in aws_elastic_beanstalk_environment.env : k => v.name }
}

output "environment_ids" {
  description = "Map of environment key to Elastic Beanstalk environment ID."
  value       = { for k, v in aws_elastic_beanstalk_environment.env : k => v.id }
}

output "environment_cnames" {
  description = "Map of environment key to Elastic Beanstalk CNAME (load balancer DNS name)."
  value       = { for k, v in aws_elastic_beanstalk_environment.env : k => v.cname }
}

output "environment_endpoints" {
  description = "Map of environment key to Elastic Beanstalk endpoint URL."
  value       = { for k, v in aws_elastic_beanstalk_environment.env : k => v.endpoint_url }
}

output "environment_tiers" {
  description = "Map of environment key to environment tier (WebServer or Worker)."
  value       = { for k, v in aws_elastic_beanstalk_environment.env : k => v.tier }
}
