# AWS API Gateway Wrapper (Examples)

This plan demonstrates using the API Gateway v2 module to provision one or more HTTP/WebSocket APIs with integrations, routes, and stages.

## Files
- provider.tf: Providers (AWS + time)
- variables.tf: Plan inputs (region, tags, apis)
- main.tf: Wires inputs to the module
- outputs.tf: Exposes module outputs

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region |
| tags | map(string) | no | Global tags |
| apis | map(object) | yes | APIs to create (see module README for schema) |

## Example tfvars
```hcl
region = "us-east-1"

tags = { Environment = "dev" }

apis = {
  http_api = {
    name          = "my-http-api"
    protocol_type = "HTTP"

    integrations = {
      get_items = {
        integration_type       = "AWS_PROXY"
        integration_uri        = "arn:aws:lambda:us-east-1:123456789012:function:getItems"
        payload_format_version = "2.0"
      }
    }

    routes = [
      { route_key = "GET /items", target_integration_key = "get_items" }
    ]

    stage = {
      name        = "$default"
      auto_deploy = true
    }
  }
}
```
