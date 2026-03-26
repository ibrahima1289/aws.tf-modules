# Variables for the AWS Elastic Beanstalk wrapper.
# Types mirror the module variables exactly.

variable "region" {
  description = "AWS region where Elastic Beanstalk resources are deployed."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Elastic Beanstalk resources."
  type        = map(string)
  default     = {}
}

variable "applications" {
  description = "List of Elastic Beanstalk application definitions. See module README for full schema."
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "")
    tags        = optional(map(string), {})

    appversion_lifecycle = optional(object({
      service_role          = string
      max_count             = optional(number)
      max_age_in_days       = optional(number)
      delete_source_from_s3 = optional(bool, true)
    }))
  }))
  default = []
}

variable "environments" {
  description = "List of Elastic Beanstalk environment definitions. See module README for full schema."
  type = list(object({
    key             = string
    name            = string
    application_key = string
    description     = optional(string, "")
    solution_stack  = string

    tier             = optional(string, "WebServer")
    environment_type = optional(string, "LoadBalanced")

    instance_type        = optional(string, "t3.micro")
    iam_instance_profile = optional(string, "aws-elasticbeanstalk-ec2-role")
    ec2_key_name         = optional(string)
    service_role         = optional(string)

    min_instances = optional(number, 1)
    max_instances = optional(number, 4)

    load_balancer_type = optional(string, "application")
    deployment_policy  = optional(string, "Rolling")
    health_check_path  = optional(string, "/")
    health_reporting   = optional(string, "enhanced")

    vpc_id           = optional(string)
    instance_subnets = optional(list(string), [])
    elb_subnets      = optional(list(string), [])

    env_vars = optional(map(string), {})

    custom_settings = optional(list(object({
      namespace = string
      name      = string
      value     = string
      resource  = optional(string, "")
    })), [])

    tags = optional(map(string), {})
  }))
  default = []
}
