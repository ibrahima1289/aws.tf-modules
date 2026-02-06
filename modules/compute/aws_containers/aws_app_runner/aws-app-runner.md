# AWS App Runner

AWS App Runner is a fully managed service that makes it easy for developers to quickly deploy containerized web applications and APIs, at scale and with no prior infrastructure experience required. App Runner automatically builds and deploys the application, load balances traffic, scales the underlying resources based on demand, and monitors the health of your application.

## Core Concepts

*   **Fully Managed:** App Runner abstracts away all infrastructure management. You don't need to think about servers, clusters, or deployment pipelines.
*   **Source to Production:** You can deploy directly from your source code repository or from a container image.
*   **Automatic Scaling:** App Runner automatically scales the number of containers up or down to meet the needs of your application's traffic.
*   **Integrated Security:** App Runner provides managed TLS, and integrates with AWS secrets and configuration management.

## Configuration Options

### 1. Source

You can deploy to App Runner from two sources:

*   **Source Code Repository:**
    *   **Provider:** GitHub. You connect your GitHub account and choose a repository and branch.
    *   **Runtime:** App Runner detects the language and provides a managed runtime (e.g., Python, Node.js).
    *   **Build Command:** You specify the command to build your application (e.g., `npm install`).
    *   **Start Command:** You specify the command to start your web server (e.g., `node app.js`).
    *   **Real-life Example:** A developer has a Node.js application on GitHub. They can connect their repository to App Runner, and on every `git push` to the main branch, App Runner will automatically build and deploy the new version of the application.

*   **Container Registry:**
    *   **Provider:** Amazon ECR (Elastic Container Registry), including both public and private repositories.
    *   **Image Identifier:** The URI of the container image to deploy.
    *   **Real-life Example:** You have a CI/CD pipeline that builds a Docker image and pushes it to ECR. You can configure App Runner to automatically deploy the new image whenever it's pushed to the ECR repository.

### 2. Auto Scaling

App Runner's auto scaling is configured based on concurrent requests.

*   **Concurrency:** The maximum number of concurrent requests that a single container instance will handle. When this number is exceeded, App Runner will scale out, adding more container instances.
*   **Min Size:** The minimum number of container instances to keep running. The default is 1. If you want to scale to zero to save costs during periods of no traffic, you can set this to 0 (though this is not a supported feature and App Runner may not scale to 0).
*   **Max Size:** The maximum number of container instances that App Runner can scale out to.
*   **Real-life Example:** A simple web API might be able to handle 100 concurrent requests per container. You set the `concurrency` to 100. If the traffic increases to 150 concurrent requests, App Runner will automatically provision a second container instance.

### 3. Health Checks

App Runner performs health checks to monitor the health of your application. If an instance fails the health check, it is automatically replaced.

*   **Protocol:** HTTP or TCP.
*   **Path:** The endpoint to send health check requests to (e.g., `/health`).
*   **Interval:** The time between health checks.
*   **Timeout:** The amount of time to wait for a response before considering the health check to have failed.
*   **Healthy/Unhealthy Threshold:** The number of consecutive successful or failed health checks required to change the status of an instance.
*   **Real-life Example:** Your application has a `/health` endpoint that returns a 200 OK status if the application is healthy. You configure App Runner to send an HTTP request to this endpoint every 10 seconds. If an instance fails to respond correctly for 3 consecutive checks, App Runner will take it out of service and launch a new one.

### 4. Networking

*   **Public Access:** By default, App Runner services are accessible from the public internet. App Runner provides a default domain for your service (e.g., `servicename.region.awsapprunner.com`).
*   **VPC Connector:** You can configure your App Runner service to connect to resources in a Virtual Private Cloud (VPC), such as databases or other backend services.
*   **Real-life Example:** Your web application needs to connect to an RDS database that is located in a private subnet in your VPC. You can create a VPC connector for your App Runner service, allowing it to securely access the database without exposing the database to the public internet.

### 5. Security

*   **IAM Roles:**
    *   **Access Role:** An IAM role that grants App Runner permission to access your ECR images or GitHub repository.
    *   **Instance Role:** An IAM role that your application code can use to access other AWS services.
*   **Secrets and Configuration:** You can securely pass secrets (like API keys or database credentials) to your application using AWS Secrets Manager and AWS Systems Manager Parameter Store.
*   **Real-life Example:** Your application needs to read data from an S3 bucket. You would create an IAM role with S3 read permissions, and assign this role as the `Instance Role` for your App Runner service. Your code can then use the AWS SDK to access S3 without needing to hardcode any credentials.

## Purpose and Real-Life Use Cases

*   **Rapid Prototyping and Development:** Developers can deploy applications in minutes without worrying about infrastructure.
*   **Simple Web APIs and Microservices:** Ideal for running individual, stateless services that need to scale independently.
*   **Internal Tools and Dashboards:** Quickly deploy internal applications for your team.
*   **Student Projects and Hackathons:** The fastest way to get a web application running on AWS.

App Runner is designed for simplicity and speed. For more complex applications or for those who need more control over the environment (e.g., specific networking configurations, sidecar containers), Amazon ECS or EKS would be a better choice.
