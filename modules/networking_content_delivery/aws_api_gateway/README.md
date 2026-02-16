# AWS API Gateway (HTTP/WebSocket) Terraform Module

This module provisions one or more Amazon API Gateway v2 (HTTP/WebSocket) APIs with integrations, routes, and stages. It avoids null values by setting safe defaults and only rendering optional blocks when provided. All resources are tagged with a stable `CreatedDate` timestamp.

## Requirements
- Terraform >= 1.3
- AWS Provider >= 5.0

## Features
- Create multiple APIs (`protocol_type`: HTTP or WEBSOCKET)
- Per-API integrations (Lambda AWS_PROXY or HTTP backends)
- Per-API routes referencing integrations
- Optional per-API stage with access logs and route settings
- Global and per-API tags, including `CreatedDate`

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region for the provider |
| tags | map(string) | no | Global tags applied to all resources |
| apis | map(object) | yes | Map of APIs keyed by a unique key; see schema below |

### `apis` object schema
- `name` (string): API display name.
- `protocol_type` (string): `HTTP` or `WEBSOCKET`.
- `description` (string, optional): Description.
- `cors_configuration` (object, optional): Allow/Expose headers, methods, origins, `max_age`, `allow_credentials`.
- `integrations` (map(object), optional): Each integration has:
  - `integration_type` (string): `AWS_PROXY` (Lambda) or `HTTP`.
  - `integration_uri` (string): Lambda ARN or HTTP URL.
  - `payload_format_version` (string, optional): defaults to `2.0`.
  - `timeout_milliseconds` (number, optional): defaults to `30000`.
- `routes` (list(object), optional): Each route has:
  - `route_key` (string): e.g., `GET /items`.
  - `target_integration_key` (string): Key from `integrations` map.
  - `authorization_type` (string, optional): Defaults to `NONE`.
- `stage` (object, optional):
  - `name` (string, optional): Defaults to `$default`.
  - `auto_deploy` (bool, optional): Defaults to `true`.
  - `access_log_settings` (object, optional): `{ destination_arn, format }`.
  - `default_route_settings` (object, optional): `{ throttling_burst_limit, throttling_rate_limit, detailed_metrics_enabled }`.
- `tags` (map(string), optional): Per-API tags merged with global tags.

## Outputs
- `api_ids`: Map of API key -> API ID
- `api_endpoints`: Map of API key -> API endpoint URL
- `integration_ids`: Map of `apiKey::integrationKey` -> Integration ID
- `route_ids`: Map of `apiKey::routeKey` -> Route ID
- `stage_arns`: Map of API key -> Stage ARN (when stage provided)

## Usage
```hcl
module "api_gw" {
  source = "../../modules/networking_content_delivery/aws_api_gateway"
  region = var.region
  tags   = { Environment = "dev" }

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
}
```
