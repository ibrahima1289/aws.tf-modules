# Example configuration for the ALB plan
region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

vpc_id                 = "vpc-0123456789abcdef0"
subnet_ids             = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
alb_security_group_ids = ["sg-1234567890abcdef0"]

access_logs = {
  enabled = false
}

# Optional multi-ALB configuration. When provided, the plan will create
# these ALBs instead of the single-ALB above.
albs = [
  {
    name            = "demo-app-alb-1"
    subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    security_groups = ["sg-1234567890abcdef0"]
    internal        = false
    ip_address_type = "ipv4"
    access_logs = {
      enabled = false
    }
    tags = {
      Environment = "dev"
      Team        = "platform"
    }
    target_groups = [
      {
        name     = "tg-web-1"
        port     = 80
        protocol = "HTTP"
        health_check = {
          enabled           = true
          path              = "/health"
          interval          = 30
          timeout           = 5
          healthy_threshold = 5
          matcher           = "200-399"
        }
      }
    ]
    listeners = [
      {
        port                         = 80
        protocol                     = "HTTP"
        default_forward_target_group = "tg-web-1"
      }
    ]
  },
  {
    name            = "demo-app-alb-2"
    subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    security_groups = ["sg-1234567890abcdef0"]
    internal        = true
    ip_address_type = "ipv4"
    access_logs = {
      enabled = true
      bucket  = "my-logs-bucket"
      prefix  = "alb-2"
    }
    tags = {
      Environment = "dev"
      Team        = "platform"
    }
    target_groups = [
      {
        name     = "tg-web-2"
        port     = 443
        protocol = "HTTPS"
      }
    ]
    listeners = [
      {
        port                         = 443
        protocol                     = "HTTPS"
        ssl_policy                   = "ELBSecurityPolicy-2016-08"
        certificate_arn              = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-efgh-ijkl"
        default_forward_target_group = "tg-web-2"
      }
    ]
  }
]
