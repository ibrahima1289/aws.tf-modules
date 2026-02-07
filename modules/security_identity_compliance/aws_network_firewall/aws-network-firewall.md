# AWS Network Firewall

AWS Network Firewall is a fully managed, highly available network security service for your Amazon Virtual Private Cloud (VPC). It makes it easier to deploy essential network protections for all your VPCs without the need to deploy and manage a fleet of third-party firewalls. Network Firewall provides granular control over network traffic, including intrusion prevention and detection capabilities.

## Core Concepts

*   **Managed Firewall:** AWS handles the deployment, scaling, patching, and high availability of the firewall infrastructure.
*   **VPC-native:** Designed to seamlessly integrate within your VPC environment.
*   **Deep Packet Inspection:** Provides deep inspection of traffic flowing through your VPC, allowing for advanced filtering rules.
*   **Stateful and Stateless Filtering:** Supports both stateless (packet-level) and stateful (connection-level) traffic filtering.
*   **Integrated with AWS Firewall Manager:** Can be centrally deployed and managed across multiple accounts and VPCs using AWS Firewall Manager.

## Key Components and Configuration

### 1. Firewall Endpoints

*   **Purpose:** The entry and exit points for traffic that you want to inspect. You deploy a firewall endpoint into a dedicated subnet in your VPC.
*   **Placement:** For high availability, you typically deploy at least one firewall endpoint per Availability Zone where your application subnets reside.
*   **Traffic Routing:** You update the route tables of your application subnets (or gateway route tables) to direct traffic through the firewall endpoint.
*   **Real-life Example:** You have application subnets in `us-east-1a` and `us-east-1b`. You deploy a Network Firewall endpoint in a separate `firewall-subnet-a` in `us-east-1a` and another endpoint in `firewall-subnet-b` in `us-east-1b`. You then configure the route tables of your application subnets to send internet-bound traffic through these firewall endpoints.

### 2. Firewall Policies

*   **Purpose:** A firewall policy defines the rules and settings that your Network Firewall endpoints will apply to traffic.
*   **Rule Groups:** A policy can reference multiple stateless and stateful rule groups.
*   **Default Actions:** You define a default action for stateless (e.g., `PASS`, `DROP`, `FORWARD_TO_STATEFUL`) and stateful (e.g., `DROP`, `ALERT`) traffic that doesn't match any explicit rules.
*   **Real-life Example:** You create a firewall policy named `ProductionFirewallPolicy` that combines a stateless rule group for basic filtering and a stateful rule group for intrusion prevention.

### 3. Rule Groups

Rule groups are collections of individual firewall rules.

*   **Stateless Rule Groups:**
    *   **Purpose:** Perform fast, packet-level filtering. They evaluate each packet independently, without considering the context of a connection.
    *   **Rules:** Defined using 5-tuple (protocol, source IP, source port, destination IP, destination port).
    *   **Real-life Example:** A stateless rule group blocks all UDP traffic from `0.0.0.0/0` on port 53 (DNS) to prevent unauthorized DNS requests from entering your VPC.
*   **Stateful Rule Groups:**
    *   **Purpose:** Perform deeper inspection of traffic, considering the context of a connection. They track connection states and can detect patterns across multiple packets.
    *   **Rules:** Can use 5-tuple, domain names, Suricata compatible intrusion prevention system (IPS) rules.
    *   **Actions:** `ALLOW`, `DROP`, `ALERT`.
    *   **Real-life Example:** A stateful rule group:
        *   Blocks all outbound traffic to known malicious domains.
        *   Detects and alerts on attempts to access internal resources from the internet via SSH, even if the traffic is encrypted.
        *   Allows only established connections for web traffic (HTTP/HTTPS) to pass through.

### 4. Integration with AWS Firewall Manager

*   **Centralized Deployment:** AWS Firewall Manager can centrally deploy and manage AWS Network Firewall endpoints and policies across multiple accounts and VPCs in your AWS Organization. (See `aws-firewall-manager.md`)
*   **Real-life Example:** Your central security team defines a `CorporateNetworkFirewallPolicy` in Firewall Manager. This policy automatically deploys AWS Network Firewall endpoints in all new and existing VPCs within your `Production` OU and applies the defined rule groups.

### 5. Logging and Monitoring

*   **Amazon CloudWatch Logs:** Network Firewall can send detailed flow logs and alert logs to CloudWatch Logs for real-time monitoring and analysis.
*   **Amazon S3:** Logs can also be sent to S3 for long-term storage and data lake analysis.
*   **Kinesis Data Firehose:** Integrate with Kinesis Data Firehose for streaming logs to other destinations.
*   **Real-life Example:** All Network Firewall alert logs are sent to a central CloudWatch Logs log group. A CloudWatch alarm triggers an SNS notification if the number of "DROP" alerts (e.g., blocked intrusion attempts) exceeds a threshold.

## Purpose and Real-life Use Cases

*   **Centralized Egress/Ingress Filtering:** Controlling all traffic entering and leaving your VPCs, including internet-bound traffic and traffic between VPCs (via Transit Gateway).
*   **Intrusion Prevention and Detection:** Protecting your applications from common network exploits, malware, and unauthorized access attempts.
*   **Compliance and Security:** Helping organizations meet regulatory compliance requirements for network security and segmentation.
*   **Microsegmentation:** Enforcing granular network policies between different application tiers or services within a VPC.
*   **Hybrid Cloud Security:** Extending consistent network security policies to your on-premises connections (e.g., VPN, Direct Connect).
*   **Reducing Operational Overhead:** Eliminating the need to deploy and manage third-party firewall appliances, allowing security teams to focus on policy definition.

AWS Network Firewall provides a powerful, managed, and scalable network security solution for your VPCs, offering essential protection against a wide range of network-based threats.
