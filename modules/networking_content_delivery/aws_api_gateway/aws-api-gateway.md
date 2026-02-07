# Amazon API Gateway

Amazon API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. It acts as a "front door" for applications to access data, business logic, or functionality from your backend services, whether they run on Amazon EC2, AWS Lambda, or any web application.

## Core Concepts

*   **API Management:** API Gateway handles all the tasks involved in accepting and processing up to hundreds of thousands of concurrent API calls, including traffic management, authorization and access control, monitoring, and API version management.
*   **"Front Door" for Backends:** It provides a unified and secure entry point for clients (web browsers, mobile apps, IoT devices) to interact with your backend services.
*   **Scalable:** API Gateway is a fully managed service that automatically scales to handle any volume of API calls.
*   **Multiple API Types:** Supports REST APIs (HTTP APIs and REST APIs) and WebSocket APIs.

## API Types

### 1. HTTP APIs (Recommended for most RESTful use cases)

*   **Purpose:** Building high-performance, low-latency RESTful APIs. It's a simpler, faster, and more cost-effective alternative to REST APIs for basic use cases.
*   **Features:** Supports OIDC and OAuth 2.0 authorization, built-in CORS, custom domains, and integration with AWS Lambda and HTTP endpoints.
*   **Real-life Example:** Building a microservices-based backend where each microservice exposes a simple HTTP API.

### 2. REST APIs (More features, often used for complex scenarios)

*   **Purpose:** Building powerful, flexible, feature-rich RESTful APIs. Offers more customization and control over the API behavior.
*   **Features:** Supports request/response data transformations, API keys, usage plans, caching, custom authorizers (Lambda Authorizers), AWS WAF integration, and integrates with almost any AWS service.
*   **Real-life Example:** Creating a public API for partners to access your data, where you need strict rate limiting, monetization (usage plans), and detailed request validation.

### 3. WebSocket APIs

*   **Purpose:** Building real-time two-way communication applications, such as chat apps, streaming dashboards, and gaming applications.
*   **Features:** Maintains a persistent connection between the client and the backend, allowing messages to be sent in both directions at any time. Integrates with AWS Lambda and HTTP endpoints.
*   **Real-life Example:** A live chat application where users can send and receive messages instantly.

## Key Components and Configuration (Focus on REST APIs, as they cover most features)

### 1. API Endpoint Types

*   **Edge-Optimized:** For APIs with clients primarily in geographically diverse locations. API requests are routed through CloudFront (AWS's Content Delivery Network) to improve latency.
*   **Regional:** For APIs with clients in the same AWS Region as the API or when you want to control your own CDN.
*   **Private:** For APIs that can only be accessed from within your Amazon Virtual Private Cloud (VPC) using a VPC endpoint.

### 2. Resources and Methods

*   **Resource:** The logical components of your API (e.g., `/users`, `/products/{id}`).
*   **Method:** HTTP verbs (e.g., GET, POST, PUT, DELETE) that apply to a resource.

### 3. Integration Types (Backend)

*   **Lambda Function:** API Gateway passes the request to an AWS Lambda function, which executes your backend code.
    *   **Real-life Example:** A `GET /users` request triggers a Lambda function that queries a DynamoDB table to fetch user data.
*   **HTTP/Proxy:** API Gateway proxies requests to any HTTP endpoint (e.g., an EC2 instance, an on-premises server, another web service).
    *   **Real-life Example:** Integrating with an existing legacy SOAP service by exposing it as a REST API.
*   **AWS Service:** API Gateway integrates directly with other AWS services (e.g., DynamoDB, S3, SQS) using fine-grained IAM permissions.
    *   **Real-life Example:** A `POST /items` request directly inserts an item into a DynamoDB table without needing a Lambda function.
*   **Mock:** API Gateway returns a response without sending the request to a backend. Useful for testing or returning static data.

### 4. Security and Authorization

*   **IAM Permissions:** Use IAM roles and policies to control who can invoke your API (for internal APIs).
*   **Cognito User Pool Authorizer:** Integrates with Amazon Cognito User Pools to provide JWT-based authorization for your API methods.
    *   **Real-life Example:** Only authenticated users from your Cognito User Pool can access the `GET /profile` endpoint.
*   **Lambda Authorizer (Custom Authorizer):** A Lambda function that you provide to control access to your API methods. It returns an IAM policy.
    *   **Real-life Example:** Implementing custom authentication logic, such as validating a custom API key from an internal system.
*   **API Keys & Usage Plans:**
    *   **API Keys:** Unique alphanumeric keys that clients must provide to access your API.
    *   **Usage Plans:** Define who can access your APIs and how often. You can set throttling limits (requests per second) and daily/monthly quotas.
    *   **Real-life Example:** Offering different tiers of access to your API for partners, with free, basic, and premium usage plans.
*   **AWS WAF:** Integrate with AWS Web Application Firewall to protect your APIs from common web exploits.

### 5. Caching

*   **API Caching:** You can enable API caching to cache responses from your API's endpoints. This can reduce the number of calls made to your backend and improve latency.
*   **Real-life Example:** Caching the response of a `GET /products` endpoint for 5 minutes reduces the load on your database and speeds up response times for frequently requested product lists.

### 6. Request and Response Transformation

*   **Mapping Templates (Velocity Template Language - VTL):** For REST APIs, you can transform the request body before sending it to the backend and transform the backend response before sending it back to the client. This is powerful for integrating with backends that expect a different data format.
*   **Real-life Example:** A client sends JSON, but your legacy backend expects XML. You can use a mapping template to convert the JSON request into XML for the backend, and then convert the XML response back to JSON for the client.

### 7. Deployment Stages

*   **Logical References:** A deployment stage is a logical reference to a specific version of your API.
*   **Configuration:** Each stage can have its own configuration, such as throttling limits, caching settings, and logging levels.
*   **Real-life Example:** You have `dev`, `staging`, and `prod` deployment stages. You can deploy a new version of your API to the `staging` stage for testing without affecting `prod` users.

## Purpose and Real-Life Use Cases

*   **Building RESTful and WebSocket APIs:** Quickly expose services running on AWS Lambda, EC2, or other HTTP endpoints.
*   **Serverless Backends:** The cornerstone for building serverless applications using Lambda functions.
*   **Mobile and IoT Backends:** Providing secure and scalable API endpoints for mobile apps and IoT devices.
*   **API Productization:** Creating managed APIs for external developers, with features like API keys, usage plans, and SDK generation.
*   **Microservices Orchestration:** Providing a single entry point to a complex microservices architecture, routing requests to the appropriate backend service.

API Gateway greatly simplifies the task of building and managing APIs, allowing developers to focus on the core business logic of their applications.
