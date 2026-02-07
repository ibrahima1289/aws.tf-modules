# Terraform variables for the Route 53 wrapper
region = "us-east-1"

zones = {
  public_full_options = {
    zone_name     = "example-2026.com"
    is_private    = false
    comment       = "Public zone managed by Terraform"
    force_destroy = true # Allow deletion even with non-Terraform records

    # enable_query_log         = true
    # cloudwatch_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/example"

    allow_overwrite = true

    tags = {
      Environment = "dev"
      Owner       = "platform-team"
    }

    records = {
      # Basic A record
      root_a = {
        name    = "example-2026.com"
        type    = "A"
        ttl     = 300
        records = ["203.0.113.10"]
      }

      # Basic CNAME
      www_cname = {
        name    = "www"
        type    = "CNAME"
        ttl     = 300
        records = ["example-2026.com"]
      }

      # # Weighted routing policy
      # api_weighted = {
      #   name                 = "api"
      #   type                 = "A"
      #   ttl                  = 60
      #   records              = ["203.0.113.20"]
      #   set_identifier       = "api-weight-1"
      #   weighted_routing_policy = { weight = 100 }
      # }

      # # Latency routing policy
      # app_latency = {
      #   name                   = "app"
      #   type                   = "A"
      #   ttl                    = 60
      #   records                = ["203.0.113.30"]
      #   set_identifier         = "app-latency-us-east-1"
      #   latency_routing_policy = { region = "us-east-1" }
      # }

      # # Failover routing (PRIMARY)
      # db_failover_primary = {
      #   name                    = "db"
      #   type                    = "A"
      #   ttl                     = 60
      #   records                 = ["203.0.113.40"]
      #   set_identifier          = "db-primary"
      #   failover_routing_policy = { type = "PRIMARY" }
      # }

      # # Failover routing (SECONDARY)
      # db_failover_secondary = {
      #   name                    = "db"
      #   type                    = "A"
      #   ttl                     = 60
      #   records                 = ["203.0.113.41"]
      #   set_identifier          = "db-secondary"
      #   failover_routing_policy = { type = "SECONDARY" }
      # }

      # # Geolocation routing (country-specific)
      # shop_geo_us = {
      #   name                         = "shop"
      #   type                         = "A"
      #   ttl                          = 60
      #   records                      = ["203.0.113.50"]
      #   set_identifier               = "shop-us"
      #   geolocation_routing_policy   = { country = "US" }
      # }

      # # Geolocation routing (continent)
      # shop_geo_eu = {
      #   name                         = "shop"
      #   type                         = "A"
      #   ttl                          = 60
      #   records                      = ["203.0.113.51"]
      #   set_identifier               = "shop-eu"
      #   geolocation_routing_policy   = { continent = "EU" }
      # }

      # # CIDR routing policy (requires a pre-defined CIDR collection)
      # svc_cidr = {
      #   name               = "svc"
      #   type               = "A"
      #   ttl                = 60
      #   records            = ["10.0.0.25"]
      #   set_identifier     = "svc-cidr-loc1"
      #   cidr_routing_policy = {
      #     collection_id = "cc-0a1b2c3d4e5f6g7h8"  # Example CIDR collection ID
      #     location_name = "location-1"            # Example location created within the collection
      #   }
      # }

      # # Multi-value answers
      # api_multi = {
      #   name       = "multi-api"
      #   type       = "A"
      #   ttl        = 30
      #   records    = ["203.0.113.60", "203.0.113.61", "203.0.113.62"]
      #   multivalue_answer_routing_policy = true
      # }

      # # Health-checked record
      # api_health = {
      #   name            = "hc-api"
      #   type            = "A"
      #   ttl             = 60
      #   records         = ["203.0.113.70"]
      #   health_check_id = "12345678-aaaa-bbbb-cccc-1234567890ab" # Example health check ID
      # }

      # # Alias to an ALB (example)
      # alb_alias = {
      #   name  = "app"
      #   type  = "A"
      #   alias = {
      #     name                   = "dualstack.alb-xyz.us-east-1.elb.amazonaws.com"
      #     zone_id                = "Z35SXDOTRQ7X7K"
      #     evaluate_target_health = true
      #   }
      # }
    }
  }

  # private_full_options = {
  #   zone_name   = "corp.local"
  #   is_private  = true

  #   # Associate multiple VPCs (specify region if different from provider region)
  #   vpc_associations = [
  #     { vpc_id = "vpc-0123456789abcdef0", region = "us-east-1" },
  #     { vpc_id = "vpc-abcdef0123456789",  region = "us-west-2" }
  #   ]

  #   enable_query_log         = false
  #   cloudwatch_log_group_arn = null

  #   allow_overwrite = false
  #   prevent_destroy = true

  #   tags = {
  #     Environment = "dev"
  #     Owner       = "networking-team"
  #   }

  #   records = {
  #     # Private A record
  #     api_a = {
  #       name    = "api"
  #       type    = "A"
  #       ttl     = 60
  #       records = ["10.0.0.50"]
  #     }

  #     # Private SRV record example
  #     ldap_srv = {
  #       name    = "_ldap._tcp"
  #       type    = "SRV"
  #       ttl     = 60
  #       records = ["0 10 389 ldap.corp.local"]
  #     }
  #   }
  # }
}
