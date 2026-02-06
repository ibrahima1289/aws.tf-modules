# AWS Virtual Private Cloud (VPC)

Amazon Virtual Private Cloud (VPC) enables you to launch AWS resources into a virtual network that you've defined. This virtual network closely resembles a traditional network that you'd operate in your own data center, with the benefits of using the scalable infrastructure of AWS. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways.

## Core Concepts

*   **Isolated Network:** A VPC is a logically isolated section of the AWS Cloud where you can launch AWS resources.
*   **Customer Controlled:** You have granular control over the network configuration, including IP address ranges, subnets, route tables, and network gateways.
*   **Global, Regional, and AZ Scopes:** VPCs are regional resources. Subnets are Availability Zone-specific resources within a VPC.

## Key Components and Configuration

### 1. CIDR Block

*   **Primary CIDR Block:** When you create a VPC, you must specify an IPv4 CIDR block for it (e.g., `10.0.0.0/16`). This range cannot be changed after creation.
*   **Secondary CIDR Blocks:** You can add additional IPv4 CIDR blocks and IPv6 CIDR blocks to your VPC. These can be removed later.
*   **Real-life Example:** You create a VPC with a `10.0.0.0/16` CIDR. This gives you 65,536 private IP addresses to work with within your VPC.

### 2. Subnets

*   **Logical Segments:** You divide your VPC's CIDR block into smaller ranges called subnets. Each subnet must reside entirely within one Availability Zone.
*   **Public and Private Subnets:** As discussed in `aws-subnets.md`, subnets are classified based on their internet accessibility.
*   **Real-life Example:** From your `10.0.0.0/16` VPC, you create:
    *   `10.0.1.0/24` in `us-east-1a` (public web subnet)
    *   `10.0.2.0/24` in `us-east-1b` (public web subnet)
    *   `10.0.10.0/24` in `us-east-1a` (private app subnet)
    *   `10.0.11.0/24` in `us-east-1b` (private app subnet)
    *   `10.0.20.0/24` in `us-east-1a` (private DB subnet)
    *   `10.0.21.0/24` in `us-east-1b` (private DB subnet)

### 3. Route Tables

*   **Traffic Routing:** Route tables control where network traffic from your subnets or gateways is directed.
*   **Main Route Table:** The default route table that comes with your VPC.
*   **Custom Route Tables:** You can create custom route tables and explicitly associate them with subnets. This allows for fine-grained control over network traffic.
*   **Real-life Example:** Your public subnets are associated with a route table that directs internet-bound traffic to an Internet Gateway. Your private subnets are associated with a route table that directs internet-bound traffic to a NAT Gateway.

### 4. Internet Gateway (IGW)

*   **Internet Connectivity:** An Internet Gateway enables communication between your VPC and the internet.
*   **Attachment:** You attach an IGW to your VPC. A VPC can only have one IGW.
*   **Real-life Example:** You attach an IGW to your VPC to allow your public web servers to communicate with the internet.

### 5. NAT Gateway (or NAT Instance)

*   **Outbound Internet Access for Private Subnets:** A NAT Gateway enables instances in a private subnet to connect to the internet or other AWS services, but prevents the internet from initiating a connection with those instances.
*   **Placement:** A NAT Gateway must be deployed in a public subnet.
*   **Real-life Example:** Your application servers in private subnets need to download software updates or connect to external APIs. They route their internet-bound traffic through a NAT Gateway located in a public subnet.

### 6. Security

*   **Security Groups:** Act as a virtual firewall at the instance level. They control inbound and outbound traffic for individual instances or network interfaces. They are stateful.
*   **Network Access Control Lists (NACLs):** Act as a stateless firewall at the subnet level. They control inbound and outbound traffic for entire subnets.
*   **Real-life Example:** A security group for your web servers allows inbound HTTP/HTTPS traffic from anywhere. A NACL on your database subnet only allows traffic on the database port from the security group of your application servers.

### 7. VPC Peering

*   **Connecting VPCs:** VPC peering connection allows you to route traffic between two VPCs privately using IPv4 or IPv6 addresses. Instances in either VPC can communicate with each other as if they are within the same network.
*   **Limitations:** VPC peering is a one-to-one connection. It does not support transitive peering (meaning you cannot reach a third VPC through a peered VPC).
*   **Real-life Example:** You have a "shared services" VPC that contains a centralized logging server. You can peer your application VPC with the shared services VPC to allow your application instances to send logs to the logging server.

### 8. VPC Endpoints

*   **Private Connectivity to AWS Services:** VPC endpoints allow you to privately connect your VPC to supported AWS services and VPC endpoint services powered by AWS PrivateLink, without requiring an Internet Gateway, NAT device, VPN connection, or AWS Direct Connect connection.
*   **Interface Endpoints:** Powered by AWS PrivateLink, an interface endpoint is an elastic network interface (ENI) with a private IP address that serves as an entry point for traffic to a supported service.
*   **Gateway Endpoints:** A gateway that you specify as a target for a route in your route table for traffic destined to S3 or DynamoDB.
*   **Real-life Example:** Your instances in a private subnet need to store data in S3. Instead of routing traffic through a NAT Gateway to the public S3 endpoint, you can create a Gateway Endpoint for S3 in your VPC. All S3 traffic stays within the AWS network, improving security and potentially reducing costs.

## Purpose and Real-Life Use Cases

*   **Network Isolation:** Creating distinct environments for development, staging, and production workloads.
*   **Multi-Tier Architectures:** Separating application components (web, app, DB) into different subnets with varying levels of internet access and security.
*   **Hybrid Cloud:** Connecting your on-premises data centers to your VPC using VPN or Direct Connect.
*   **Enhanced Security:** Granular control over network traffic flow using security groups and NACLs.
*   **Compliance:** Meeting specific industry or regulatory compliance requirements for network architecture.

VPC is the foundational networking service in AWS, providing the flexibility and control needed to design complex and secure cloud environments.
