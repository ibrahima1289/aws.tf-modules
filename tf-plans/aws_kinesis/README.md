# AWS Kinesis Wrapper Plan

This wrapper shows how to use the `modules/analytics/aws_kinesis` module to create one or more Kinesis Data Streams and optional Kinesis Data Firehose delivery streams.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name        | Type          | Required | Description |
|-------------|---------------|----------|-------------|
| `region`    | `string`      | Yes      | AWS region to deploy Kinesis resources in. |
| `tags`      | `map(string)` | No       | Global tags applied to all Kinesis resources (default: `{}`). |
| `streams`   | `any`         | Yes      | Map of Kinesis Data Streams to create; forwarded to the module. |
| `firehoses` | `any`         | No       | Map of Kinesis Data Firehose delivery streams to create; forwarded to the module. |

See `modules/analytics/aws_kinesis/README.md` for the full `streams` schema.

## Outputs

| Name             | Description |
|------------------|-------------|
| `stream_arns`    | Map of stream keys to Kinesis stream ARNs. |
| `stream_names`   | Map of stream keys to Kinesis stream names. |
| `stream_ids`     | Map of stream keys to Kinesis stream IDs. |
| `firehose_arns`  | Map of firehose keys to Firehose delivery stream ARNs. |
| `firehose_names` | Map of firehose keys to Firehose delivery stream names. |

## Usage

1. Change into this directory:

```bash
cd tf-plans/aws_kinesis
```

2. (Optional) Edit `terraform.tfvars` to define your streams, firehoses, region, and tags.

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

This wrapper simply calls the root Kinesis module, passing through `region`, `tags`, `streams`, and `firehoses`, and then re-exports the stream and Firehose ARNs and names for convenience.
