# Example configuration for the AWS Batch wrapper plan
# - Sets region and optional global tags
# - Defines compute environments, job queues, and job definitions
# - Demonstrates EC2, SPOT, and FARGATE compute types

region = "us-east-1"

# Global tags applied to all resources created by the module
tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}

# Define one or more Batch compute environments
# Keys (ec2_env, spot_env, etc.) are used to reference from job queues

compute_environments = {
  ec2_env = {
    name         = "example-ec2-compute-env"
    type         = "MANAGED"
    service_role = "arn:aws:iam::123456789012:role/AWSBatchServiceRole"

    compute_resources = {
      type               = "EC2"
      max_vcpus          = 16
      min_vcpus          = 0
      desired_vcpus      = 4
      instance_types     = ["m5.large", "m5.xlarge"]
      subnets            = ["subnet-12345678", "subnet-87654321"]
      security_group_ids = ["sg-12345678"]
      instance_role      = "arn:aws:iam::123456789012:instance-profile/ecsInstanceRole"

      allocation_strategy = "BEST_FIT_PROGRESSIVE"
    }

    state = "ENABLED"

    tags = {
      ComputeType = "EC2"
    }
  }

  # ---------------------------------------------------------------------------
  # Example of a SPOT compute environment (uncomment and customize as needed)
  # ---------------------------------------------------------------------------
  # spot_env = {
  #   name         = "example-spot-compute-env"
  #   type         = "MANAGED"
  #   service_role = "arn:aws:iam::123456789012:role/AWSBatchServiceRole"
  #
  #   compute_resources = {
  #     type               = "SPOT"
  #     max_vcpus          = 32
  #     min_vcpus          = 0
  #     desired_vcpus      = 8
  #     instance_types     = ["c5.large", "c5.xlarge", "optimal"]
  #     subnets            = ["subnet-12345678", "subnet-87654321"]
  #     security_group_ids = ["sg-12345678"]
  #     instance_role      = "arn:aws:iam::123456789012:instance-profile/ecsInstanceRole"
  #     
  #     allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
  #     bid_percentage      = 80
  #     spot_iam_fleet_role = "arn:aws:iam::123456789012:role/aws-ec2-spot-fleet-tagging-role"
  #   }
  #
  #   state = "ENABLED"
  #
  #   tags = {
  #     ComputeType = "SPOT"
  #   }
  # }

  # ---------------------------------------------------------------------------
  # Example of a FARGATE compute environment (uncomment as needed)
  # ---------------------------------------------------------------------------
  # fargate_env = {
  #   name         = "example-fargate-compute-env"
  #   type         = "MANAGED"
  #   service_role = "arn:aws:iam::123456789012:role/AWSBatchServiceRole"
  #
  #   compute_resources = {
  #     type               = "FARGATE"
  #     max_vcpus          = 8
  #     subnets            = ["subnet-12345678", "subnet-87654321"]
  #     security_group_ids = ["sg-12345678"]
  #   }
  #
  #   state = "ENABLED"
  #
  #   tags = {
  #     ComputeType = "FARGATE"
  #   }
  # }
}

# Define one or more Batch job queues
# Job queues connect jobs to compute environments

job_queues = {
  default_queue = {
    name     = "example-job-queue"
    state    = "ENABLED"
    priority = 1

    # Reference compute environments by key from above
    compute_environment_keys = ["ec2_env"]

    tags = {
      Queue = "Default"
    }
  }

  # ---------------------------------------------------------------------------
  # Example of a multi-environment queue (uncomment as needed)
  # ---------------------------------------------------------------------------
  # multi_env_queue = {
  #   name     = "multi-env-job-queue"
  #   state    = "ENABLED"
  #   priority = 10
  #
  #   # Can reference multiple compute environments in priority order
  #   compute_environment_keys = ["spot_env", "ec2_env"]
  #
  #   tags = {
  #     Queue = "MultiEnv"
  #   }
  # }
}

# Define one or more Batch job definitions
# Job definitions specify how jobs should run

job_definitions = {
  simple_job = {
    name = "example-job-definition"
    type = "container"

    platform_capabilities = ["EC2"]

    # Container properties as JSON string
    # Replace with your actual container configuration
    container_properties = <<-JSON
      {
        "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest",
        "vcpus": 2,
        "memory": 2048,
        "command": ["echo", "Hello from Batch"],
        "jobRoleArn": "arn:aws:iam::123456789012:role/BatchJobRole",
        "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
      }
    JSON

    # Optional retry strategy
    retry_strategy = {
      attempts = 3
    }

    # Optional timeout
    timeout = {
      attempt_duration_seconds = 3600
    }

    tags = {
      JobType = "SimpleContainer"
    }
  }

  # ---------------------------------------------------------------------------
  # Example of a FARGATE job definition (uncomment as needed)
  # ---------------------------------------------------------------------------
  # fargate_job = {
  #   name = "example-fargate-job-definition"
  #   type = "container"
  #
  #   platform_capabilities = ["FARGATE"]
  #
  #   container_properties = <<-JSON
  #     {
  #       "image": "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest",
  #       "resourceRequirements": [
  #         {"type": "VCPU", "value": "0.25"},
  #         {"type": "MEMORY", "value": "512"}
  #       ],
  #       "jobRoleArn": "arn:aws:iam::123456789012:role/BatchJobRole",
  #       "executionRoleArn": "arn:aws:iam::123456789012:role/ecsTaskExecutionRole",
  #       "fargatePlatformConfiguration": {
  #         "platformVersion": "LATEST"
  #       }
  #     }
  #   JSON
  #
  #   retry_strategy = {
  #     attempts = 2
  #   }
  #
  #   tags = {
  #     JobType = "Fargate"
  #   }
  # }
}
