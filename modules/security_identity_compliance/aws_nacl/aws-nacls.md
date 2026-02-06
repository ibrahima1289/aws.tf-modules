# AWS Network Access Control Lists (NACLs)

A Network Access Control List (NACL) is an optional layer of security for your VPC that acts as a firewall for controlling traffic in and out of one or more subnets. NACLs evaluate traffic at the subnet boundary, making them a powerful tool for network segmentation and security.

## Core Concepts

*   **Subnet-level Firewall:** NACLs operate at the subnet level, providing a coarse-grained layer of security.
*   **Stateless:** Unlike security groups, NACLs are *stateless*. This means that if you create an inbound rule to allow traffic, you must also create an outbound rule to allow the response traffic.
*   **Rules Processing Order:** NACLs process rules in number order, from lowest to highest. The first rule that matches the traffic is applied, and no further rules are evaluated.
*   **Default Deny:** Every NACL has an implicit deny rule at the end (`*` rule number) for both inbound and outbound traffic. This means that if a packet doesn't match any other rule, it will be denied.

## Key Components and Configuration

### 1. Rules

Each rule specifies whether to allow or deny traffic based on protocol, port, source/destination IP, and traffic direction.

*   **Rule Number:** From 1 to 32766. Rules are evaluated in ascending order. It's common to leave gaps in numbering (e.g., 100, 110, 120) to insert new rules later.
*   **Type:** Specifies the protocol (e.g., ALL Traffic, Custom TCP, HTTP, HTTPS, SSH).
*   **Protocol:** The protocol to which the rule applies (e.g., TCP, UDP, ICMP, All).
*   **Port Range:** The destination port or port range for inbound rules, or the source port or port range for outbound rules.
*   **Source/Destination:** The CIDR block (IP address range) that the rule applies to.
*   **Allow/Deny:** Whether to allow or deny the traffic that matches the rule.

### 2. Inbound Rules

These rules apply to traffic entering the subnet.

| Rule # | Action | Type        | Protocol | Port Range   | Source       | Description                                                |
|:------:|:------:|:------------|:--------:|:-------------|:-------------|:-----------------------------------------------------------|
| 100    | Allow  | SSH         | TCP      | 22           | 0.0.0.0/0    | Allow SSH for management                                  |
| 110    | Allow  | HTTP        | TCP      | 80           | 0.0.0.0/0    | Allow inbound HTTP to web servers                         |
| 120    | Allow  | HTTPS       | TCP      | 443          | 0.0.0.0/0    | Allow inbound HTTPS to web servers                        |
| 130    | Allow  | Custom TCP  | TCP      | 1024-65535   | 0.0.0.0/0    | Allow ephemeral ports for response traffic (stateless NACL)|
| *      | Deny   | ALL Traffic | ALL      | -            | -            | Implicit default deny for any other inbound traffic        |

### 3. Outbound Rules

These rules apply to traffic leaving the subnet.

| Rule # | Action | Type        | Protocol | Port Range   | Destination  | Description                                         |
|:------:|:------:|:------------|:--------:|:-------------|:-------------|:----------------------------------------------------|
| 100    | Allow  | HTTP        | TCP      | 80           | 0.0.0.0/0    | Allow outbound HTTP traffic                         |
| 110    | Allow  | HTTPS       | TCP      | 443          | 0.0.0.0/0    | Allow outbound HTTPS traffic                        |
| 120    | Allow  | Custom TCP  | TCP      | 1024-65535   | 0.0.0.0/0    | Allow ephemeral ports for response traffic to go out|
| *      | Deny   | ALL Traffic | ALL      | -            | -            | Implicit default deny for any other outbound traffic |

### 4. Default NACL

*   Every VPC comes with a default NACL.
*   By default, it allows all inbound and outbound traffic.
*   You can modify the default NACL or create custom ones.

### 5. Custom NACLs

*   You can create custom NACLs and associate them with your subnets.
*   Each subnet can be associated with only one NACL at a time.
*   **Real-life Example:** You create a custom NACL and associate it with a private subnet that hosts your database servers. This NACL would only allow inbound traffic on the database port (e.g., 3306 for MySQL) from your application subnets and deny all other traffic.

## NACLs vs. Security Groups

It's important to understand the differences between NACLs and Security Groups as they both act as firewalls.

| Feature         | Network ACLs                               | Security Groups                               |
| :-------------- | :----------------------------------------- | :-------------------------------------------- |
| **Scope**       | Subnet level                               | Instance level (applies to ENI)              |
| **Nature**      | Stateless (must explicitly allow return traffic) | Stateful (return traffic is automatically allowed) |
| **Rules**       | Support both `ALLOW` and `DENY` rules       | Support only `ALLOW` rules (implicit deny all other) |
| **Processing**  | Process rules in number order              | Evaluate all rules before deciding to allow traffic |
| **Default**     | Default allows all traffic (unless modified) | Default denies all inbound, allows all outbound |

## Purpose and Real-Life Use Cases

*   **Network Segmentation:** Creating hard boundaries between different tiers of your application (e.g., web, application, database) or between environments (e.g., development, production).
*   **Blocking Malicious IP Addresses:** If you identify a malicious IP address or range, you can explicitly deny it at the NACL level, preventing any traffic from that source from reaching your subnets.
*   **Compliance:** Meeting strict security compliance requirements that demand a stateless firewall at the subnet boundary.
*   **Secondary Layer of Defense:** NACLs provide an additional layer of defense in depth. Even if an instance's security group is misconfigured, the NACL can still provide a safeguard.

While security groups are generally the first line of defense for instance-level traffic, NACLs offer a powerful, fine-grained control at the subnet level, especially for denying specific types of traffic or IP ranges.
