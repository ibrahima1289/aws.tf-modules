# Example configuration for the NLB plan
region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

vpc_id     = "vpc-0123456789abcdef0"

subnet_ids = [
  "subnet-aaa",
  "subnet-bbb", 
  "subnet-ccc"
]

# Optional multi-NLB configuration.
nlbs = [
  {
    name     = "nlb-1"
    cross_zone_load_balancing = true
    subnets  = [
      "subnet-aaa", 
      "subnet-bbb", 
      "subnet-ccc"
    ]
    internal = false

    access_logs = {
      enabled = false
    }

    target_groups = [
      {
        name     = "tg-1",
        port     = 80,
        protocol = "TCP"
      }
    ]

    listeners = [
      { port                         = 80,
        protocol                     = "TCP",
        default_forward_target_group = "tg-1"
      }
    ]
  },
  {
    name = "nlb-2"
    cross_zone_load_balancing = false
    subnets = [
      "subnet-aaa",
      "subnet-bbb",
      "subnet-ccc"
    ]

    internal = true

    access_logs = {
      enabled = true,
      bucket  = "my-logs-bucket",
      prefix  = "nlb-2"
    }

    target_groups = [
      {
        name     = "tg-2",
        port     = 443,
        protocol = "TLS"
      }
    ]

    listeners = [
      {
        port                         = 443,
        protocol                     = "TLS",
        ssl_policy                   = "ELBSecurityPolicy-TLS13-1-2-2021-06",
        certificate_arn              = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-efgh-ijkl",
        default_forward_target_group = "tg-2"
      }
    ]
  }
]
