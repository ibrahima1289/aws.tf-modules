# AWS Elastic Beanstalk — Terraform Module

> Reusable Terraform module for deploying and managing [AWS Elastic Beanstalk](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/Welcome.html) applications and environments. Supports multiple applications and environments via `for_each`, with convenience variables for all common settings and an escape-hatch `custom_settings` list for any EBS namespace.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     AWS Elastic Beanstalk Module                        │
│                                                                         │
│  var.applications                                                       │
│       │                                                                 │
│       ▼                                                                 │
│  ┌──────────────────────────────────────┐                               │
│  │  aws_elastic_beanstalk_application   │  (logical container)          │
│  │  • name, description                 │                               │
│  │  • appversion_lifecycle (optional)   │                               │
│  └──────────────────┬───────────────────┘                               │
│                     │ application_key reference                         │
│  var.environments   │                                                   │
│       │             ▼                                                   │
│       ▼  ┌──────────────────────────────────────────────────────────┐   │
│          │       aws_elastic_beanstalk_environment                  │   │
│          │  tier = "WebServer" │ tier = "Worker"                    │   │
│          │  ┌──────────────┐   ┌───────────────┐  ┌─────────────┐   │   │
│          │  │  EC2 / ASG   │   │  ALB / NLB    │  │  Env Vars   │   │   │
│          │  └──────────────┘   └───────────────┘  └─────────────┘   │   │
│          │  ┌──────────────┐   ┌───────────────┐  ┌─────────────┐   │   │
│          │  │  VPC/Subnets │   │ Deploy Policy │  │  Custom     │   │   │
│          │  └──────────────┘   └───────────────┘  │  Settings   │   │   │
│          │                                        └─────────────┘   │   │
│          │  settings ◄── locals.environment_settings (built in      │   │
│          │               locals.tf from convenience variables       │   │
│          │               + custom_settings list)                    │   │
│          └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Data flow

1. `var.applications` → `local.applications_map` (keyed map) → `aws_elastic_beanstalk_application.app`
2. `var.environments` → `local.environments_map` (keyed map) → `aws_elastic_beanstalk_environment.env`
3. Convenience variables per environment → `local.environment_settings[env.key]` (list of namespace/name/value objects) → `dynamic "setting"` blocks

---

## Resources Created

| Resource | Description |
|----------|-------------|
| [`aws_elastic_beanstalk_application`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application) | Logical application container; one per `var.applications` entry |
| [`aws_elastic_beanstalk_environment`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment) | Live AWS resources (EC2, ALB, ASG); one per `var.environments` entry |

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.3` |
| AWS Provider | `>= 5.0` |

---

## Usage

```hcl
module "beanstalk" {
  source = "../../modules/compute/aws_elastic_beanstalk"

  region = "us-east-1"

  tags = {
    environment = "production"
    team        = "platform"
    managed_by  = "terraform"
  }

  applications = [
    {
      key         = "node-web"
      name        = "node-web-application"
      description = "Customer-facing Node.js 20 web app"
      appversion_lifecycle = {
        service_role = "arn:aws:iam::123456789012:role/aws-elasticbeanstalk-service-role"
        max_count    = 10
      }
    }
  ]

  environments = [
    {
      key             = "node-production"
      name            = "node-web-production"
      application_key = "node-web"
      solution_stack  = "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
      tier            = "WebServer"
      environment_type     = "LoadBalanced"
      instance_type        = "t3.small"
      iam_instance_profile = "aws-elasticbeanstalk-ec2-role"
      service_role         = "arn:aws:iam::123456789012:role/aws-elasticbeanstalk-service-role"
      min_instances        = 2
      max_instances        = 6
      load_balancer_type   = "application"
      deployment_policy    = "Rolling"
      health_check_path    = "/health"
      vpc_id               = "vpc-0a1b2c3d4e5f67890"
      instance_subnets     = ["subnet-aaa", "subnet-bbb"]
      elb_subnets          = ["subnet-ccc", "subnet-ddd"]
      env_vars = {
        NODE_ENV  = "production"
        LOG_LEVEL = "info"
      }
      # Add any EBS setting not covered by the convenience variables above
      custom_settings = [
        { namespace = "aws:autoscaling:trigger", name = "MeasureName",     value = "CPUUtilization" },
        { namespace = "aws:autoscaling:trigger", name = "UpperThreshold",  value = "70" },
      ]
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
| `applications` | `list(object)` | `[]` | ❌ | Application definitions (see below) |
| `environments` | `list(object)` | `[]` | ❌ | Environment definitions (see below) |

### `applications` object

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | `string` | ✅ | Stable unique key used as `for_each` index |
| `name` | `string` | ✅ | Application name in the AWS console |
| `description` | `string` | ❌ (`""`) | Human-readable description |
| `appversion_lifecycle` | `object` | ❌ | Auto-delete old versions; see sub-table below |
| `tags` | `map(string)` | ❌ (`{}`) | Per-application tags |

#### `appversion_lifecycle` sub-object

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `service_role` | `string` | ✅ | IAM role ARN EBS assumes to delete old versions |
| `max_count` | `number` | ❌ | Keep the N most recent versions (conflicts with `max_age_in_days`) |
| `max_age_in_days` | `number` | ❌ | Delete versions older than N days (conflicts with `max_count`) |
| `delete_source_from_s3` | `bool` | ❌ (`true`) | Remove version bundle from S3 when deleted |

### `environments` object

| Attribute | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `key` | `string` | — | ✅ | Stable unique key used as `for_each` index |
| `name` | `string` | — | ✅ | Environment name in the AWS console |
| `application_key` | `string` | — | ✅ | Must match a `key` in `var.applications` |
| `solution_stack` | `string` | — | ✅ | EBS solution stack (platform + OS + language) |
| `description` | `string` | `""` | ❌ | Human-readable description |
| `tier` | `string` | `"WebServer"` | ❌ | `"WebServer"` or `"Worker"` |
| `environment_type` | `string` | `"LoadBalanced"` | ❌ | `"LoadBalanced"` or `"SingleInstance"` |
| `instance_type` | `string` | `"t3.micro"` | ❌ | EC2 instance type for EBS managed instances |
| `iam_instance_profile` | `string` | `"aws-elasticbeanstalk-ec2-role"` | ❌ | EC2 instance profile (must already exist) |
| `ec2_key_name` | `string` | `null` | ❌ | EC2 key pair name for SSH access |
| `service_role` | `string` | `null` | ❌ | EBS service role ARN |
| `min_instances` | `number` | `1` | ❌ | ASG minimum instance count |
| `max_instances` | `number` | `4` | ❌ | ASG maximum instance count |
| `load_balancer_type` | `string` | `"application"` | ❌ | `"application"`, `"network"`, or `"classic"` |
| `deployment_policy` | `string` | `"Rolling"` | ❌ | `AllAtOnce`, `Rolling`, `RollingWithAdditionalBatch`, `Immutable`, `TrafficSplitting` |
| `health_check_path` | `string` | `"/"` | ❌ | ALB health check path |
| `health_reporting` | `string` | `"enhanced"` | ❌ | `"basic"` or `"enhanced"` |
| `vpc_id` | `string` | `null` | ❌ | VPC ID. Omit to use the default VPC |
| `instance_subnets` | `list(string)` | `[]` | ❌ | Private subnet IDs for EC2 instances |
| `elb_subnets` | `list(string)` | `[]` | ❌ | Public subnet IDs for the load balancer |
| `env_vars` | `map(string)` | `{}` | ❌ | Application environment variables |
| `custom_settings` | `list(object)` | `[]` | ❌ | Additional EBS namespace/name/value settings; see sub-table below |
| `tags` | `map(string)` | `{}` | ❌ | Per-environment tags |

#### `custom_settings` sub-object

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `namespace` | `string` | ✅ | EBS option namespace (e.g. `aws:autoscaling:trigger`) |
| `name` | `string` | ✅ | Option name within the namespace |
| `value` | `string` | ✅ | Option value |
| `resource` | `string` | ❌ (`""`) | Resource qualifier (only used for scheduled actions) |

#### Common `custom_settings` namespaces

| Namespace | Common options |
|-----------|----------------|
| `aws:autoscaling:trigger` | `MeasureName`, `UpperThreshold`, `LowerThreshold`, `ScaleUpIncrement` |
| `aws:autoscaling:scheduledaction` | `StartTime`, `EndTime`, `Recurrence`, `MinSize`, `MaxSize` |
| `aws:elasticbeanstalk:managedactions` | `ManagedActionsEnabled` |
| `aws:elasticbeanstalk:managedactions:platformupdate` | `UpdateLevel` (`minor`/`patch`) |
| `aws:elasticbeanstalk:sns:topics` | `Notification Endpoint`, `Notification Protocol` |
| `aws:ec2:vpc` | `AssociatePublicIpAddress` |
| `aws:elbv2:loadbalancer` | `AccessLogsS3Bucket`, `AccessLogsS3Enabled` |

---

## Outputs

| Output | Description |
|--------|-------------|
| `application_names` | `map(string)` — application key → application name |
| `environment_names` | `map(string)` — environment key → environment name |
| `environment_ids` | `map(string)` — environment key → environment ID |
| `environment_cnames` | `map(string)` — environment key → load balancer CNAME |
| `environment_endpoints` | `map(string)` — environment key → endpoint URL |
| `environment_tiers` | `map(string)` — environment key → tier (`WebServer`/`Worker`) |

---

## Notes

- **Solution stacks** change with each platform release. Use `aws elasticbeanstalk list-available-solution-stacks` (AWS CLI) or the [platform history page](https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platform-history.html) to find the latest stack name.
- **IAM prerequisites** — The `aws-elasticbeanstalk-ec2-role` instance profile and `aws-elasticbeanstalk-service-role` service role must exist before applying. They are created automatically when you first use EBS in the console, or you can provision them with the [IAM module](../../security_identity_compliance/aws_iam/README.md).
- **Worker tier** environments do not use a load balancer; `load_balancer_type` and `elb_subnets` are ignored for `tier = "Worker"`.
- **`SingleInstance` environments** do not create an ASG; `min_instances`/`max_instances` are ignored.
