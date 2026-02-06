# Network Load Balancer (NLB)

A Network Load Balancer (NLB) is a type of Elastic Load Balancer that operates at the transport layer (Layer 4) of the OSI model. It is capable of handling millions of requests per second with ultra-low latencies. It is best suited for load balancing of TCP, UDP, and TLS traffic where extreme performance is required.

## Core Concepts

*   **Layer 4 Load Balancing:** NLB routes traffic based on IP protocol data (source/destination IP address and port). It does not look at the content of the packets, which allows it to be extremely fast.
*   **High Throughput and Low Latency:** NLB is designed for performance-critical applications.
*   **Preserves Source IP:** The NLB preserves the client-side source IP address, allowing the back-end application to see the IP address of the client. This is different from an ALB, which acts as a proxy and replaces the source IP with its own.
*   **Static IP Support:** An NLB can have a static Elastic IP address assigned to it in each Availability Zone, providing a fixed entry point for your application.

## Key Components and Configuration

### 1. Listeners

A listener checks for connection requests from clients on a specific protocol and port.

*   **Protocols:** TCP, UDP, TLS, TCP_UDP.
*   **Port:** Any port from 1 to 65535.
*   **Default Action:** Each listener has a default action, which is typically to forward traffic to a target group.
*   **TLS Listeners:** For a TLS listener, the NLB can terminate the TLS connection. You must specify a certificate from AWS Certificate Manager (ACM). This is useful for offloading the work of encryption and decryption from your backend servers.

### 2. Target Groups

A target group is a logical grouping of targets that will receive traffic from the load balancer.

*   **Target Type:** Can be `instance`, `ip`, or `alb`. Yes, an NLB can forward traffic to an Application Load Balancer, which is useful in some advanced architectures.
*   **Protocols:** TCP, UDP, TLS, TCP_UDP.
*   **Health Checks:** NLB performs health checks on its registered targets to ensure they are healthy before sending traffic to them. You can use TCP, HTTP, or HTTPS health checks.
    *   **Note:** Because NLB operates at Layer 4, even for an HTTP/HTTPS health check, it's checking the health of the target on a specific port. It doesn't interpret the HTTP status code in the same way an ALB does. It only cares that a TCP connection can be established and a response is received.
*   **Proxy Protocol v2:** If you need to preserve the source IP address but also have TLS termination on the NLB, the backend application will see the NLB's IP as the source. To solve this, you can enable Proxy Protocol v2 on the target group. This adds a header to the TCP request that includes the original client IP information. Your application must be able to parse this header.

## Real-Life Examples and Use Cases

*   **High-Performance and Latency-Sensitive Applications:**
    *   **Scenario:** You are running a high-frequency trading platform or a real-time multiplayer game server where every millisecond of latency counts.
    *   **NLB Configuration:** You would use an NLB with a TCP or UDP listener to forward traffic directly to your application servers.
    *   **Benefit:** NLB provides the lowest possible latency for load balancing on AWS.

*   **Applications Requiring a Static IP:**
    *   **Scenario:** You have a service that is consumed by customers who need to whitelist a specific IP address in their firewalls to allow outbound connections.
    *   **NLB Configuration:** You create an NLB and assign an Elastic IP address to it in each AZ it's configured for.
    *   **Benefit:** The IP address of the NLB remains fixed, making it easy for your customers to configure their firewalls.

*   **Containerized Applications with Direct Pod Access:**
    *   **Scenario:** In an EKS cluster, you want to expose a service and have the client's source IP be visible to the pod for network policy or logging purposes.
    *   **NLB Configuration:** You create a Kubernetes service of type `LoadBalancer`. EKS will automatically provision an NLB to route traffic directly to the pods.
    *   **Benefit:** The pod can see the true source IP of the client, which is often a requirement for security and compliance.

*   **Exposing a VPC Endpoint Service:**
    *   **Scenario:** You have a service running in your VPC that you want to offer to other AWS customers to consume privately from their own VPCs using AWS PrivateLink.
    *   **NLB Configuration:** You must place your service behind an NLB. You then create a VPC endpoint service and associate it with that NLB.
    *   **Benefit:** This is the required architecture for building and selling SaaS solutions that can be accessed privately and securely within the AWS network.

*   **Combined ALB and NLB Architecture:**
    *   **Scenario:** You want to use AWS WAF (Web Application Firewall) to protect your web application, but you also need a static IP address. WAF can only be associated with an ALB, and only an NLB can provide a static IP.
    *   **NLB/ALB Configuration:**
        1.  Create an internal ALB and place your EC2/ECS targets behind it.
        2.  Associate AWS WAF with the ALB.
        3.  Create an NLB and set its target group to be the private IP addresses of the ALB.
        4.  Assign an Elastic IP to the NLB.
    *   **Benefit:** This architecture combines the benefits of both load balancers: the static IP from the NLB and the Layer 7 inspection and filtering from the ALB with WAF.

NLB is the go-to choice when you need extreme performance, low latency, Layer 4 load balancing, or a static IP address for your application's entry point.
