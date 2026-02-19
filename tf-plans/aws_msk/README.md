# AWS MSK Wrapper Plan

This wrapper shows how to use the `modules/analytics/aws-msk` module to create one or more AWS MSK clusters.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name       | Type          | Required | Description |
|------------|---------------|----------|-------------|
| `region`   | `string`      | Yes      | AWS region to deploy MSK clusters in. |
| `tags`     | `map(string)` | No       | Global tags applied to all MSK resources (default: `{}`). |
| `clusters` | `any`         | Yes      | Map of MSK clusters to create; forwarded to the module. |

See `modules/analytics/aws-msk/README.md` for the full `clusters` schema.

## Outputs

| Name                | Description |
|---------------------|-------------|
| `cluster_arns`      | Map of cluster keys to MSK cluster ARNs. |
| `cluster_names`     | Map of cluster keys to MSK cluster names. |
| `bootstrap_brokers` | Map of cluster keys to MSK bootstrap broker strings. |

## Usage

1. Change into this directory:

```bash
cd tf-plans/aws_msk
```

2. (Optional) Edit `terraform.tfvars` to define your MSK clusters, region, and tags.

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

This wrapper simply calls the root MSK module, passing through `region`, `tags`, and `clusters`, and then re-exports the cluster ARNs, names, and bootstrap brokers for convenience.
