# AWS Control Tower

AWS Control Tower is a service that provides an easy way to set up and govern a secure, multi-account AWS environment (often referred to as a "landing zone"). It automates the setup of core accounts, establishes guardrails, and provides ongoing governance and compliance monitoring based on best practices from AWS Organizations and the AWS Well-Architected Framework.

## Core Concepts

*   **Landing Zone Automation:** Automates the complex process of setting up a multi-account AWS environment with centralized logging, security, and networking.
*   **Preventative and Detective Guardrails:** Implements rules to prevent resource deployments that violate policies and detects when non-compliant resources are created.
*   **Centralized Governance:** Provides a dashboard to monitor your AWS environment's compliance status and manage accounts.
*   **Built on AWS Organizations:** Leverages AWS Organizations to manage and provision accounts, applying policies across them.

## Key Components and Configuration

### 1. Core Accounts (Provisioned during Landing Zone Setup)

*   **Management Account:** The primary account for managing your Control Tower setup, including billing for all accounts in the organization.
*   **Log Archive Account:** A dedicated account for storing all AWS CloudTrail and AWS Config logs from all accounts in the organization. This centralizes audit trails.
*   **Audit Account:** A dedicated account for security and compliance teams to access logs and perform audits. It is restricted from making changes to the Log Archive account.

### 2. Organizational Units (OUs)

Control Tower establishes a default OU structure within your AWS Organization.

*   **Root OU:** The top-level OU that contains all other OUs.
*   **Core OU:** Contains the `Log Archive` and `Audit` accounts.
*   **Custom OUs:** You can create additional OUs for different departments, projects, or environments (e.g., `Sandbox`, `Development`, `Production`).
*   **Real-life Example:** After setting up Control Tower, you create a new `Development` OU for your dev teams and a `Production` OU for your production applications.

### 3. Guardrails

Guardrails are high-level rules that enforce policies and best practices across your AWS environment. Control Tower uses two types of guardrails:

*   **Preventative Guardrails:**
    *   **Purpose:** Prevent actions that would lead to policy violations. Implemented using Service Control Policies (SCPs) from AWS Organizations.
    *   **Enforcement:** Actively block non-compliant resource deployments.
    *   **Real-life Example:** A preventative guardrail could block all accounts in the `Development` OU from disabling CloudTrail logging, ensuring that all actions are always audited. Another might prevent the creation of public S3 buckets outside the `Sandbox` OU.
*   **Detective Guardrails:**
    *   **Purpose:** Detect when resources become non-compliant with your policies and alert you. Implemented using AWS Config rules.
    *   **Enforcement:** Alerts you to non-compliance, but does not block the action.
    *   **Real-life Example:** A detective guardrail might detect if an EC2 instance is launched without an associated IAM role, and then send a notification to the audit account.

*   **Guardrail Status:** Guardrails can be either `Mandatory` (applied to all OUs, cannot be removed), `Strongly Recommended` (can be opted out), or `Optional` (you choose which OUs to apply them to).

### 4. Account Factory

*   **Purpose:** A self-service portal within Control Tower that allows you to provision new AWS accounts that are pre-configured with your organization's guardrails, network settings, and logging capabilities.
*   **Automation:** Automates the creation of new accounts, ensuring they adhere to your landing zone standards.
*   **Customization:** You can define a blueprint for new accounts, specifying network configurations, security settings, and initial IAM roles.
*   **Real-life Example:** A developer needs a new AWS account for a proof-of-concept project. They use the Account Factory to provision a new `Sandbox` account. Control Tower automatically sets up the account, enrolls it in your AWS Organization, applies relevant guardrails, and configures logging to your central `Log Archive` account.

### 5. Centralized Logging and Monitoring

*   **CloudTrail and Config:** Control Tower automatically configures AWS CloudTrail and AWS Config across all enrolled accounts, centralizing logs and configuration history in the `Log Archive` account.
*   **CloudWatch:** Metrics and alarms are configured in CloudWatch to monitor the health and compliance of your landing zone.
*   **Security Hub Integration:** Control Tower integrates with AWS Security Hub to provide a consolidated view of security findings across your accounts.

### 6. Integration with AWS Single Sign-On (SSO)

*   **Identity Management:** Control Tower integrates with AWS IAM Identity Center (successor to AWS SSO) to provide centralized identity management and single sign-on access to all accounts in your organization.
*   **User Provisioning:** You can configure IAM Identity Center to provision users and groups from your existing identity source (e.g., Active Directory, Okta).
*   **Real-life Example:** Users can log in once to a central portal and then access any AWS account they have permissions for, without needing separate credentials for each account.

## Purpose and Real-Life Use Cases

*   **Establishing a Secure Landing Zone:** Automating the foundational setup of a secure, compliant, and well-governed multi-account AWS environment.
*   **Centralized Governance:** Maintaining consistent policies, security controls, and compliance across a growing number of AWS accounts.
*   **Accelerated Account Provisioning:** Rapidly creating new AWS accounts that conform to your organizational standards.
*   **Compliance Automation:** Continuously monitoring your environment against guardrails and reporting on compliance status.
*   **Reducing Operational Overhead:** Automating many of the complex, repetitive tasks associated with managing a multi-account AWS environment.
*   **Enterprise Adoption of AWS:** Providing a simplified way for large organizations to adopt and scale their use of AWS while maintaining control and security.

AWS Control Tower is an ideal solution for organizations that need to quickly set up a multi-account AWS environment with built-in governance, security, and best practices.
