# AWS Elastic Beanstalk — Wrapper Plan

> Ready-to-apply Terraform wrapper that calls the [AWS Elastic Beanstalk module](../../modules/compute/aws_elastic_beanstalk/README.md). Demonstrates two applications (Node.js WebServer + Python Worker) with three environments across WebServer and Worker tiers.

---

## Architecture

```
tf-plans/aws_elastic_beanstalk/
│
├── terraform.tfvars          ← applications + environments (region, tags, configs)
├── main.tf                   ← calls module "beanstalk"
├── variables.tf              ← mirrors module variable types
├── outputs.tf                ← passes through all module outputs
├── locals.tf                 ← created_date tag
└── provider.tf               ← AWS provider + Terraform version pins

         │  source
         ▼
modules/compute/aws_elastic_beanstalk/
         │
         ├── aws_elastic_beanstalk_application  (node-web, python-worker)
         │         │
         │         └── aws_elastic_beanstalk_environment
         │                   ├── node-staging       (SingleInstance, t3.micro)
         │                   ├── node-production    (LoadBalanced, ALB, t3.small, VPC)
         │                   └── python-worker-prod (Worker tier, SQS daemon)
```

---

## Files

| File | Purpose |
|------|---------|
| [provider.tf](provider.tf) | Terraform ≥ 1.3, AWS provider ≥ 5.0, `region` |
| [locals.tf](locals.tf) | `created_date` tag computation |
| [main.tf](main.tf) | Calls `module "beanstalk"` |
| [variables.tf](variables.tf) | Input variable declarations |
| [outputs.tf](outputs.tf) | Pass-through outputs |
| [terraform.tfvars](terraform.tfvars) | Example values for all variables |

---

## Usage

```bash
cd tf-plans/aws_elastic_beanstalk

# 1. Edit terraform.tfvars — update region, VPC/subnet IDs, IAM role ARNs,
#    solution stack names, and env_vars for your account.

# 2. Initialise and apply
terraform init
terraform plan
terraform apply
```

> **Prerequisites** — The `aws-elasticbeanstalk-ec2-role` instance profile and `aws-elasticbeanstalk-service-role` service role must exist in your account. Run the EBS console wizard once to create them automatically, or provision them with the [IAM module](../../modules/security_identity_compliance/aws_iam/README.md).

---

## Inputs

| Variable | Type | Required | Description |
|----------|------|----------|-------------|
| `region` | `string` | ✅ | AWS region (e.g. `"us-east-1"`) |
| `tags` | `map(string)` | ❌ | Global tags merged into every resource |
| `applications` | `list(object)` | ❌ | Application definitions — see [module README](../../modules/compute/aws_elastic_beanstalk/README.md#applications-object) |
| `environments` | `list(object)` | ❌ | Environment definitions — see [module README](../../modules/compute/aws_elastic_beanstalk/README.md#environments-object) |

---

## Outputs

| Output | Description |
|--------|-------------|
| `application_names` | Map of application key → application name |
| `environment_names` | Map of environment key → environment name |
| `environment_ids` | Map of environment key → environment ID |
| `environment_cnames` | Map of environment key → load balancer CNAME |
| `environment_endpoints` | Map of environment key → endpoint URL |
| `environment_tiers` | Map of environment key → tier (`WebServer` / `Worker`) |

---

## `terraform.tfvars` Patterns

| Pattern | Key settings |
|---------|-------------|
| **Node.js staging** (env `node-staging`) | `environment_type = "SingleInstance"`, `t3.micro`, `AllAtOnce`, no VPC |
| **Node.js production** (env `node-production`) | `environment_type = "LoadBalanced"`, ALB, `t3.small`, `Rolling`, multi-AZ VPC, CPU scaling triggers via `custom_settings` |
| **Python Worker** (env `python-worker-prod`) | `tier = "Worker"`, SQS daemon, `t3.small`, private subnets only |

### Adding a new environment

```hcl
# In terraform.tfvars
environments = [
  # ... existing entries ...
  {
    key             = "node-canary"
    name            = "node-web-canary"
    application_key = "node-web"
    solution_stack  = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
    tier            = "WebServer"
    environment_type = "LoadBalanced"
    instance_type   = "t3.micro"
    deployment_policy = "TrafficSplitting"   # Canary 10 % → 100 %
    env_vars = { NODE_ENV = "canary" }
  }
]
```

### Adding a custom EBS setting

```hcl
custom_settings = [
  # Enable managed platform updates (minor versions + patches)
  { namespace = "aws:elasticbeanstalk:managedactions",                name = "ManagedActionsEnabled", value = "true" },
  { namespace = "aws:elasticbeanstalk:managedactions:platformupdate", name = "UpdateLevel",            value = "minor" },
]
```
