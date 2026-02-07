# AWS Certificate Manager (ACM)

AWS Certificate Manager (ACM) is a service that lets you easily provision, manage, and deploy public and private SSL/TLS certificates for use with AWS services and your internal connected resources. ACM removes the time-consuming manual process of purchasing, uploading, and renewing SSL/TLS certificates.

## Core Concepts

*   **Managed SSL/TLS Certificates:** ACM handles the complexity of creating, storing, and renewing SSL/TLS certificates.
*   **Free Public Certificates:** ACM provides free SSL/TLS certificates for use with AWS services.
*   **Automatic Renewal:** ACM automatically renews certificates managed by the service, ensuring your applications remain secure without manual intervention.
*   **Integrated with AWS Services:** Seamlessly integrates with services like Elastic Load Balancing (ALB, NLB), Amazon CloudFront, and AWS API Gateway.

## Key Components and Configuration

### 1. Public Certificates

*   **Purpose:** Secure public-facing websites and applications with HTTPS.
*   **Issuance:** ACM can issue publicly trusted SSL/TLS certificates.
*   **Domain Validation:** To prove ownership of a domain, ACM uses either:
    *   **DNS Validation (Recommended):** You add a CNAME record to your domain's DNS configuration. This is fully automated by ACM.
    *   **Email Validation:** ACM sends validation emails to registered contacts for your domain. You click a link in the email to approve.
*   **Automatic Renewal:** Certificates provisioned by ACM are automatically renewed as long as the domain validation remains active (especially easy with DNS validation and Route 53).
*   **Usage with AWS Services:** Public ACM certificates can only be used with integrated AWS services (ALB, CloudFront, API Gateway, etc.). They cannot be directly installed on EC2 instances or on-premises servers.
*   **Real-life Example:** You have a website `www.example.com` hosted behind an Application Load Balancer. You request a public SSL certificate for `www.example.com` from ACM. You use DNS validation with Route 53, and ACM automatically provisions and renews the certificate. The ALB then uses this certificate to handle HTTPS traffic.

### 2. Private Certificates (ACM Private Certificate Authority - ACM PCA)

*   **Purpose:** For securing internal services, devices, and applications within your organization. This is useful when you need a private certificate authority (CA) that you control.
*   **Managed CA:** ACM PCA allows you to create and manage your own private Certificate Authority (CA) hierarchy.
*   **Issuance:** You issue private certificates from your ACM PCA.
*   **Usage:** Private certificates can be used with AWS services, EC2 instances, or on-premises servers.
*   **Real-life Example:** Your microservices communicate internally within a VPC. You want to encrypt all internal traffic with TLS. You set up an ACM PCA, issue private certificates for each of your microservices, and deploy these certificates to your ECS containers or EC2 instances.

### 3. Certificate Export

*   **Public Certificates:** Cannot be exported from ACM. They are bound to AWS services.
*   **Private Certificates:** Can be exported for use on EC2 instances, containers, or on-premises servers.

### 4. Integration with AWS Services

*   **Elastic Load Balancing (ALB, NLB):** Certificates are easily attached to listeners for SSL/TLS termination. (See `aws-elb.md`, `aws-alb.md`, `aws-nlb.md`)
*   **Amazon CloudFront:** Used to secure custom domain names for your CDN distributions. Note: CloudFront certificates must be provisioned in the `us-east-1` region, regardless of your primary region. (See `aws-cloudfront.md`)
*   **AWS API Gateway:** Secure custom domain names for your API endpoints. (See `aws-api-gateway.md`)
*   **AWS AppSync:** Secure custom domain names for your GraphQL APIs. (See `aws-appsync.md`)
*   **AWS Global Accelerator:** Secure custom domain names for your accelerators.
*   **Amazon CloudWatch:** Monitor certificate expiration dates.

## Purpose and Real-life Use Cases

*   **Website Security (HTTPS):** Ensuring secure communication for public-facing web applications.
*   **API Security:** Securing API endpoints for mobile apps, IoT devices, or microservices communication.
*   **Internal Service Encryption:** Encrypting traffic between internal applications and microservices in a VPC.
*   **IoT Device Security:** Issuing and managing certificates for IoT devices for secure authentication.
*   **Email Security:** Securing email communication for specific email domains.
*   **VPN Connections:** Providing TLS certificates for client VPN connections.
*   **Cost Savings:** Eliminating the cost of purchasing public SSL/TLS certificates.
*   **Operational Efficiency:** Automating certificate lifecycle management, reducing the manual effort of renewal and deployment.
*   **Compliance:** Meeting security and compliance requirements that mandate the use of SSL/TLS encryption.

AWS Certificate Manager simplifies the complex and often error-prone process of managing SSL/TLS certificates, enhancing the security and operational efficiency of your applications on AWS.
