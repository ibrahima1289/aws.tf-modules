# Terraform Modules for AWS Services

[![Terraform Modules CI](https://github.com/ibrahima1289/aws.tf-modules/actions/workflows/terraform-modules-ci.yml/badge.svg?branch=main)](https://github.com/ibrahima1289/aws.tf-modules/actions/workflows/terraform-modules-ci.yml) [![Contributors](https://img.shields.io/github/contributors/ibrahima1289/aws.tf-modules.svg?color=orange)](https://github.com/ibrahima1289/aws.tf-modules/graphs/contributors) 

> This repository contains reusable Terraform modules for [AWS infrastructure components](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/amazon-web-services-cloud-platform.html) and markdown for services information summary and potential usage. <br>
> Each module is documented in its own directory. See the table below for details and usage examples.

## Repository Structure

```
aws.tf-modules/
├─ modules/
│  ├─ compute/                      # ALB, NLB, GWLB, ASG, EC2, Lambda
│  ├─ networking_content_delivery/  # VPC, Route 53, Route Table, Internet Gateway
│  ├─ security_identity_compliance/ # IAM, KMS, Security Group
│  └─ storage/                      # S3
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

| AWS Service Type | Module Name     | Documentation Link                                                    | Resource Guide                                  |
|------------------|-----------------|-----------------------------------------------------------------------|-------------------------------------------------|
| Compute          | ALB             | [ALB Module](modules/compute/aws_elb/aws_alb/README.md)               | [ELB Overview](modules/compute/aws_elb/aws-elb.md) |
| Compute          | NLB             | [NLB Module](modules/compute/aws_elb/aws_nlb/README.md)               | [ELB Overview](modules/compute/aws_elb/aws-elb.md) |
| Compute          | GWLB            | [GWLB Module](modules/compute/aws_elb/aws_glb/README.md)              | [ELB Overview](modules/compute/aws_elb/aws-elb.md) |
| Compute          | ASG             | [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) | [ASG Overview](modules/compute/aws_EC2s/aws_auto_scaling_grp/aws-auto-scaling-grp.md) |
| Compute          | EC2             | [EC2 Module](modules/compute/aws_EC2s/aws_ec2/README.md)               | [EC2 Overview](modules/compute/aws_EC2s/aws_ec2/aws-ec2.md)                           |
| Compute          | Lambda          | [Lambda Module](modules/compute/aws_serverless/aws_lambda/README.md)   | [Lambda Overview](modules/compute/aws_serverless/aws_lambda/aws-lambda.md)           |
| Networking       | VPC             | [VPC Module](modules/networking_content_delivery/aws_vpc/README.md)    | [VPC Overview](modules/networking_content_delivery/aws_vpc/aws-vpc.md)               |
| Networking/CDN   | Route 53        | [Route 53 Module](modules/networking_content_delivery/aws_route_53/README.md) | [Route 53 Overview](modules/networking_content_delivery/aws_route_53/aws-route-53.md) |
| Networking/CDN   | API Gateway     | [API Gateway Module](modules/networking_content_delivery/aws_api_gateway/README.md) | [API Gateway Overview](modules/networking_content_delivery/aws_api_gateway/aws-api-gateway.md) |
| Security         | IAM             | [IAM Module](modules/security_identity_compliance/aws_iam/README.md)   | [IAM Overview](modules/security_identity_compliance/aws_iam/aws-iam.md)              |
| Security         | KMS             | [KMS Module](modules/security_identity_compliance/aws_kms/README.md)   | [KMS Overview](modules/security_identity_compliance/aws_kms/aws-kms.md)              |
| Security         | Security Group  | [Security Group Module](modules/security_identity_compliance/aws_security_group/README.md) | [Security Groups Overview](modules/security_identity_compliance/aws_security_group/aws-security-groups.md) |
| Storage          | S3              | [S3 Module](modules/storage/aws_s3/README.md)                          | [S3 Overview](modules/storage/aws_s3/aws-s3.md)                                       |

> Each module directory contains its own README file with usage instructions, input/output variables, and examples.

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
Wrapper plans are available under tf-plans/ to demonstrate usage with sensible defaults and example terraform.tfvars files.

| Wrapper | Module | Description |
|---------|--------|-------------|
| [tf-plans/aws_alb](tf-plans/aws_alb/README.md) | ALB | Application Load Balancer; multi-ALB via `albs` |
| [tf-plans/aws_nlb](tf-plans/aws_nlb/README.md) | NLB | Network Load Balancer; multi-NLB via `nlbs`; cross-zone option |
| [tf-plans/aws_glb](tf-plans/aws_glb/README.md) | GWLB | Gateway Load Balancer; multi-GLB via `glbs` |
| [tf-plans/aws_asg](tf-plans/aws_asg/README.md) | ASG | Auto Scaling Groups; multi-ASG via `asgs`; hooks & policies |
| [tf-plans/aws_ec2](tf-plans/aws_ec2/README.md) | EC2 | Instances; AMIs, EBS, networking examples |
| [tf-plans/aws_lambda](tf-plans/aws_lambda/README.md) | Lambda | Functions; Zip/Image; VPC/IAM integrations |
| [tf-plans/aws_route_53](tf-plans/aws_route_53/README.md) | Route 53 | Zones & records; alias examples |
| [tf-plans/aws_iam](tf-plans/aws_iam/README.md) | IAM | Users, groups, policies; access keys & console options |
| [tf-plans/aws_kms](tf-plans/aws_kms/README.md) | KMS | Keys, aliases, grants; rotation options |
| [tf-plans/aws_s3](tf-plans/aws_s3/README.md) | S3 | Buckets; SSE-KMS/SSE-S3 options; logging examples |
| [tf-plans/aws_internet_gateway](tf-plans/aws_internet_gateway/README.md) | Internet Gateway | IGW attach examples; route integration |
| [tf-plans/aws_route_table](tf-plans/aws_route_table/README.md) | Route Table | Routes, associations; VPC/Subnet wiring |
| [tf-plans/aws_api_gateway](tf-plans/aws_api_gateway/README.md) | API Gateway | HTTP/WebSocket APIs; integrations, routes, stages |

All modules consistently tag resources with a `CreatedDate` sourced from a one-time timestamp via the `time_static` provider.
Modules that support multi-resource creation (e.g., ALB via `albs`, NLB via `nlbs`, GWLB via `glbs`, ASG via `asgs`) expose outputs as maps keyed by the resource key.

## CI & Workflows

- **Auto open PR**: [auto-open-pr.yml](.github/workflows/auto-open-pr.yml) creates a PR to `main` first when code is pushed to any non-`main` branch (skips if a PR already exists).
- **Terraform checks**: [terraform-modules-ci.yml](.github/workflows/terraform-modules-ci.yml) then runs the hygiene script (file types + `terraform fmt -check -recursive`) on push/PR to `main`.
- **PR Merged** by humans only!

## Release Notes
See [RELEASE.md](RELEASE.md) for the latest changes and version history.

## Contributing

We welcome contributions! To contribute to this repository:

1. **Fork the repository** on GitHub.
2. **Clone your forked version** to your local machine (or, use the browser):
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
