# AWS Security Groups

An AWS Security Group acts as a virtual firewall for your EC2 instances to control inbound and outbound traffic. Security groups are stateful, meaning that if you send a request from your instance, the response traffic is automatically allowed, regardless of inbound security group rules.

## Core Concepts

*   **Instance-level Firewall:** Security groups operate at the instance level (specifically, at the Elastic Network Interface (ENI) level), not the subnet level.
*   **Stateful:** If traffic is allowed in one direction (e.g., inbound), the return traffic in the other direction (outbound) is automatically allowed. You don't need to explicitly define outbound rules for responses to inbound traffic.
*   **Default Deny:** By default, a new security group denies all inbound traffic and allows all outbound traffic. You only add "allow" rules.
*   **Allow Rules Only:** You can only specify allow rules; you cannot create deny rules.

## Key Components and Configuration

### 1. Inbound Rules

These rules control the incoming traffic to your instances.

*   **Type:** The type of traffic (e.g., SSH, HTTP, HTTPS, Custom TCP Rule, All TCP, All Traffic).
*   **Protocol:** The IP protocol (e.g., TCP, UDP, ICMP, All).
*   **Port Range:** The destination port or port range (e.g., 22 for SSH, 80 for HTTP, 443 for HTTPS).
*   **Source:** The source of the traffic. This can be:
    *   **A CIDR block:** (e.g., `0.0.0.0/0` for all IPv4 addresses, `54.1.2.3/32` for a specific IP address).
    *   **Another Security Group ID:** This is a powerful feature for allowing traffic between instances based on their security group membership, rather than their IP addresses.
    *   **A Prefix List ID:** A collection of CIDR blocks, useful for simplifying routing to AWS services.
*   **Real-life Example:**
    *   **Web Server Security Group:** Allow `HTTP (80)` and `HTTPS (443)` inbound from `0.0.0.0/0` (the internet). Allow `SSH (22)` inbound from your company's public IP range (e.g., `203.0.113.0/24`).
    *   **Application Server Security Group:** Allow `Custom TCP (8080)` inbound from the `Web Server Security Group`. This means only instances belonging to the web server security group can connect to the app servers on port 8080.

### 2. Outbound Rules

These rules control the outgoing traffic from your instances.

*   **Type, Protocol, Port Range, Destination:** Similar to inbound rules.
*   **Default Behavior:** By default, all outbound traffic is allowed (`All Traffic` to `0.0.0.0/0`). You can modify this to be more restrictive if needed.
*   **Real-life Example:**
    *   **Application Server Security Group:** The default `Allow All` outbound might be fine if your app servers need to connect to various external APIs.
    *   **Database Server Security Group:** You might restrict outbound traffic to only allow connections to specific internal services (e.g., `Custom TCP (587)` to an email relay server within your VPC, or specific ports to other databases for replication).

## Default Security Group

*   Every VPC comes with a default security group.
*   By default, this security group:
    *   Allows all inbound traffic from other instances associated with the *same* default security group.
    *   Allows all outbound traffic.
*   It's generally recommended to create custom security groups for your applications and resources rather than modifying the default one.

## Using Security Groups Effectively

*   **Attach to Network Interfaces:** Security groups are associated with Elastic Network Interfaces (ENIs), which are attached to EC2 instances. When you associate a security group with an instance, it means you're associating it with the instance's primary ENI.
*   **Multiple Security Groups per Instance:** An instance can have multiple security groups associated with it. The rules from all associated security groups are effectively merged.
*   **Referencing Other Security Groups:** A key best practice is to reference other security groups in your rules instead of specific IP addresses. This creates a dynamic firewall that automatically adapts as instances within the referenced security group are launched or terminated.
    *   **Real-life Example:** Your database security group allows inbound traffic on port 3306 from your application server's security group. As app servers scale up or down, the database security group automatically allows traffic from the correct instances.

## Security Groups vs. Network ACLs (NACLs)

| Feature         | Security Groups                            | Network ACLs                               |
| :-------------- | :----------------------------------------- | :-------------------------------------------- |
| **Scope**       | Instance level (applies to ENI)              | Subnet level                               |
| **Nature**      | Stateful (return traffic automatically allowed) | Stateless (must explicitly allow return traffic) |
| **Rules**       | Support only `ALLOW` rules                 | Support both `ALLOW` and `DENY` rules       |
| **Processing**  | Evaluate all rules before deciding to allow traffic | Process rules in number order              |
| **Default**     | Default denies all inbound, allows all outbound | Default allows all (unless modified)        |

Security groups provide the primary instance-level firewall for your resources in AWS. They are an essential part of designing a secure network architecture.
