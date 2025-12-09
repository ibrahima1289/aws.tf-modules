# AWS Lambda Wrapper (tf-plans)

This wrapper consumes the Lambda module and exposes simple variables to deploy a function.

## Quick start

```bash
terraform init -upgrade
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Adjust variables in `terraform.tfvars` to your needs.

To deploy a Zip package from S3, set:

```
s3_bucket = "my-bucket"
s3_key    = "lambda/builds/my-func.zip"
# optional
s3_object_version = "abc123"
```

Or to deploy a container image, set:

```
image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-image:latest"
```
