# ─────────────────────────────────────────────────────────────────────────────
# AWS Region
# ─────────────────────────────────────────────────────────────────────────────
region = "us-east-1"

# ─────────────────────────────────────────────────────────────────────────────
# Global Tags
# ─────────────────────────────────────────────────────────────────────────────
tags = {
  environment = "production"
  team        = "platform"
  project     = "beanstalk-apps"
  managed_by  = "terraform"
}

# ─────────────────────────────────────────────────────────────────────────────
# Applications
# Each application is a logical container for environments and versions.
# ─────────────────────────────────────────────────────────────────────────────
applications = [
  # Application 1: Customer-facing Node.js web app.
  # Hosts the staging and production WebServer environments below.
  {
    key         = "node-web"
    name        = "node-web-application"
    description = "Customer-facing Node.js 20 web application"
    tags        = { language = "nodejs" }

    # Delete old versions automatically; keep only the 10 most recent.
    appversion_lifecycle = {
      service_role          = "arn:aws:iam::123456789012:role/aws-elasticbeanstalk-service-role"
      max_count             = 10
      delete_source_from_s3 = true
    }
  },

  # Application 2: Python background worker.
  # Processes async order events from an SQS queue via the Worker tier.
  {
    key         = "python-worker"
    name        = "python-worker-application"
    description = "Python 3.11 background worker for async order processing"
    tags        = { language = "python" }

    appversion_lifecycle = {
      service_role          = "arn:aws:iam::123456789012:role/aws-elasticbeanstalk-service-role"
      max_count             = 5
      delete_source_from_s3 = true
    }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Environments
# Each environment maps to a live set of AWS resources (EC2, ALB, ASG, etc.)
# running one version of its parent application.
# ─────────────────────────────────────────────────────────────────────────────
environments = [

  # ── Environment 1: Node.js development — single instance, low cost ─────────
  # Used for smoke-testing before promoting a release to production.
  # No load balancer; a single t3.micro is enough for pre-production validation.
  {
    key             = "node-dev"
    name            = "node-web-dev"
    application_key = "node-web"
    description     = "Development environment for smoke-testing before production release"
    solution_stack  = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
    tier            = "WebServer"

    # SingleInstance avoids the cost of an ALB for non-production environments.
    environment_type = "SingleInstance"
    instance_type    = "t3.micro"

    # AllAtOnce is acceptable for staging — downtime during deploys is fine.
    deployment_policy = "AllAtOnce"
    health_check_path = "/health"
    health_reporting  = "enhanced"

    min_instances = 1
    max_instances = 1

    env_vars = {
      NODE_ENV  = "dev"
      LOG_LEVEL = "debug"
      PORT      = "8080"
    }

    tags = { environment-tier = "dev" }
  },

  # ── Environment 2: Node.js production — load balanced, multi-AZ ──────────
  # High-availability production environment with an ALB, rolling deployments,
  # and CPU-based auto-scaling across two private subnets.
  {
    key             = "node-production"
    name            = "node-web-production"
    application_key = "node-web"
    description     = "Production load-balanced environment with rolling deploys"
    solution_stack  = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
    tier            = "WebServer"

    environment_type     = "LoadBalanced"
    instance_type        = "t3.small"
    iam_instance_profile = "aws-elasticbeanstalk-ec2-role"
    service_role         = "arn:aws:iam::123456789012:role/aws-elasticbeanstalk-service-role"

    # Roll 30 % of instances at a time; zero-downtime deploys.
    deployment_policy = "Rolling"
    health_check_path = "/health"
    health_reporting  = "enhanced"

    min_instances      = 2
    max_instances      = 6
    load_balancer_type = "application" # ALB (default) for HTTP apps; NLB or Classic LB also supported.

    # Deploy into private subnets; ALB listeners on public subnets.
    vpc_id           = "vpc-0a1b2c3d4e5f67890"
    instance_subnets = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f678901a"]
    elb_subnets      = ["subnet-0c3d4e5f678901ab2", "subnet-0d4e5f678901ab3c"]

    env_vars = {
      NODE_ENV       = "production"
      LOG_LEVEL      = "info"
      PORT           = "8080"
      CACHE_ENDPOINT = "redis.internal.example.com:6379"
    }

    # CPU-based scaling triggers via custom_settings.
    custom_settings = [
      { namespace = "aws:autoscaling:trigger", name = "MeasureName", value = "CPUUtilization" },
      { namespace = "aws:autoscaling:trigger", name = "UpperThreshold", value = "70" },
      { namespace = "aws:autoscaling:trigger", name = "LowerThreshold", value = "30" },
    ]

    tags = { environment-tier = "production" }
  },

  # ── Environment 3: Python Worker — processes SQS order events ─────────────
  # Worker tier: EBS provisions an on-instance SQS daemon that pulls messages
  # and POSTs them to a local HTTP endpoint on each instance.
  # No load balancer or public subnets needed.
  {
    key             = "python-worker-prod"
    name            = "python-worker-production"
    application_key = "python-worker"
    description     = "Worker tier processes order events from the SQS queue"
    solution_stack  = "64bit Amazon Linux 2023 v4.1.0 running Python 3.11"
    tier            = "Worker"

    # SingleInstance for Worker tier (EBS manages the SQS daemon per instance).
    environment_type     = "SingleInstance"
    instance_type        = "t3.small"
    iam_instance_profile = "aws-elasticbeanstalk-ec2-role"
    service_role         = "arn:aws:iam::123456789012:role/aws-elasticbeanstalk-service-role"

    deployment_policy = "Rolling"
    health_reporting  = "enhanced"

    min_instances = 1
    max_instances = 4

    vpc_id           = "vpc-0a1b2c3d4e5f67890"
    instance_subnets = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f678901a"]

    env_vars = {
      WORKER_ENV     = "production"
      LOG_LEVEL      = "info"
      SQS_QUEUE_URL  = "https://sqs.us-east-1.amazonaws.com/123456789012/order-processing"
      WORKER_THREADS = "4"
    }

    tags = { environment-tier = "production" }
  }
]
