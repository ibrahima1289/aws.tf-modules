# AWS Detective

AWS Detective is a security service that automatically collects log data from your AWS resources and uses machine learning, statistical analysis, and graph theory to build a linked set of data that enables easier, faster, and more efficient security investigations. It provides a unified, interactive view of resource behaviors and interactions over time, helping security analysts investigate or quickly pinpoint the root cause of security findings from services like Amazon GuardDuty.

## Core Concepts

*   **Security Investigation Service:** Detective is purpose-built to help security analysts conduct efficient investigations into potential security issues.
*   **Graph Database:** It uses a graph database to create a unified view of behaviors and interactions across your AWS accounts, users, and resources.
*   **Machine Learning and Analytics:** Applies ML and statistical analysis to automatically identify suspicious activity.
*   **Automated Data Ingestion:** Automatically ingests and processes security-related logs from various AWS sources.
*   **Integrated with GuardDuty:** Works seamlessly with Amazon GuardDuty findings to provide rich context for investigations.

## Key Components and Configuration

### 1. Behavior Graph

*   **Purpose:** The central component of Detective. It continuously extracts time-based events from ingested log data and uses them to create a master set of data (a "behavior graph") that represents the entire activity in your AWS accounts.
*   **Data Sources:** Detective automatically ingests:
    *   **AWS CloudTrail Management Events:** API calls, user activities.
    *   **Amazon VPC Flow Logs:** Network traffic information.
    *   **Amazon GuardDuty Findings:** Threat detection alerts.
    *   **AWS Security Hub Findings:** Security alerts.
*   **Real-life Example:** The behavior graph links IAM users to the EC2 instances they launched, the IP addresses they connected from, the S3 buckets they accessed, and any GuardDuty findings related to those activities.

### 2. Enabling Detective

*   **Master Account:** In an AWS Organizations setup, one account is designated as the master account for Detective. This account can invite other member accounts.
*   **Data Ingestion:** Once enabled, Detective automatically begins ingesting data from the specified data sources across all enabled member accounts.
*   **Real-life Example:** Your security team enables Detective in your central security account (master account). They then invite your development, staging, and production accounts to become member accounts. Detective starts collecting and analyzing logs from all these accounts.

### 3. Analytics and Visualization

*   **Interactive Visualizations:** Detective provides interactive visualizations within the console that help you explore the behavior graph.
    *   **Summary Pages:** Provide a high-level overview of entities (IAM users, roles, EC2 instances, IP addresses) and their key statistics.
    *   **Profile Panels:** Offer detailed, contextual information about an entity over a customizable time range. These panels display:
        *   **Activity Volume:** How much activity an entity has generated.
        *   **Geolocation:** Where activities originated.
        *   **API Call History:** Specific API calls made by a user or on an instance.
        *   **Network Traffic:** Inbound/outbound traffic details for an instance.
        *   **GuardDuty Findings:** Any related GuardDuty findings.
*   **Time-based Analysis:** You can adjust the time window for your investigation, allowing you to focus on specific periods of interest.
*   **Scoped Graph:** For a GuardDuty finding, Detective automatically scopes the behavior graph to the entities and activities relevant to that specific finding.

### 4. Integration with Amazon GuardDuty

*   **Enhanced Investigation:** When a GuardDuty finding is generated (e.g., `UnauthorizedAccess:EC2/SSHBruteForce`), you can pivot directly from the GuardDuty console to Detective.
*   **Contextual Details:** Detective then provides a rich, interactive view of all related activities, such as:
    *   The EC2 instance involved and its normal network activity.
    *   The IAM user/role associated with the instance.
    *   All IP addresses that attempted to connect via SSH.
    *   Other API calls made by the user around the time of the brute-force attempt.
*   **Real-life Example:** GuardDuty alerts you to an SSH brute-force attack on an EC2 instance. You click a link in the GuardDuty finding, which takes you directly to Detective. Detective shows you the instance's typical SSH login patterns, highlights the anomalous login attempts, and lets you quickly see if any other unusual activities (like data exfiltration to S3) occurred from that instance or the associated user around the same time.

### 5. Integration with AWS Security Hub

*   **Finding Enrichment:** Detective enriches Security Hub findings with contextual data, helping security analysts prioritize and investigate issues more effectively.

## Purpose and Real-life Use Cases

*   **Security Incident Response:** Rapidly investigate potential security incidents by quickly understanding the scope and root cause of a finding.
*   **Threat Hunting:** Proactively search for suspicious activities that might not have triggered a specific alert.
*   **Forensics:** Gather detailed evidence of what happened during a security event.
*   **Compliance and Auditing:** Generate reports on user activity and resource interactions for audit purposes.
*   **Cloud Security Posture Management (CSPM):** Complementing CSPM tools by providing deeper investigative capabilities when a misconfiguration is detected.
*   **Root Cause Analysis:** Go beyond simple alerts to understand the full chain of events leading to a security issue.

AWS Detective empowers security analysts to move beyond basic alert triage, providing the tools needed to conduct thorough and efficient security investigations across their entire AWS environment.
