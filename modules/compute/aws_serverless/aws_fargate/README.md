# AWS Fargate — Terraform Module

> Reusable Terraform module for deploying containerised applications on [AWS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html) via Amazon ECS. Manages ECS clusters (with Fargate and Fargate Spot capacity providers), task definitions, CloudWatch log groups, and services via `for_each`. Container definitions are supplied as a JSON string per task, keeping the module schema stable regardless of container count or shape.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                          AWS Fargate Module                                  │
│                                                                              │
│  var.clusters                                                                │
│       │                                                                      │
│       ▼                                                                      │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │  aws_ecs_cluster                    aws_ecs_cluster_capacity_providers │  │
│  │  • name, Container Insights         • FARGATE + FARGATE_SPOT           │  │
│  └─────────────────────────────┬──────────────────────────────────────────┘  │
│                                │ cluster reference                           │
│  var.task_definitions          │           var.services                      │
│       │                        │                │                            │
│       ▼                        │                ▼                            │
│  ┌─────────────────────────┐   │   ┌────────────────────────────────────┐    │
│  │ aws_cloudwatch_log_group│   │   │         aws_ecs_service            │    │
│  │ /ecs/{family}           │   │   │  ┌─────────────┐ ┌──────────────┐  │    │
│  └───────────┬─────────────┘   │   │  │ launch_type │ │ capacity_    │  │    │
│              │ awslogs driver  │   │  │ FARGATE     │ │ provider_    │  │    │
│              ▼                 │   │  └─────────────┘ │ strategy     │  │    │
│  ┌─────────────────────────┐   │   │  (FARGATE_SPOT)  └──────────────┘  │    │
│  │ aws_ecs_task_definition │   │   │  ┌──────────────────────────────┐  │    │
│  │ • FARGATE compatibility │───┘   │  │ network_configuration        │  │    │
│  │ • awsvpc network mode   │       │  │ (subnets, security groups)   │  │    │ 
│  │ • cpu + memory (task)   │       │  └──────────────────────────────┘  │    │
│  │ • container_definitions │       │  ┌──────────────┐ ┌────────────┐   │    │
│  │   (JSON string)         │       │  │ load_balancer│ │ circuit    │   │    │
│  │ • runtime_platform      │       │  │ (optional)   │ │ breaker    │   │    │
│  └─────────────────────────┘       │  └──────────────┘ └────────────┘   │    │
│                                    └────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Data flow

1. `var.clusters` → `aws_ecs_cluster` + `aws_ecs_cluster_capacity_providers`
2. `var.task_definitions` → `aws_cloudwatch_log_group` + `aws_ecs_task_definition`
3. `var.services` → `aws_ecs_service` (references cluster + task definition)

### Container definitions pattern

Container definitions are passed as a **JSON string** (`container_definitions` field). Build them in your wrapper's `locals.tf`:

```hcl
# Option A — jsonencode()
container_definitions = jsonencode([
  {
    name      = "api"
    image     = "nginx:1.27"
    essential = true
    portMappings = [{ containerPort = 80, hostPort = 80, protocol = "tcp" }]
    logConfiguration = {
      logDriver = "awslogs"
      options   = { "awslogs-group" = "/ecs/api", "awslogs-region" = "us-east-1", "awslogs-stream-prefix" = "api" }
    }
  }
])

# Option B — load from a dedicated JSON template file
container_definitions = file("${path.module}/templates/api-containers.json")
```

> The log group name in the container definition must match `/ecs/{family}` — the convention used by this module when creating `aws_cloudwatch_log_group` resources.

---

## Resources Created

| Resource | Description |
|----------|-------------|
| [`aws_ecs_cluster`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | ECS cluster; one per `var.clusters` entry |
| [`aws_ecs_cluster_capacity_providers`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | Registers FARGATE + FARGATE_SPOT on each cluster |
| [`aws_cloudwatch_log_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | Log group `/ecs/{family}`; one per task definition |
| [`aws_ecs_task_definition`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | Fargate task spec (cpu, memory, containers, roles); one per `var.task_definitions` entry |
| [`aws_ecs_service`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | Long-running service maintaining desired task count; one per `var.services` entry |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3` |
| AWS Provider | `>= 5.0` |

---

## Usage

```hcl
module "fargate" {
  source = "../../modules/compute/aws_serverless/aws_fargate"

  region = "us-east-1"
  tags   = { environment = "production", managed_by = "terraform" }

  clusters = [
    {
      key                = "web"
      name               = "web-cluster"
      container_insights = true
    }
  ]

  task_definitions = [
    {
      key                     = "api"
      family                  = "api-service"
      cpu                     = "512"
      memory                  = "1024"
      task_execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
      task_role_arn           = "arn:aws:iam::123456789012:role/api-task-role"
      # JSON string built in the caller's locals.tf
      container_definitions   = local.api_container_definitions
    }
  ]

  services = [
    {
      key                 = "api"
      name                = "api-service"
      cluster_key         = "web"
      task_definition_key = "api"
      desired_count       = 2
      subnet_ids          = ["subnet-aaa", "subnet-bbb"]
      security_group_ids  = ["sg-0abc1234"]
      load_balancer = {
        target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/api/abcdef"
        container_name   = "api"
        container_port   = 80
      }
    }
  ]
}
```

---

## Inputs

### Top-level

| Variable | Type | Default | Required | Description |
|----------|------|---------|----------|-------------|
| `region` | `string` | — | ✅ | AWS region to deploy into |
| `tags` | `map(string)` | `{}` | ❌ | Global tags merged into every resource |
| `clusters` | `list(object)` | `[]` | ❌ | ECS cluster definitions |
| `task_definitions` | `list(object)` | `[]` | ❌ | Task definition configurations |
| `services` | `list(object)` | `[]` | ❌ | ECS service configurations |

### `clusters` object

| Attribute | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key |
| `name` | `string` | — | ✅ | ECS cluster name |
| `container_insights` | `bool` | `true` | ❌ | Enable Container Insights metrics |
| `tags` | `map(string)` | `{}` | ❌ | Per-cluster tags |

### `task_definitions` object

| Attribute | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key |
| `family` | `string` | — | ✅ | Task family name |
| `cpu` | `string` | — | ✅ | Task CPU units: `"256"`, `"512"`, `"1024"`, `"2048"`, `"4096"` |
| `memory` | `string` | — | ✅ | Task memory in MiB: `"512"` – `"30720"` (must be compatible with cpu) |
| `task_execution_role_arn` | `string` | — | ✅ | IAM role for ECS to pull images and write logs |
| `container_definitions` | `string` | — | ✅ | JSON-encoded container spec array |
| `task_role_arn` | `string` | `null` | ❌ | IAM role the task containers can assume |
| `log_retention_days` | `number` | `30` | ❌ | CloudWatch log retention (0 = never expire) |
| `operating_system_family` | `string` | `"LINUX"` | ❌ | OS family for the task |
| `cpu_architecture` | `string` | `"X86_64"` | ❌ | CPU architecture: `"X86_64"` or `"ARM64"` |
| `volumes` | `list(object)` | `[]` | ❌ | Named volumes (bind or EFS) |
| `tags` | `map(string)` | `{}` | ❌ | Per-task-definition tags |

#### `volumes` sub-object

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | `string` | ✅ | Volume name referenced in container mount points |
| `efs_volume_configuration` | `object` | ❌ | EFS file system details; omit for ephemeral volumes |

### `services` object

| Attribute | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key |
| `name` | `string` | — | ✅ | ECS service name |
| `cluster_key` | `string` | — | ✅ | Must match a `key` in `var.clusters` |
| `task_definition_key` | `string` | — | ✅ | Must match a `key` in `var.task_definitions` |
| `subnet_ids` | `list(string)` | — | ✅ | Subnets for task ENIs |
| `security_group_ids` | `list(string)` | — | ✅ | Security groups for task ENIs |
| `desired_count` | `number` | `1` | ❌ | Target number of running tasks |
| `launch_type` | `string` | `"FARGATE"` | ❌ | Used when `capacity_provider_strategy` is empty |
| `capacity_provider_strategy` | `list(object)` | `[]` | ❌ | Mix FARGATE + FARGATE_SPOT |
| `assign_public_ip` | `bool` | `false` | ❌ | Assign public IP to task ENIs |
| `deployment_minimum_healthy_percent` | `number` | `100` | ❌ | Min % healthy tasks during deployment |
| `deployment_maximum_percent` | `number` | `200` | ❌ | Max % capacity during deployment |
| `health_check_grace_period_seconds` | `number` | `0` | ❌ | Grace period before LB health checks start |
| `enable_deployment_circuit_breaker` | `bool` | `true` | ❌ | Auto-roll back failed deployments |
| `load_balancer` | `object` | `null` | ❌ | ALB/NLB target group routing |
| `service_registries` | `object` | `null` | ❌ | Cloud Map service discovery |
| `enable_ecs_managed_tags` | `bool` | `true` | ❌ | Propagate ECS-managed tags to tasks |
| `propagate_tags` | `string` | `"SERVICE"` | ❌ | Tag source: `"SERVICE"`, `"TASK_DEFINITION"`, or `"NONE"` |
| `tags` | `map(string)` | `{}` | ❌ | Per-service tags |

---

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_arns` | `map(string)` — cluster key → cluster ARN |
| `cluster_names` | `map(string)` — cluster key → cluster name |
| `task_definition_arns` | `map(string)` — task key → task definition ARN (with revision) |
| `task_definition_revisions` | `map(number)` — task key → latest revision number |
| `service_arns` | `map(string)` — service key → service ARN |
| `service_names` | `map(string)` — service key → service name |
| `log_group_names` | `map(string)` — task key → CloudWatch log group name |
| `log_group_arns` | `map(string)` — task key → CloudWatch log group ARN |

---

## Notes

- **IAM prerequisites** — The `ecsTaskExecutionRole` (or equivalent) must exist before applying. It is created automatically when you first use ECS in the console, or provision it with the [IAM module](../../../security_identity_compliance/aws_iam/README.md).
- **Container definitions** — The JSON string must include `"logDriver": "awslogs"` with `"awslogs-group"` set to `/ecs/{family}` to match the log group this module creates.
- **FARGATE_SPOT** — Spot tasks can be interrupted with a two-minute warning. Use `deployment_minimum_healthy_percent = 50` and set `desired_count >= 2` so the service survives an interruption.
- **ARM64 / Graviton** — Set `cpu_architecture = "ARM64"` for up to 20% cost reduction on Graviton-compatible images. Ensure your container images are built for `linux/arm64`.
