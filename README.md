# Terraform Modules for AWS Services

This repository contains reusable Terraform modules for [AWS infrastructure components](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/amazon-web-services-cloud-platform.html). Each module is documented in its own directory. See the table below for details and usage examples.

## Modules

| AWS Service Type | Module Name     | Documentation Link                                                    |
|------------------|----------------|-----------------------------------------------------------------------|
| Networking       | VPC            | [VPC Module](modules/networking_content_delivery/aws_vpc/README.md)   |
| Security         | Security Group | [Security Group Module](modules/security_identity_compliance/aws_security_group/README.md) |
| Security         | IAM            | [IAM Module](modules/security_identity_compliance/aws_iam/README.md)  |
| Compute          | EC2            | [EC2 Module](modules/compute/aws_ec2/README.md)                           |
| Storage          | S3             | [S3 Module](modules/storage/aws_s3/README.md)                             |

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
## Release Notes
See [RELEASE.md](RELEASE.md) for the latest changes and version history.

## Contributing

We welcome contributions! To contribute to this repository:

1. **Fork the repository** on GitHub.
2. **Clone your fork** to your local machine:
   ```sh
   git clone https://github.com/your-username/aws.tf-modules.git
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

## Links
1. How to clone a repo --> see [here](https://github.com/ibrahima1289/kura-deployment-6-frontend?tab=readme-ov-file#3-find-and-upload-the-video-and-screenshot-files)
