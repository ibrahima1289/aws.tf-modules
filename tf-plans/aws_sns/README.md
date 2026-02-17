# AWS SNS Wrapper Plan

This wrapper shows how to use the `modules/application_integration/aws_sns` module to create one or more SNS topics and optional subscriptions.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name     | Type         | Required | Description |
|----------|--------------|----------|-------------|
| `region` | `string`     | Yes      | AWS region to deploy SNS topics in. |
| `tags`   | `map(string)` | No      | Global tags applied to all SNS resources (default: `{}`). |
| `topics` | `any`        | Yes      | Map of SNS topics to create; forwarded to the module. |

See `modules/application_integration/aws_sns/README.md` for the full `topics` schema.

## Outputs

| Name                | Description |
|---------------------|-------------|
| `topic_arns`        | Map of topic keys to SNS topic ARNs. |
| `topic_names`       | Map of topic keys to SNS topic names. |
| `subscription_arns` | Map of subscription keys to SNS subscription ARNs. |

## Usage

1. Change into this directory:

```bash
cd tf-plans/aws_sns
```

2. (Optional) Edit `terraform.tfvars` to define your topics, subscriptions, region, and tags.

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

6. Destroy
```bash
terraform destroy
```

This wrapper simply calls the root SNS module, passing through `region`, `tags`, and `topics`, and then re-exports topic and subscription ARNs for convenience.
