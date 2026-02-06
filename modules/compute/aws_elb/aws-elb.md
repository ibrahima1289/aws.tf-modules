# Elastic Load Balancing (ELB)

Elastic Load Balancing (ELB) automatically distributes incoming application traffic across multiple targets, such as Amazon EC2 instances, containers, IP addresses, and Lambda functions. It helps you achieve greater levels of fault tolerance and availability by spreading the load across multiple resources.

## Core Concepts

*   **High Availability:** ELB distributes traffic across healthy targets in multiple Availability Zones, increasing the redundancy of your application.
*   **Health Checks:** ELB periodically sends requests to its registered targets to test their status. It only sends traffic to targets that are considered healthy.
*   **Scalability:** ELB is designed to handle rapid changes in network traffic patterns.
*   **Security:** When used with a VPC, you can use security groups to control access to your load balancers. ELB also supports integrated certificate management for SSL/TLS termination.

## Types of Load Balancers

AWS provides four types of load balancers, each designed for a specific purpose.

### 1. Application Load Balancer (ALB)

*   **Layer:** Operates at the application layer (Layer 7) of the OSI model.
*   **What it does:** ALBs are best for load balancing of HTTP and HTTPS traffic. They are "application-aware" and can make intelligent routing decisions based on the content of the request, such as the URL path, host name, or headers.
*   **Use Cases:**
    *   Microservices and container-based architectures (it's the primary load balancer for ECS and EKS).
    *   Web applications with complex routing needs.
    *   Serverless applications with Lambda functions as targets.
*   **Real-life Example:** You have an e-commerce site with services for products, cart, and checkout. An ALB can route requests to `example.com/products` to the product service, and requests to `example.com/cart` to the cart service, all through the same load balancer endpoint.

### 2. Network Load Balancer (NLB)

*   **Layer:** Operates at the transport layer (Layer 4) of the OSI model.
*   **What it does:** NLBs are designed for ultra-high performance and low latency. They can handle millions of requests per second while maintaining a static IP address per Availability Zone. They route traffic based on IP protocol data (e.g., TCP port).
*   **Use Cases:**
    *   TCP/UDP based traffic.
    *   Applications that require extreme performance and low latency.
    *   Workloads where you need a static IP address.
*   **Real-life Example:** You are running a real-time online gaming service that uses a custom TCP protocol on port 8123. An NLB can distribute this traffic across your game servers with minimal latency.

### 3. Gateway Load Balancer (GLB)

*   **Layer:** Operates at the network layer (Layer 3) of the OSI model.
*   **What it does:** GLBs make it easy to deploy, scale, and manage third-party virtual network appliances, such as firewalls, intrusion detection and prevention systems (IDS/IPS), and deep packet inspection systems. It provides a single entry and exit point for all traffic for a VPC and distributes that traffic to a fleet of virtual appliances.
*   **Use Cases:**
    *   Security inspection of VPC traffic.
    *   Centralizing network appliances for multiple VPCs.
*   **Real-life Example:** A large enterprise wants to inspect all traffic entering and leaving its VPCs for security threats. They can deploy a fleet of third-party firewall appliances behind a GLB. All traffic is transparently routed through the GLB to the firewalls for inspection before continuing to its destination.

### 4. Classic Load Balancer (CLB) - Legacy

*   **Layer:** Operates at both Layer 4 and Layer 7.
*   **What it is:** This is the previous generation of load balancer. It provides basic load balancing across multiple Amazon EC2 instances.
*   **Status:** While still available, AWS strongly recommends using Application Load Balancers or Network Load Balancers for new applications.
*   **Use Cases:** Only for applications that were built within the EC2-Classic network (which is being retired).

## Common Configuration Components

*   **Listeners:** A listener checks for connection requests from clients, using the protocol and port that you configure. Each load balancer must have at least one listener.
*   **Rules:** Rules determine how the listener forwards requests. For an ALB, rules can be based on path or hostname.
*   **Target Groups:** Each target group routes requests to one or more registered targets (e.g., EC2 instances). You define a target group for each set of similar targets. Health checks are configured on the target group.

Choosing the right load balancer is a critical architectural decision based on your application's needs for performance, routing complexity, and security.
