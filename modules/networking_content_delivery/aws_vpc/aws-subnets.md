# AWS Subnets

In AWS, a subnet (short for subnetwork) is a range of IP addresses in your Virtual Private Cloud (VPC). You launch your AWS resources, such as Amazon EC2 instances, into subnets. Subnets enable you to partition your VPC into logical segments for organization, security, and availability.

## Core Concepts

*   **VPC Subdivision:** A subnet is a section of a VPC where you can place groups of isolated resources.
*   **Availability Zone (AZ) Scope:** A subnet always resides entirely within one Availability Zone and cannot span multiple AZs. This is critical for high availability design.
*   **IP Address Range (CIDR Block):** Each subnet has a Classless Inter-Domain Routing (CIDR) block, which is a contiguous range of IP addresses. The subnet's CIDR block is a subdivision of the VPC's CIDR block.

## Types of Subnets

Based on their routing to the internet, subnets are categorized as public or private.

### 1. Public Subnet

*   **Definition:** A public subnet is a subnet whose route table contains a route to an Internet Gateway (IGW).
*   **Internet Access:** Instances launched in a public subnet can send outbound traffic directly to the internet (via the IGW). If they have a public IP address, they can also receive inbound traffic from the internet.
*   **Use Cases:** Web servers, public-facing load balancers (ALB, NLB), bastion hosts.
*   **Real-life Example:** Your web servers are placed in a public subnet. The public subnet's route table has a default route (`0.0.0.0/0`) pointing to an Internet Gateway. This allows internet users to access your web application.

### 2. Private Subnet

*   **Definition:** A private subnet is a subnet whose route table does *not* contain a route to an Internet Gateway.
*   **Internet Access:** Instances launched in a private subnet cannot directly access the internet, nor can they be accessed from the internet (unless you specifically configure other mechanisms like a NAT Gateway or VPC endpoint).
*   **Use Cases:** Database servers (RDS), application servers, backend services, internal tools.
*   **Real-life Example:** Your database servers are placed in a private subnet. The private subnet's route table only contains routes to other internal resources (like a NAT Gateway for outbound internet access or other subnets in the VPC), preventing direct exposure to the public internet.

### 3. Isolated Subnet (Special Type of Private Subnet)

*   **Definition:** An isolated subnet is a private subnet with no internet access whatsoever, not even through a NAT Gateway.
*   **Use Cases:** Highly sensitive data processing, storing critical secrets, or specific compliance requirements where no outbound internet access is permitted.
*   **Real-life Example:** You have a compliance requirement that your HSM (Hardware Security Module) instances must never have internet access. You place these instances in an isolated subnet whose route table only allows internal VPC communication.

## Configuration Options

### 1. CIDR Block

*   **Size:** The smallest subnet you can create in a VPC is a `/28` (16 IP addresses), and the largest is a `/16` (65,536 IP addresses).
*   **Relationship to VPC CIDR:** The subnet CIDR block must be a subset of the VPC's CIDR block.
*   **AWS Reserved IPs:** AWS reserves the first four and the last IP address in every subnet's CIDR block for internal networking purposes.
    *   Example: For a `10.0.0.0/24` subnet:
        *   `10.0.0.0`: Network address
        *   `10.0.0.1`: VPC router
        *   `10.0.0.2`: DNS server
        *   `10.0.0.3`: Future use
        *   `10.0.0.255`: Network broadcast address (not supported in VPC)

### 2. Availability Zone

You choose which Availability Zone your subnet will be created in. For high availability, you should distribute your resources across multiple subnets, each in a different AZ.

*   **Real-life Example:** For a highly available web application, you would create public subnets in `us-east-1a`, `us-east-1b`, and `us-east-1c`. You would do the same for private subnets.

### 3. Route Table Association

As discussed in the `aws-route-table.md` document, each subnet must be associated with a route table that dictates its traffic flow.

### 4. Auto-assign Public IPv4 Address

*   **Setting:** This is a subnet-level setting. If enabled, instances launched into this subnet will automatically receive a public IPv4 address.
*   **Best Practice:** Typically enabled for public subnets and disabled for private subnets.

### 5. Network Access Control Lists (NACLs)

Each subnet is associated with a NACL, which provides a stateless firewall at the subnet boundary. This allows you to apply security rules to all traffic entering or leaving the subnet.

## Purpose and Real-Life Use Cases

*   **Network Isolation and Security:** Separating different tiers of an application (e.g., frontend, backend, database) into different subnets for enhanced security. For example, database servers should always be in private subnets.
*   **High Availability:** Distributing resources across subnets in different Availability Zones to protect against AZ-wide outages.
*   **Routing Control:** Using different route tables for different subnets to control how traffic flows in and out of those segments.
*   **Resource Organization:** Logically grouping resources that have similar networking or security requirements.
*   **Cost Control:** In some cases, resources in private subnets accessing the internet via a NAT Gateway incur charges, making the decision to place certain resources in public vs. private subnets relevant to cost optimization.

Subnets are a fundamental building block of your network architecture in AWS, allowing you to design a robust, secure, and highly available environment.
