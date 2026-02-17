# AWS SQS Wrapper Plan

This directory contains a Terraform wrapper for the root SQS module at `modules/application_integration/aws_sqs`.
Use it to define one or more queues via `terraform.tfvars` and run `terraform plan/apply` in a single place.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name    | Type         | Required | Description |
|---------|--------------|----------|-------------|
| `region` | `string`    | Yes      | AWS region to deploy SQS queues in. |
| `tags`   | `map(string)` | No     | Global tags applied to all SQS queues (default: `{}`). |
| `queues` | `any`       | Yes      | Map of queue definitions; forwarded to the root module. |

See `modules/application_integration/aws_sqs/README.md` for the full `queues` schema.

## Outputs

| Name        | Description |
|-------------|-------------|
| `queue_ids` | Map of logical queue keys to SQS queue IDs (URLs). |
| `queue_arns` | Map of logical queue keys to SQS queue ARNs. |

## Usage

1. Change into this directory:

```bash
cd tf-plans/aws_sqs
```

2. (Optional) Edit `terraform.tfvars` to define your queues, region, and tags.

3. Initialize the working directory:

```bash
terraform init
```

4. Review the plan:

```bash
terraform plan
```

5. Apply the changes when ready:

```bash
terraform apply
```

This wrapper simply calls the root SQS module, passing through `region`, `tags`, and `queues`, and then re-exports the queue IDs and ARNs for convenience.

