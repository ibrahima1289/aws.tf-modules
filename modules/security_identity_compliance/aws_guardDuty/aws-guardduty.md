# Amazon GuardDuty

Amazon GuardDuty is a threat detection service that continuously monitors your AWS accounts and workloads for malicious activity and unauthorized behavior to protect your AWS resources. It uses machine learning, anomaly detection, and integrated threat intelligence to identify and prioritize potential threats.

## Core Concepts

*   **Intelligent Threat Detection:** Continuously monitors for malicious activity (e.g., cryptocurrency mining, unauthorized access attempts, compromised instances) without deploying agents.
*   **Machine Learning Powered:** Uses machine learning models to detect anomalies and identify new threats.
*   **Integrated Threat Intelligence:** Leverages continually updated threat intelligence feeds (e.g., lists of malicious IP addresses, domains).
*   **Serverless:** Fully managed, so no infrastructure to deploy or maintain.
*   **Prioritized Findings:** Provides security findings with severity levels and detailed context to help you prioritize and respond to threats.

## Key Components and Configuration

### 1. Data Sources

GuardDuty automatically analyzes data from several AWS sources for potential threats.

*   **AWS CloudTrail Management Events:** Monitors management API calls for suspicious activities (e.g., IAM credential compromise, unusual API calls).
*   **Amazon VPC Flow Logs:** Analyzes network traffic data (who is talking to whom) for anomalies (e.g., communication with known malicious IPs, port scanning).
*   **DNS Query Logs:** Monitors DNS queries for requests to known malicious domains.
*   **Amazon S3 Data Event Logs:** Monitors S3 object-level API activity for suspicious behavior (e.g., unauthorized data exfiltration, deletion of logs).
*   **Amazon EKS Audit Logs:** Monitors Kubernetes API server activity in your EKS clusters for potential container compromise.
*   **Amazon RDS Login Activity:** Monitors successful and failed login attempts to your RDS databases for potential brute-force attacks or credential compromise.
*   **Real-life Example:** GuardDuty monitors your VPC Flow Logs and detects an EC2 instance communicating with an IP address identified as a known command-and-control server. This triggers a `Backdoor:EC2/C&CActivity` finding.

### 2. Findings

When GuardDuty detects a potential threat, it generates a "finding."

*   **Severity Levels:** Findings are assigned severity levels (High, Medium, Low) to help you prioritize.
    *   **High:** Indicates a confirmed compromise.
    *   **Medium:** Indicates suspicious activity that needs investigation.
    *   **Low:** Indicates unusual activity that might warrant review.
*   **Finding Types:** GuardDuty has a large and growing list of predefined finding types (e.g., `Trojan:EC2/BlackholeTraffic`, `PrivilegeEscalation:IAMUser/NetworkPermissions`, `Policy:S3/BypassedBucketPolicies`).
*   **Detailed Context:** Each finding includes details such as the affected resource, AWS account ID, time of detection, associated IP addresses, user agents, and recommended actions.
*   **Real-life Example:** GuardDuty detects `UnauthorizedAccess:EC2/SSHBruteForce` (High severity) on an EC2 instance and also `CryptoMining:EC2/BitcoinTool.B` (Medium severity). It also flags `S3/Exfiltration` if data is being copied to an unusual destination.

### 3. Threat Lists

*   **Trusted IP Lists:** You can provide lists of trusted IP addresses that are known to be safe (e.g., your corporate VPN range). GuardDuty will ignore activity from these IPs unless it's explicitly malicious.
*   **Threat IP Lists:** You can upload custom threat intelligence feeds (lists of known malicious IP addresses). GuardDuty will generate findings for any activity involving these IPs.
*   **Real-life Example:** You add your corporate VPN CIDR block to the trusted IP list, so GuardDuty doesn't flag legitimate connections from your internal network. You subscribe to a third-party threat intelligence feed and import it as a custom threat list.

### 4. Suppression Rules

*   **Purpose:** To suppress findings that you deem to be false positives or acceptable risks, reducing noise.
*   **Configuration:** You define criteria (e.g., specific finding type, affected resource, IP address) for findings to be automatically archived.
*   **Real-life Example:** GuardDuty consistently flags a "Port scanning" finding from an internal security scanner that you run regularly. You create a suppression rule for this specific finding type originating from your scanner's IP address.

### 5. Integration with AWS Organizations

*   **Centralized Management:** In an AWS Organizations setup, one account is designated as the master account for GuardDuty. This account can enable and manage GuardDuty across all member accounts.
*   **Centralized Findings:** All findings from member accounts are sent to the master account.
*   **Real-life Example:** Your central security team manages GuardDuty from the master account, receiving findings from all your production, development, and sandbox accounts in one consolidated view.

### 6. Notifications and Automation

*   **Amazon EventBridge:** All GuardDuty findings are sent to Amazon EventBridge.
*   **Targets:** You can create EventBridge rules to send findings to various targets:
    *   **AWS Security Hub:** For centralized security posture management.
    *   **AWS Lambda:** To trigger automated remediation actions (e.g., isolate a compromised EC2 instance, block a malicious IP).
    *   **Amazon SNS:** For email/SMS notifications.
    *   **AWS Chatbot:** For notifications to Slack/Chime.
*   **Real-life Example:** A high-severity GuardDuty finding (`UnauthorizedAccess:IAMUser/RootCredentialUsage`) triggers an EventBridge rule. This rule invokes a Lambda function that automatically revokes the compromised root user credentials and notifies the security team via an SNS topic.

## Purpose and Real-life Use Cases

*   **Continuous Threat Detection:** Providing 24/7 monitoring for malicious activity in your AWS environment.
*   **Security Posture Improvement:** Identifying vulnerabilities and misconfigurations that attackers might exploit.
*   **Incident Response Acceleration:** Helping security teams quickly identify, understand, and respond to threats.
*   **Compliance and Auditing:** Providing a record of threat detection events for audit purposes.
*   **Protection Against Zero-Day Exploits:** GuardDuty's ML capabilities can sometimes detect new, unknown threats.
*   **Cloud Security Operations:** A foundational service for any robust cloud security strategy.

Amazon GuardDuty acts as a vigilant security guard for your AWS environment, providing intelligent and automated threat detection to protect your valuable resources and data.
