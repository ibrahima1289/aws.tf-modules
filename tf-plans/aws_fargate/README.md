# AWS Fargate — Wrapper Plan

> Ready-to-apply Terraform wrapper that calls the [AWS Fargate module](../../modules/compute/aws_serverless/aws_fargate/README.md). Demonstrates one ECS cluster with two Fargate services: an ALB-integrated API (standard FARGATE) and a cost-optimised background worker (FARGATE + FARGATE_SPOT mix).

---

## Architecture

```
tf-plans/aws_fargate/
│
├── terraform.tfvars          ← clusters + services (region, tags, configs)
├── locals.tf                 ← created_date + task_definitions_config (file() refs)
├── main.tf                   ← calls module "fargate"
├── variables.tf              ← mirrors module variable types
├── outputs.tf                ← passes through all module outputs
├── provider.tf               ← AWS provider + Terraform version pins
└── templates/
    ├── api-containers.json   ← nginx API container definition
    └── worker-containers.json← Python worker container definition

         │  source
         ▼
modules/compute/aws_serverless/aws_fargate/
         │
         ├── aws_ecs_cluster              web-cluster (Container Insights on)
         │    └── aws_ecs_cluster_capacity_providers  FARGATE + FARGATE_SPOT
         │
         ├── aws_cloudwatch_log_group     /ecs/api-service
         │                               /ecs/order-worker
         │
         ├── aws_ecs_task_definition      api-service  (512 CPU / 1024 MB)
         │                               order-worker (256 CPU /  512 MB)
         │
         └── aws_ecs_service              api-service    → FARGATE, ALB, 2 tasks
                                         worker-service → FARGATE_SPOT mix, 3 tasks
```

---

## Files

| File | Purpose |
|------|---------|
| [provider.tf](provider.tf) | Terraform ≥ 1.3, AWS provider ≥ 5.0, `region` |
| [locals.tf](locals.tf) | `created_date`; `task_definitions_config` with `file()` container JSON |
| [main.tf](main.tf) | Calls `module "fargate"` |
| [variables.tf](variables.tf) | Input variable declarations |
| [outputs.tf](outputs.tf) | Pass-through outputs |
| [terraform.tfvars](terraform.tfvars) | Example values for clusters and services |
| [templates/api-containers.json](templates/api-containers.json) | nginx API container spec |
| [templates/worker-containers.json](templates/worker-containers.json) | Python worker container spec |

---

## Usage

```bash
cd tf-plans/aws_fargate

# 1. Edit terraform.tfvars
#    — Update region, subnet IDs, security group IDs, and ALB target group ARN.
#    — Update IAM role ARNs in locals.tf (task_execution_role_arn, task_role_arn).

# 2. Edit templates/*.json
#    — Update awslogs-region to match your region.
#    — awslogs-group must match /ecs/{family} (api-service, order-worker).
#    — Replace image tags with your own ECR image URIs for production use.

# 3. Initialise and apply
terraform init
terraform plan
terraform apply
```

> **IAM prerequisites** — The `ecsTaskExecutionRole` (managed policy `AmazonECSTaskExecutionRolePolicy`) must exist in your account. It is created automatically the first time you use ECS in the console, or use the [IAM module](../../modules/security_identity_compliance/aws_iam/README.md).

---

## Inputs

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `region` | `string` | ✅ | AWS region |
| `tags` | `map(string)` | ❌ | Global tags merged into every resource |
| `clusters` | `list(object)` | ❌ | ECS cluster definitions |
| `services` | `list(object)` | ❌ | Fargate service definitions |

> `task_definitions` is built in `locals.tf` (container JSON loaded from `templates/`) and passed directly to the module — it is not exposed as a `terraform.tfvars` variable.

---

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_arns` | Map of cluster key → cluster ARN |
| `cluster_names` | Map of cluster key → cluster name |
| `task_definition_arns` | Map of task key → task definition ARN (with revision) |
| `task_definition_revisions` | Map of task key → latest revision number |
| `service_arns` | Map of service key → service ARN |
| `service_names` | Map of service key → service name |
| `log_group_names` | Map of task key → CloudWatch log group name |
| `log_group_arns` | Map of task key → CloudWatch log group ARN |

---

## `terraform.tfvars` Patterns

| Pattern | Key settings |
|---------|-------------|
| **API service** (`api`) | `launch_type = "FARGATE"`, 2 tasks, ALB target group, 30 s health check grace period |
| **Worker service** (`worker`) | `capacity_provider_strategy` mix (1 FARGATE base + 3× FARGATE_SPOT weight), 3 tasks, no LB |

### Using Fargate Spot for all tasks

```hcl
services = [
  {
    key                 = "batch-job"
    # ...
    capacity_provider_strategy = [
      { capacity_provider = "FARGATE_SPOT", weight = 1, base = 0 }
    ]
    # Set minimum healthy % lower to tolerate interruptions
    deployment_minimum_healthy_percent = 0
  }
]
```

### ARM64 / Graviton containers (up to 20 % cheaper)

```hcl
# In locals.tf task_definitions_config:
{
  key              = "api-arm"
  family           = "api-service-arm"
  cpu              = "512"
  memory           = "1024"
  cpu_architecture = "ARM64"     # Graviton
  container_definitions = file("${path.module}/templates/api-containers.json")
  # ...
}
```

### Adding a second container (sidecar)

```json
// templates/api-containers.json — add after the first container object:
[
  { "name": "api", ... },
  {
    "name": "xray-daemon",
    "image": "public.ecr.aws/xray/aws-xray-daemon:latest",
    "essential": false,
    "portMappings": [{ "containerPort": 2000, "protocol": "udp" }],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": { "awslogs-group": "/ecs/api-service", "awslogs-region": "us-east-1", "awslogs-stream-prefix": "xray" }
    }
  }
]
```
