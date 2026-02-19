# AWS Batch Wrapper (Examples)

This plan demonstrates using the AWS Batch module to provision compute environments, job queues, and job definitions for running containerized batch workloads.

## Files
- provider.tf: Providers (AWS)
- variables.tf: Plan inputs (region, tags, compute_environments, job_queues, job_definitions)
- main.tf: Wires inputs to the module
- outputs.tf: Exposes module outputs
- terraform.tfvars: Example configuration

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region |
| tags | map(string) | no | Global tags |
| compute_environments | map(object) | no | Compute environments to create (see module README) |
| job_queues | map(object) | no | Job queues to create (see module README) |
| job_definitions | map(object) | no | Job definitions to create (see module README) |

### Quick Reference

**Compute Environment Types:**
- `MANAGED`: AWS manages compute resources (EC2, SPOT, FARGATE)
- `UNMANAGED`: You manage compute resources

**Compute Resource Types:**
- `EC2`: On-demand EC2 instances
- `SPOT`: Spot instances (up to 90% cost savings)
- `FARGATE`: Serverless containers

**Job Queue Priority:**
- Higher numbers = higher priority
- Jobs are dispatched to queues based on priority

## Example tfvars
```hcl
region = "us-east-1"

tags = { Environment = "dev" }

compute_environments = {
  ec2_env = {
    name         = "my-ec2-env"
    type         = "MANAGED"
    service_role = "arn:aws:iam::123456789012:role/AWSBatchServiceRole"

    compute_resources = {
      type               = "EC2"
      max_vcpus          = 16
      instance_types     = ["m5.large"]
      subnets            = ["subnet-12345678"]
      security_group_ids = ["sg-12345678"]
      instance_role      = "arn:aws:iam::123456789012:instance-profile/ecsInstanceRole"
    }
  }
}

job_queues = {
  default = {
    name                     = "my-job-queue"
    state                    = "ENABLED"
    priority                 = 1
    compute_environment_keys = ["ec2_env"]
  }
}

job_definitions = {
  my_job = {
    name                  = "my-job-definition"
    type                  = "container"
    platform_capabilities = ["EC2"]
    container_properties  = <<-JSON
      {
        "image": "my-image:latest",
        "vcpus": 2,
        "memory": 2048
      }
    JSON
  }
}
```

## Usage
1. Customize `terraform.tfvars` with your IAM roles, VPC subnets, and container images
2. Initialize and apply:
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

## Common Patterns

### EC2 Compute Environment
Best for: Long-running jobs, consistent workloads
```hcl
compute_resources = {
  type               = "EC2"
  max_vcpus          = 16
  allocation_strategy = "BEST_FIT_PROGRESSIVE"
}
```

### SPOT Compute Environment
Best for: Fault-tolerant jobs, cost optimization
```hcl
compute_resources = {
  type                = "SPOT"
  max_vcpus           = 32
  allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
  bid_percentage      = 80
  spot_iam_fleet_role = "arn:aws:iam::123456789012:role/aws-ec2-spot-fleet-tagging-role"
}
```

### FARGATE Compute Environment
Best for: Serverless, no instance management
```hcl
compute_resources = {
  type               = "FARGATE"
  max_vcpus          = 8
  subnets            = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
}
```

## Required IAM Roles
- **Batch Service Role**: `AWSBatchServiceRole` managed policy
- **EC2 Instance Profile**: `AmazonEC2ContainerServiceforEC2Role` for EC2/SPOT
- **Spot Fleet Role**: Required for SPOT compute (optional)
- **Job Role**: Permissions for your job containers
- **Execution Role**: For FARGATE, pulling images from ECR
