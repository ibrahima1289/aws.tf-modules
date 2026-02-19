# AWS Batch Terraform Module

This module provisions AWS Batch resources including compute environments, job queues, and job definitions. It supports multiple compute types (EC2, SPOT, FARGATE), avoids null values with safe defaults, and tags all resources with a stable `CreatedDate`.

## Requirements
- Terraform >= 1.3
- AWS Provider >= 5.0

## Features
- Create multiple compute environments via a keyed map
- Support for MANAGED and UNMANAGED compute environment types
- EC2, SPOT, and FARGATE compute resources
- Multiple job queues with priority ordering
- Job definitions with retry strategies and timeouts
- Global and per-resource tags, including `CreatedDate`

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region for the provider |
| tags | map(string) | no | Global tags applied to all resources |
| compute_environments | map(object) | no | Map of compute environments; see schema below |
| job_queues | map(object) | no | Map of job queues; see schema below |
| job_definitions | map(object) | no | Map of job definitions; see schema below |

### `compute_environments` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| name | string | yes | - | Compute environment name |
| type | string | yes | - | `MANAGED` or `UNMANAGED` |
| service_role | string | no | `null` | IAM role ARN for Batch service |
| compute_resources | object | no | `null` | Compute resources config (required for MANAGED) |
| state | string | no | `ENABLED` | `ENABLED` or `DISABLED` |
| tags | map(string) | no | `{}` | Per-environment tags |

#### `compute_resources` nested object
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| type | string | yes | - | `EC2`, `SPOT`, or `FARGATE` |
| max_vcpus | number | yes | - | Maximum vCPUs |
| min_vcpus | number | no | `0` | Minimum vCPUs |
| desired_vcpus | number | no | `min_vcpus` | Desired vCPUs |
| instance_types | list(string) | yes | - | EC2 instance types |
| subnets | list(string) | yes | - | Subnet IDs |
| security_group_ids | list(string) | yes | - | Security group IDs |
| instance_role | string | no | `null` | IAM instance profile ARN |
| ec2_key_pair | string | no | `null` | EC2 key pair name |
| allocation_strategy | string | no | `null` | `BEST_FIT`, `BEST_FIT_PROGRESSIVE`, `SPOT_CAPACITY_OPTIMIZED` |
| bid_percentage | number | no | `null` | SPOT bid percentage (0-100) |
| spot_iam_fleet_role | string | no | `null` | IAM role for Spot fleet |
| launch_template | object | no | `null` | Launch template configuration |

### `job_queues` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| name | string | yes | - | Job queue name |
| state | string | yes | - | `ENABLED` or `DISABLED` |
| priority | number | yes | - | Queue priority (higher = higher priority) |
| compute_environment_keys | list(string) | yes | - | Keys from `compute_environments` map |
| tags | map(string) | no | `{}` | Per-queue tags |

### `job_definitions` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| name | string | yes | - | Job definition name |
| type | string | yes | - | `container` or `multinode` |
| platform_capabilities | list(string) | no | `null` | `["EC2"]` or `["FARGATE"]` |
| container_properties | string | no | `null` | JSON string for container config |
| retry_strategy | object | no | `null` | Retry configuration |
| timeout | object | no | `null` | Timeout configuration |
| tags | map(string) | no | `{}` | Per-definition tags |

## Outputs
- `compute_environment_arns`: Map of compute environment key -> ARN
- `compute_environment_names`: Map of compute environment key -> name
- `compute_environment_ecs_cluster_arns`: Map of compute environment key -> ECS cluster ARN
- `job_queue_arns`: Map of job queue key -> ARN
- `job_queue_names`: Map of job queue key -> name
- `job_definition_arns`: Map of job definition key -> ARN
- `job_definition_names`: Map of job definition key -> name
- `job_definition_revisions`: Map of job definition key -> revision number

## Usage
```hcl
module "batch" {
  source = "../../modules/compute/aws_containers/aws_batch"
  region = var.region
  tags   = { Environment = "dev" }

  compute_environments = {
    ec2_env = {
      name         = "my-compute-env"
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
      container_properties  = jsonencode({
        image  = "my-image:latest"
        vcpus  = 2
        memory = 2048
      })
    }
  }
}
```

## Notes
- **IAM Roles**: You must provide existing IAM roles:
  - `service_role`: Batch service role with `AWSBatchServiceRole` policy
  - `instance_role`: EC2 instance profile for container instances
  - Container job/execution roles in `container_properties`
- **Compute Types**:
  - **EC2**: Traditional EC2 instances, full control
  - **SPOT**: Cost-optimized with Spot instances
  - **FARGATE**: Serverless compute, no instance management
- **Container Properties**: Must be valid JSON matching AWS Batch container specification

## Examples
See [tf-plans/aws_batch](../../tf-plans/aws_batch/README.md) for a complete wrapper example with `terraform.tfvars`.
