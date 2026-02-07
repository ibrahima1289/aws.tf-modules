# AWS Trusted Advisor

AWS Trusted Advisor is an online tool that provides you with real-time guidance to help you provision your resources following AWS best practices. It inspects your AWS environment and makes recommendations across five categories (or "pillars") to help you reduce costs, improve system performance and reliability, close security gaps, and operate more efficiently.

## Core Concepts

*   **Proactive Guidance:** Continuously scans your AWS environment and provides actionable recommendations.
*   **Best Practice Adherence:** Helps you align your AWS infrastructure with the AWS Well-Architected Framework.
*   **Five Pillar Categories:** Recommendations are categorized into Cost Optimization, Performance, Security, Fault Tolerance (Reliability), and Service Limits.
*   **Subscription Levels:** Offers different levels of checks and features depending on your AWS Support plan (Basic, Developer, Business, Enterprise).

## Key Categories and Configuration (Checks)

Trusted Advisor performs a series of checks and provides a status (Green: No issues detected, Yellow: Investigation recommended, Red: Action recommended).

### 1. Cost Optimization

*   **Purpose:** Helps you save money by identifying unused or under-utilized resources and recommending cost-saving opportunities.
*   **Checks:**
    *   **Low Utilization Amazon EC2 Instances:** Identifies EC2 instances that have been running at low CPU or network utilization for an extended period.
        *   **Real-life Example:** Trusted Advisor flags several `m5.large` EC2 instances that are consistently running at less than 10% CPU utilization. It recommends downgrading them to `t3.small` instances or even shutting them down if they're not needed, leading to significant cost savings.
    *   **Idle Load Balancers:** Detects Elastic Load Balancers that are receiving little or no traffic.
    *   **Unassociated Elastic IP Addresses:** Flags Elastic IP addresses that are not currently associated with a running instance (which incur a small hourly charge).
    *   **Underutilized Amazon EBS Volumes:** Identifies EBS volumes with low read/write activity.

### 2. Performance

*   **Purpose:** Helps improve the responsiveness and throughput of your applications by identifying bottlenecks and optimizing resource configurations.
*   **Checks:**
    *   **High Utilization Amazon EC2 Instances:** Identifies EC2 instances running at high CPU utilization, potentially indicating a need to scale up or out.
    *   **Amazon EBS Provisioned IOPS (SSD) Volume Throughput Optimization:** Checks if your `io1`/`io2` volumes are properly utilized.
    *   **Amazon EC2 to Amazon EBS Throughput Optimization:** Suggests optimizations for network performance between EC2 and EBS.
    *   **Amazon CloudFront CDN Optimization:** Recommends settings for CloudFront distributions.
        *   **Real-life Example:** Trusted Advisor notices an EC2 instance consistently running at 90% CPU. It suggests upgrading the instance type or adding more instances via Auto Scaling to improve application performance.

### 3. Security

*   **Purpose:** Helps improve the overall security posture of your AWS environment by identifying security misconfigurations and vulnerabilities.
*   **Checks:**
    *   **Security Groups - Specific Ports Unrestricted:** Flags security groups that have overly permissive inbound rules (e.g., SSH port 22 open to `0.0.0.0/0`).
        *   **Real-life Example:** Trusted Advisor warns that your database server's security group allows inbound access on port 3306 from `0.0.0.0/0`. It recommends restricting this to only your application server's security group or specific IP ranges.
    *   **MFA on Root Account:** Checks if Multi-Factor Authentication (MFA) is enabled for your AWS root account (critical security best practice).
    *   **IAM Access Key Rotation:** Recommends regular rotation of IAM user access keys.
    *   **Exposed Access Keys:** Detects if any access keys have been exposed publicly (e.g., committed to a public GitHub repository).
    *   **S3 Bucket Permissions:** Checks for S3 buckets that are publicly accessible.

### 4. Fault Tolerance (Reliability)

*   **Purpose:** Helps improve the reliability and resilience of your applications by identifying potential points of failure and recommending actions to ensure high availability.
*   **Checks:**
    *   **Amazon EC2 Availability Zone Balance:** Identifies Auto Scaling groups that are not distributing instances evenly across Availability Zones.
        *   **Real-life Example:** Trusted Advisor points out that your Auto Scaling group with 6 instances has all of them running in `us-east-1a`, making your application vulnerable to an AZ outage. It recommends reconfiguring the ASG to distribute instances across at least two AZs.
    *   **Amazon RDS Multi-AZ:** Checks if your RDS instances are configured for Multi-AZ deployment.
    *   **Load Balancer Optimization:** Recommends enabling cross-zone load balancing for Elastic Load Balancers.
    *   **EBS Snapshots:** Checks for EBS volumes that have not been backed up with snapshots recently.
    *   **Service Limit Exceeded:** Flags when you are approaching or have exceeded AWS service limits.

### 5. Service Limits

*   **Purpose:** Helps you stay within AWS service limits by identifying when your usage is approaching or has exceeded a soft limit, preventing service disruptions.
*   **Checks:** Monitors usage for various services (e.g., EC2 instances, EBS volumes, VPCs) against your account's service limits.
*   **Real-life Example:** Trusted Advisor warns that you are approaching the default limit of 20 EC2 instances per region. It suggests requesting a service limit increase from AWS Support to prevent future launch failures.

## Trusted Advisor with AWS Organizations

If you use AWS Organizations, you can enable Trusted Advisor for all accounts in your organization, allowing you to centrally monitor best practice adherence across your entire AWS estate.

## Purpose and Real-Life Use Cases

*   **Cost Savings:** Identifying opportunities to reduce your AWS bill by optimizing resource usage.
*   **Improved Performance:** Pinpointing performance bottlenecks and suggesting ways to improve application responsiveness.
*   **Enhanced Security Posture:** Highlighting security vulnerabilities and misconfigurations that could expose your data or systems.
*   **Increased Reliability:** Recommending architectures and configurations that improve the fault tolerance and uptime of your applications.
*   **Proactive Operations:** Staying ahead of potential issues like service limit breaches before they impact your operations.
*   **Compliance Support:** Helping organizations adhere to best practices that contribute to various compliance frameworks.

Trusted Advisor acts as your "cloud expert," continuously scanning your environment and providing personalized recommendations to help you run your AWS workloads effectively.
