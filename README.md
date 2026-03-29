# Terraform Modules for AWS Services

[![Contributors](https://img.shields.io/github/contributors/ibrahima1289/aws.tf-modules.svg)](https://github.com/ibrahima1289/aws.tf-modules/graphs/contributors) [![Terraform Modules CI](https://github.com/ibrahima1289/aws.tf-modules/actions/workflows/terraform-modules-ci.yml/badge.svg?branch=main)](https://github.com/ibrahima1289/aws.tf-modules/actions/workflows/terraform-modules-ci.yml)

> This repository contains reusable Terraform modules for [AWS infrastructure components](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/amazon-web-services-cloud-platform.html) and markdown for services information summary and potential usage. <br>
> Each module is documented in its own directory. See [Module-Service-List.md](Module-Service-List.md) for the full list of modules, resource guides, and wrapper plans.

## Repository Structure

```
aws.tf-modules/
├─ modules/
│  ├─ analytics/                    # Kinesis, MSK, Glue, Redshift, Athena, QuickSight, OpenSearch, EMR
│  ├─ application_integration/      # MQ, SNS, SQS, Step Functions, EventBridge
│  ├─ cloud_financial_management/   # Budgets, Savings Plans
│  ├─ compute/                      # ALB, NLB, GWLB, ASG, EC2, Lambda, Batch, Elastic Beanstalk, Fargate
│  ├─ databases/                    # Aurora, RDS, DynamoDB, DocumentDB, ElastiCache
│  ├─ management_and_governance/    # Organizations, CloudFormation, Config, Systems Manager, Migration (MGN, 6 R's)
│  ├─ monitoring/                   # CloudWatch (log groups, alarms, dashboards, filters), CloudTrail (trails, event selectors, insights)
│  ├─ networking_content_delivery/  # VPC, Route 53, Route Table, Internet Gateway, CloudFront, API Gateway
│  ├─ security_identity_compliance/ # IAM, KMS, Security Group, NACL, Certificate Manager, Secrets Manager, Shield, Network Firewall, Firewall Manager, GuardDuty, WAF
│  └─ storage/                      # S3, Backup, Snow Family, DataSync, Storage Gateway, Transfer Family, Lake Formation
├─ tf-plans/                        # Wrapper examples for each module
│  ├─ aws_*/ 
│  └─ ...
├─ tests/                           # Repo hygiene + fmt checks
│  ├─ terraform_module_check.py
│  └─ README.md
├─ .github/workflows/               # CI workflow
│  └─ terraform-modules-ci.yml
├─ README.md
├─ RELEASE.md
└─ LICENSE
```

## Modules

See the full module list, resource guides, and Terraform links in **[Module-Service-List.md](Module-Service-List.md)**.

## Getting Started

To use a module, reference its path in your Terraform configuration. For example:

```hcl
module "vpc" {
  source = "../modules/networking_content_delivery/aws_vpc"
  # ...module variables...
}
```
> You can verify the estimated cost of the resources you want to create in order to have an idea how much it will cost you to provision the AWS services - see the [AWS Cost Calculator](https://calculator.aws/#/).

## Wrappers (Examples)

Wrapper plans are available under `tf-plans/`. See the full wrapper list in **[Module-Service-List.md](Module-Service-List.md#wrappers-examples)**.

> All modules consistently tag resources with a `CreatedDate` sourced from a one-time timestamp via the `time_static` provider.  
> Modules that support multi-resource creation (e.g., ALB via `albs`, NLB via `nlbs`, GWLB via `glbs`, ASG via `asgs`, CloudWatch resources via `log_groups`, `metric_alarms`, `dashboards`, etc.) expose outputs as maps keyed by the resource key.  
> CloudWatch dashboard bodies can be stored as external `.json` files under the wrapper's `dashboards/` folder and loaded via `file()` in `locals.tf`, keeping `terraform.tfvars` free of inline JSON.

## CI & Workflows

- **Auto open PR**: [auto-open-pr.yml](.github/workflows/auto-open-pr.yml) creates a PR to `main` first when code is pushed to any non-`main` branch (skips if a PR already exists).
- **Terraform checks**: [terraform-modules-ci.yml](.github/workflows/terraform-modules-ci.yml) then runs the hygiene script (file types + `terraform fmt -check -recursive`) on push/PR to `main`.
- **PR Merged** by humans only!

## Release Notes
See [RELEASE.md](RELEASE.md) for the latest changes and version history.

## Contributing

We welcome contributions! To contribute to this repository:

1. **Fork the repository** on GitHub.
2. **Clone your forked version** to your local machine:
   ```sh
   git clone https://github.com/ibrahima1289/aws.tf-modules.git
   cd aws.tf-modules
   ```
3. **Create a new branch** for your feature or bugfix:
   ```sh
   git checkout -b my-feature-branch
   ```
4. **Make your changes** and commit them:
   ```sh
   git add .
   git commit -m "Describe your changes"
   ```
5. **Push your branch** to your fork:
   ```sh
   git push origin my-feature-branch
   ```
6. **Open a Pull Request (PR)** from your branch to the `main` branch of this repository on GitHub.
7. The maintainers will review your PR and provide feedback or merge it.

> Please ensure your code follows the style and structure of the existing modules. Add or update documentation and tests as appropriate.

## Sources and References
This repository’s development leveraged the following tools and documentation:

- GitHub Copilot: AI coding assistance and suggestions — [docs.github.com/copilot](https://docs.github.com/en/copilot)
- Google Gemini: research and design guidance — [ai.google.dev](https://ai.google.dev)
- OpenAI ChatGPT: explanations and Terraform best practices — [platform.openai.com/docs](https://platform.openai.com/docs)
- AWS Documentation: authoritative service references — [docs.aws.amazon.com](https://docs.aws.amazon.com/)
- Terraform AWS Provider: resource specs and examples — [registry.terraform.io/providers/hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
