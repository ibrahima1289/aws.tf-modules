# AWS Config

AWS Config is a service that enables you to assess, audit, and evaluate the configurations of your AWS resources. Config continuously monitors and records your AWS resource configurations and allows you to automate the evaluation of recorded configurations against desired configurations. This helps in compliance auditing, security analysis, change management, and operational troubleshooting.

## Core Concepts

*   **Configuration Recorder:** Continuously tracks changes to your AWS resource configurations.
*   **Configuration History:** Maintains a complete history of how your AWS resources were configured at any point in time.
*   **Configuration Items (CIs):** A point-in-time snapshot of the various attributes of a supported AWS resource.
*   **Compliance Rules:** Allows you to define desired configurations and automatically evaluate whether your resources comply.
*   **Change Tracking:** Provides visibility into who changed what, when, and how, facilitating auditing and troubleshooting.

## Key Components and Configuration

### 1. Configuration Recorder

*   **Purpose:** The Configuration Recorder records configuration changes for supported resources in your AWS account and delivers them to an S3 bucket and an SNS topic.
*   **Supported Resources:** You can choose to record all supported resource types (recommended) or specify a subset of resource types.
*   **Global Resources:** You can choose to include global resources (IAM resources, CloudFront distributions) in your recording. It's recommended to have one recorder in one region (e.g., `us-east-1`) for global resources.
*   **Delivery Channels:**
    *   **S3 Bucket:** Stores the full configuration history and configuration snapshots.
    *   **SNS Topic:** Sends notifications when a configuration change is detected.
*   **Real-life Example:** You enable the Configuration Recorder for your AWS account. It starts tracking every change made to your EC2 instances, S3 buckets, security groups, RDS databases, etc., and stores this history in an S3 bucket.

### 2. AWS Config Rules

*   **Purpose:** Config rules represent your desired configuration settings for your AWS resources. They continuously evaluate the configuration items recorded by the Configuration Recorder against your specified conditions.
*   **Types of Rules:**
    *   **Managed Rules:** Pre-defined, customizable rules created by AWS. There are hundreds of managed rules for common use cases (e.g., check if S3 buckets are public, check if EC2 instances use encrypted EBS volumes, check if MFA is enabled for the root account).
        *   **Real-life Example:** You enable the `s3-bucket-public-read-prohibited` managed rule to ensure none of your S3 buckets are publicly readable. If a bucket's policy changes to allow public read access, AWS Config will flag it as non-compliant.
    *   **Custom Rules (Lambda-backed):** You write your own AWS Lambda function to implement custom logic for evaluating resource configurations.
        *   **Real-life Example:** You have a custom tagging standard (e.g., all resources must have a `Project` tag and a `Owner` tag). You can write a Lambda function to check for this and deploy it as a custom Config rule.
*   **Evaluation Frequency:**
    *   **Triggered on Change:** Rules are automatically evaluated whenever a relevant resource's configuration changes.
    *   **Periodic:** Rules are evaluated at a defined interval (e.g., every 24 hours).
*   **Compliance Status:** For each rule, AWS Config reports whether a resource is `COMPLIANT` or `NON_COMPLIANT`.

### 3. Conformance Packs

*   **Purpose:** A collection of AWS Config rules and remediation actions that can be easily deployed as a single entity in your account or across an organization.
*   **Templates:** Conformance Packs are deployed using CloudFormation templates.
*   **Use Cases:** Automating compliance checks for specific industry standards (e.g., PCI DSS, HIPAA) or internal company policies.
*   **Real-life Example:** You deploy the "Operational Best Practices for AWS" conformance pack across your entire AWS Organization. This automatically sets up a collection of Config rules to check for common security and operational best practices, giving you a quick overview of your organizational compliance.

### 4. Remediation Actions

*   **Purpose:** Automate the process of fixing non-compliant resources.
*   **Integration with Systems Manager:** Config rules can trigger AWS Systems Manager Automation documents to automatically remediate non-compliant resources.
*   **Real-life Example:** You have a Config rule that checks if EC2 instances have an SSH port open to `0.0.0.0/0`. If an instance is found non-compliant, you can configure an automatic remediation action that triggers an AWS Systems Manager Automation document to modify the security group to restrict SSH access to a safer IP range.

### 5. Aggregators

*   **Purpose:** Consolidate configuration and compliance data from multiple AWS accounts and multiple Regions into a single view.
*   **Use Cases:** For organizations with multi-account AWS environments (managed by AWS Organizations) or applications deployed in multiple regions.
*   **Real-life Example:** Your company has separate AWS accounts for dev, test, and prod. You set up a Config aggregator in your central security account that pulls Config data from all these accounts and all regions, giving your security team a unified compliance dashboard.

## Purpose and Real-Life Use Cases

*   **Compliance Auditing:** Automatically audit your AWS environment against internal policies or external regulations (e.g., PCI DSS, HIPAA, GDPR).
*   **Security Analysis:** Identifying security vulnerabilities and misconfigurations (e.g., publicly accessible S3 buckets, over-permissive security groups).
*   **Change Management:** Tracking all changes to your AWS resources, providing an audit trail for who, what, and when changes occurred.
*   **Operational Troubleshooting:** Diagnosing operational issues by reviewing the configuration history of a resource to identify recent changes.
*   **Continuous Governance:** Enforcing desired configurations across your AWS environment through automated rules and remediation actions.
*   **DevOps Best Practices:** Integrating compliance checks into CI/CD pipelines to ensure that only compliant resources are deployed.

AWS Config is an essential service for maintaining continuous governance, compliance, and operational best practices in your AWS environment.
