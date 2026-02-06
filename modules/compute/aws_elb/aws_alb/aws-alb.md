# Application Load Balancer (ALB)

An Application Load Balancer (ALB) is a type of Elastic Load Balancer that operates at the application layer (Layer 7) of the OSI model. It is designed for load balancing of HTTP and HTTPS traffic and provides advanced routing capabilities that make it ideal for modern application architectures, including microservices and containers.

## Core Concepts

*   **Layer 7 Routing:** ALBs are "application-aware" and can inspect the content of a request to make intelligent routing decisions.
*   **Targets:** An ALB can route traffic to various types of targets, including EC2 instances, IP addresses, Lambda functions, and other ALBs.
*   **High Availability:** The ALB is itself highly available, with nodes automatically provisioned by AWS in multiple Availability Zones within a region.

## Key Components and Configuration

### 1. Listeners

A listener is a process that checks for connection requests on a specific protocol and port.

*   **Protocols:** HTTP (port 80), HTTPS (port 443).
*   **SSL/TLS Certificates:** For an HTTPS listener, you must specify an SSL certificate. This can be a free certificate from AWS Certificate Manager (ACM) or one you have uploaded. This is where the ALB performs SSL/TLS termination.
*   **Default Rule:** Each listener has a default rule that specifies what to do with requests that don't match any of the other rules.

### 2. Rules

Rules are the core of an ALB's advanced routing capabilities. Each rule consists of a priority, one or more actions, and one or more conditions.

*   **Priority:** Rules are evaluated in order from lowest to highest priority number. The first rule that matches is applied.
*   **Conditions (Routing Logic):**
    *   **`host-header`:** Route based on the hostname in the request (e.g., `api.example.com` vs. `www.example.com`). This is also known as host-based routing.
    *   **`path-pattern`:** Route based on the path in the URL (e.g., `/api/*` vs. `/images/*`). This is also known as path-based routing.
    *   **`http-header`:** Route based on the value of a standard or custom HTTP header.
    *   **`http-request-method`:** Route based on the HTTP method (e.g., GET, POST).
    *   **`query-string`:** Route based on the presence or value of a query parameter.
    *   **`source-ip`:** Route based on the source IP address of the request.
*   **Actions:**
    *   **`forward`:** Forward the request to one or more target groups.
    *   **`redirect`:** Return an HTTP redirect (301 or 302) to the client. This is commonly used to redirect HTTP traffic to HTTPS.
    *   **`fixed-response`:** Return a static response with a specific HTTP status code and an optional message body.
    *   **`authenticate-cognito` / `authenticate-oidc`:** Authenticate users with Amazon Cognito or another OIDC-compliant identity provider before forwarding the request.

### 3. Target Groups

A target group is a logical grouping of targets that will receive traffic from the load balancer.

*   **Target Type:** Can be `instance`, `ip`, or `lambda`.
*   **Registered Targets:** The actual EC2 instances, IP addresses, or Lambda function that will handle the requests.
*   **Health Checks:** The ALB sends health check requests to the targets in a group to determine if they are healthy. Traffic is only sent to healthy targets. You can configure the health check protocol, port, path, and thresholds.
*   **Sticky Sessions (Target Group Stickiness):** You can configure a target group to bind a user's session to a specific target instance. This ensures that all requests from the same user during a session are sent to the same target.

## Real-Life Examples and Use Cases

*   **Microservices Routing:**
    *   **Scenario:** You have a microservices-based application with services for users, products, and orders.
    *   **ALB Configuration:**
        *   A rule with condition `path-pattern: /api/users/*` forwards to the `users-service` target group.
        *   A rule with condition `path-pattern: /api/products/*` forwards to the `products-service` target group.
        *   A rule with condition `path-pattern: /api/orders/*` forwards to the `orders-service` target group.
    *   **Benefit:** All services are accessible through a single load balancer endpoint, simplifying client configuration and DNS.

*   **Blue/Green Deployments:**
    *   **Scenario:** You want to deploy a new version of your application with zero downtime.
    *   **ALB Configuration:** You have your current "blue" version running in the `blue-target-group`. You deploy the new "green" version to a separate `green-target-group`. You can then update the listener rule to switch traffic from the blue target group to the green one. If there's an issue, you can quickly revert the rule. You can also use weighted target groups to perform a canary deployment, sending a small percentage of traffic to the new version first.

*   **Host-Based Routing:**
    *   **Scenario:** You are hosting multiple websites (e.g., `blog.example.com` and `shop.example.com`) on the same set of servers.
    *   **ALB Configuration:**
        *   A rule with condition `host-header: blog.example.com` forwards to the `blog-target-group`.
        *   A rule with condition `host-header: shop.example.com` forwards to the `shop-target-group`.

*   **Serverless Application Integration:**
    *   **Scenario:** You have a serverless application where some routes are handled by containers in ECS/Fargate and others by Lambda functions.
    *   **ALB Configuration:** An ALB can have a target group that points to your ECS service and another target group that points to a Lambda function. You can use path-based routing to direct requests appropriately.

*   **Built-in Authentication:**
    *   **Scenario:** You have an internal admin dashboard that you want to protect without building authentication logic into the application itself.
    *   **ALB Configuration:** You can create an authentication action on the listener rule that requires users to log in via Amazon Cognito before their request is forwarded to the application.

ALBs are a powerful and flexible tool for managing traffic to modern web applications, providing routing, security, and scalability in a single managed service.
