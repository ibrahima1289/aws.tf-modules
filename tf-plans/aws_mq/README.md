# AWS MQ Wrapper Plan

This wrapper shows how to use the `modules/application_integration/aws_mq` module to create one or more Amazon MQ brokers.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name      | Type          | Required | Description |
|-----------|---------------|----------|-------------|
| `region`  | `string`      | Yes      | AWS region to deploy Amazon MQ brokers in. |
| `tags`    | `map(string)` | No       | Global tags applied to all Amazon MQ resources (default: `{}`). |
| `brokers` | `any`         | Yes      | Map of Amazon MQ brokers to create; forwarded to the module. |

See `modules/application_integration/aws_mq/README.md` for the full `brokers` schema.

## Outputs

| Name           | Description |
|----------------|-------------|
| `broker_arns`  | Map of broker keys to Amazon MQ broker ARNs. |
| `broker_ids`   | Map of broker keys to Amazon MQ broker IDs. |
| `broker_names` | Map of broker keys to Amazon MQ broker names. |

## Usage

1. Change into this directory:

```bash
cd tf-plans/aws_mq
```

2. (Optional) Edit `terraform.tfvars` to define your brokers, region, and tags.

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

This wrapper simply calls the root Amazon MQ module, passing through `region`, `tags`, and `brokers`, and then re-exports the broker ARNs, IDs, and names for convenience.
