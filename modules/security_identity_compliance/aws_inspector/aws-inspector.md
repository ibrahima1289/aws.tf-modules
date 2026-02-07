# Amazon Inspector

Amazon Inspector is an automated vulnerability management service that continuously scans your AWS workloads for software vulnerabilities and unintended network exposure. It identifies potential security issues in Amazon EC2 instances, container images stored in Amazon ECR, and AWS Lambda functions.

## Core Concepts

*   **Automated Vulnerability Management:** Continuously discovers and reports software vulnerabilities and network exposures.
*   **Continuous Scanning:** Automatically rescans resources when new vulnerabilities are published or when configurations change.
*   **Contextualized Findings:** Provides actionable security findings with a severity score and detailed remediation steps.
*   **Integrated with AWS Services:** Works seamlessly with Amazon EC2, Amazon ECR, AWS Lambda, and AWS Organizations.

## Key Components and Configuration

### 1. Enabling Inspector

*   **Account-level Service:** You enable Inspector at the AWS account level.
*   **Region Specific:** You enable Inspector in each AWS Region where you have resources.
*   **AWS Organizations Integration:** In an AWS Organizations setup, the management account can delegate a member account to be the Inspector delegated administrator. This allows for centralized management and findings across multiple accounts.
*   **Real-life Example:** Your security team enables Inspector as a delegated administrator in your security account, which then enables it across all production AWS accounts in your organization.

### 2. Scanning Types

Inspector automatically performs scans for:

*   **EC2 Instance Scanning:**
    *   **Purpose:** Discovers software vulnerabilities in EC2 instances.
    *   **How it works:** Inspector deploys an SSM Agent to your instances. This agent collects data for vulnerability analysis.
    *   **Configuration:** Ensure the SSM Agent is installed and running on your EC2 instances.
    *   **Real-life Example:** Inspector identifies that an EC2 instance running Ubuntu has an outdated version of Apache HTTP Server with a known CVE.
*   **Container Image Scanning (ECR):**
    *   **Purpose:** Scans container images stored in Amazon ECR for operating system and programming language package vulnerabilities.
    *   **How it works:** Integrated with ECR, it scans new images pushed to ECR and existing images on a continuous basis.
    *   **Real-life Example:** Inspector detects a critical vulnerability in the `glibc` package of a Docker image stored in your ECR repository.
*   **Lambda Function Scanning:**
    *   **Purpose:** Scans AWS Lambda function code and associated layer packages for code vulnerabilities.
    *   **How it works:** Inspector analyzes the function code and its dependencies.
    *   **Real-life Example:** Inspector finds a known vulnerability in a Python library used by one of your critical Lambda functions.

### 3. Network Reachability Analysis

*   **Purpose:** Identifies potentially unintended network exposure for your EC2 instances. It analyzes your network configurations (VPCs, subnets, security groups, NACLs, route tables, internet gateways, NAT gateways) to determine network paths to your instances.
*   **How it works:** Creates a graphical representation of the network paths and highlights any instances that are reachable from the internet or other untrusted sources on ports you might not intend.
*   **Real-life Example:** Inspector detects that a database server (which should be private) is unintentionally reachable from the internet on port 3306 due to a misconfigured security group or network ACL.

### 4. Findings

When Inspector identifies a security issue, it generates a "finding."

*   **Severity Levels:** Findings are assigned severity levels (Critical, High, Medium, Low, Informational) based on industry standards like CVSS.
*   **Detailed Context:** Each finding includes:
    *   **Affected Resource:** The EC2 instance, ECR image, or Lambda function.
    *   **Vulnerability Details:** CVE ID, description, affected package, and version.
    *   **Remediation Steps:** Clear instructions on how to fix the vulnerability (e.g., update package to a newer version, restrict security group rule).
    *   **Exploitability Information:** Indicates if an exploit is publicly available.
    *   **EPSS (Exploit Prediction Scoring System) Score:** A probability score (0-1) that a software vulnerability will be exploited in the next 30 days.
*   **Real-life Example:** Inspector generates a High-severity finding for an ECR image, indicating a specific CVE in a Python library, and recommends updating the library to a version patched for the vulnerability.

### 5. Integration with AWS Security Hub

*   **Centralized Security:** Inspector findings are automatically sent to AWS Security Hub, providing a consolidated view of your security posture across multiple AWS services. (See `aws-security-hub.md`)

### 6. Notifications and Automation

*   **Amazon EventBridge:** All Inspector findings are sent to Amazon EventBridge.
*   **Targets:** You can create EventBridge rules to send findings to various targets:
    *   **AWS Lambda:** To trigger automated remediation actions (e.g., automatically create a patch task in AWS Systems Manager Patch Manager).
    *   **Amazon SNS:** For email/SMS notifications to your security team.
    *   **AWS Chatbot:** For notifications to Slack/Chime.
*   **Real-life Example:** A Critical-severity Inspector finding for an ECR image triggers an EventBridge rule. This rule invokes a Lambda function that automatically marks the vulnerable image as "do not use" in your image registry and notifies the DevOps team to rebuild the image.

## Purpose and Real-life Use Cases

*   **Continuous Vulnerability Management:** Automating the process of identifying and reporting software vulnerabilities in your dynamic cloud environment.
*   **Security Compliance:** Helping organizations meet compliance requirements by continuously scanning for and reporting on vulnerabilities.
*   **Incident Prevention:** Proactively identifying security weaknesses that could be exploited by attackers.
*   **DevSecOps Integration:** Integrating vulnerability scanning directly into CI/CD pipelines for container images, enabling shift-left security.
*   **Optimizing Security Spend:** Focusing remediation efforts on the most critical vulnerabilities with the highest exploitability risk.
*   **Cloud Security Posture Management (CSPM):** A key component of a comprehensive CSPM strategy, focusing on runtime and image vulnerabilities.

Amazon Inspector provides automated and continuous vulnerability management, helping you maintain a strong security posture across your AWS workloads.
