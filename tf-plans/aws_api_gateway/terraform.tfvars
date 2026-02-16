# Example configuration for the AWS API Gateway wrapper plan
# - Sets region and optional global tags
# - Defines one HTTP API with a Lambda integration and route
# - Demonstrates how to add an additional API (commented out)

region = "us-east-1"

# Global tags applied to all resources created by the module
# You can add Environment, Owner, or other keys as needed

# Optional custom domain name for API Gateway (for future use)
# domain_name = "api.example.com"

tags = {
  Environment = "dev"
}

# Define one or more API Gateway v2 APIs
# Keys (http_api, another_http_api, etc.) are used to key outputs

apis = {
  http_api = {
    name          = "example-http-api"
    protocol_type = "HTTP"

    # Optional description and CORS configuration
    description = "Example HTTP API with Lambda integration"

    cors_configuration = {
      allow_headers     = ["Content-Type", "Authorization"]
      allow_methods     = ["GET", "POST", "OPTIONS"]
      allow_origins     = ["*"]
      expose_headers    = []
      max_age           = 3600
      allow_credentials = false
    }

    # Integrations mapped by key; these keys are referenced by routes
    integrations = {
      get_items = {
        integration_type = "AWS_PROXY"
        # Replace with your Lambda function ARN or HTTP URL
        integration_uri        = "arn:aws:lambda:us-east-1:123456789012:function:getItems"
        payload_format_version = "2.0"
        timeout_milliseconds   = 30000
      }
    }

    # Routes referencing integrations by key
    routes = [
      {
        route_key              = "GET /items"
        target_integration_key = "get_items"
        authorization_type     = "NONE"
      }
    ]

    # Optional stage configuration; if omitted, a $default stage with auto_deploy is used
    stage = {
      name        = "$default"
      auto_deploy = true

      # Example access log configuration (replace destination_arn with a real log group or Kinesis stream ARN)
      # access_log_settings = {
      #   destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/apigw/example"
      #   format          = "{\"requestId\":$context.requestId}"
      # }

      # default_route_settings = {
      #   throttling_burst_limit   = 1000
      #   throttling_rate_limit    = 500.0
      #   detailed_metrics_enabled = true
      # }
    }

    # Optional per-API tags merged with global tags
    tags = {
      Service = "example-api"
    }
  }

  # ---------------------------------------------------------------------------
  # Example of a second HTTP API (uncomment and customize as needed)
  # ---------------------------------------------------------------------------
  # another_http_api = {
  #   name          = "another-http-api"
  #   protocol_type = "HTTP"
  #
  #   integrations = {
  #     root = {
  #       integration_type       = "HTTP"
  #       integration_uri        = "https://example.com/root"
  #       payload_format_version = "1.0"
  #       # timeout_milliseconds   = 10000
  #     }
  #   }
  #
  #   routes = [
  #     {
  #       route_key              = "GET /"
  #       target_integration_key = "root"
  #       # authorization_type     = "NONE"
  #     }
  #   ]
  #
  #   # Optional stage and tags as shown above
  #   # stage = {
  #   #   name        = "$default"
  #   #   auto_deploy = true
  #   # }
  #   # tags = {
  #   #   Service = "another-http-api"
  #   # }
  # }

  # ---------------------------------------------------------------------------
  # Example of a WebSocket API (uncomment and customize as needed)
  # ---------------------------------------------------------------------------
  # websocket_api = {
  #   name          = "example-websocket-api"
  #   protocol_type = "WEBSOCKET"
  #
  #   # Optional description
  #   # description = "Example WebSocket API"
  #
  #   integrations = {
  #     connect_integration = {
  #       integration_type       = "AWS_PROXY"
  #       # Replace with your connect Lambda function ARN
  #       integration_uri        = "arn:aws:lambda:us-east-1:123456789012:function:onConnect"
  #       payload_format_version = "2.0"
  #     }
  #     message_integration = {
  #       integration_type       = "AWS_PROXY"
  #       # Replace with your message Lambda function ARN
  #       integration_uri        = "arn:aws:lambda:us-east-1:123456789012:function:onMessage"
  #       payload_format_version = "2.0"
  #     }
  #     disconnect_integration = {
  #       integration_type       = "AWS_PROXY"
  #       # Replace with your disconnect Lambda function ARN
  #       integration_uri        = "arn:aws:lambda:us-east-1:123456789012:function:onDisconnect"
  #       payload_format_version = "2.0"
  #     }
  #   }
  #
  #   routes = [
  #     {
  #       route_key              = "$connect"
  #       target_integration_key = "connect_integration"
  #       authorization_type     = "NONE"
  #     },
  #     {
  #       route_key              = "$default"
  #       target_integration_key = "message_integration"
  #       authorization_type     = "NONE"
  #     },
  #     {
  #       route_key              = "$disconnect"
  #       target_integration_key = "disconnect_integration"
  #       authorization_type     = "NONE"
  #     }
  #   ]
  #
  #   # WebSocket stage example
  #   # stage = {
  #   #   name        = "$default"
  #   #   auto_deploy = true
  #   # }
  #
  #   # tags = {
  #   #   Service = "example-websocket-api"
  #   # }
  # }
}
