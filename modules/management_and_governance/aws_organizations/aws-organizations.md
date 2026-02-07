# AWS Organizations

AWS Organizations helps you centrally govern your environment as you grow and scale your AWS resources. Using AWS Organizations, you can programmatically create new AWS accounts and allocate resources, group accounts to organize your workflows, apply policies to accounts or groups for centralized control, and simplify billing by paying for all accounts with a single consolidated bill.

## Core Concepts

*   **Centralized Management:** Manage multiple AWS accounts from a single dashboard.
*   **Consolidated Billing:** Combine the billing for all your accounts into one payment method.
*   **Hierarchical Structure:** Organize accounts into organizational units (OUs) to create a logical hierarchy that mirrors your business structure.
*   **Policy-based Management:** Apply policies to enforce controls across multiple accounts (e.g., security, compliance, cost management).

## Key Components and Configuration

### 1. Organization

*   **Root Account:** The AWS account that creates the organization becomes the management account. This account has full control over the organization.
*   **Member Accounts:** All other accounts in the organization are member accounts. They can be created within the organization or invited to join.
*   **Real-life Example:** Your company creates an organization with its main AWS account as the management account. They then invite existing departmental AWS accounts (e.g., marketing, engineering) to join the organization and create new accounts for development, testing, and production environments.

### 2. Organizational Units (OUs)

*   **Hierarchical Grouping:** OUs allow you to group accounts into a hierarchy that resembles your business structure. This enables you to apply policies to groups of accounts.
*   **Maximum Depth:** You can nest OUs up to five levels deep.
*   **Real-life Example:** You create OUs for `Development`, `Testing`, and `Production`. Within `Production`, you might have OUs for `Web Applications` and `Data Science`. Each OU contains relevant member accounts.

### 3. Policies

Organizations offers different types of policies that you can attach to the root, OUs, or individual accounts.

*   **Service Control Policies (SCPs):**
    *   **Purpose:** Allow you to centrally control the maximum available permissions for all accounts in your organization. They act as "guardrails" or "security boundaries."
    *   **Effect:** An SCP *does not grant permissions*; it *filters* or *restricts* them. If an action is explicitly denied by an SCP, no IAM policy can override that denial.
    *   **Default:** By default, a full access SCP is attached to the root, allowing all AWS services and actions.
    *   **Real-life Example:** You want to prevent any account in your `Development` OU from provisioning certain expensive EC2 instance types (e.g., `p3.xlarge`). You create an SCP that explicitly denies the `ec2:RunInstances` action for that specific instance type and attach it to the `Development` OU. Even if an IAM user in a dev account has an IAM policy that allows `RunInstances`, the SCP will override it.

*   **AI Services Opt-Out Policies:**
    *   **Purpose:** Allows you to control whether AI services in your organization can store content processed by those services.
    *   **Real-life Example:** For compliance reasons, you might want to opt out of data storage for certain AI services in specific accounts.

*   **Backup Policies:**
    *   **Purpose:** Allows you to centrally manage and enforce backup plans for your resources across all accounts in your organization.
    *   **Real-life Example:** You create a backup policy that requires all EC2 instances and RDS databases in your `Production` OU to have daily backups with a 30-day retention period.

*   **Tag Policies:**
    *   **Purpose:** Helps you standardize tagging across resources in your organization. You define rules for tag keys and values.
    *   **Real-life Example:** You create a tag policy that enforces a tag key `CostCenter` with allowed values like `IT`, `Marketing`, `HR`. Resources without this tag or with invalid values are flagged.

### 4. Consolidated Billing

*   **Single Payment:** All charges for all member accounts in an organization are consolidated into a single bill for the management account.
*   **Volume Discounts:** You benefit from volume pricing discounts and Reserved Instance/Savings Plans sharing across all accounts.
*   **Real-life Example:** Your company has 10 AWS accounts. Instead of managing 10 separate bills, you get one consolidated bill. The combined usage across accounts helps you achieve better pricing tiers for services like S3 or EC2.

### 5. Trusted Access

*   **Integration with AWS Services:** AWS Organizations can grant trusted access to other AWS services (e.g., AWS Config, AWS Security Hub, AWS Control Tower) to perform tasks on your behalf across all member accounts.
*   **Delegated Administrator:** For some services, you can delegate administrative privileges to a member account to manage that service for the organization.
*   **Real-life Example:** You enable trusted access for AWS Config. This allows Config to deploy and manage conformance packs across all accounts in your organization from a central account, ensuring compliance.

### 6. AWS Control Tower (Built on Organizations)

*   **Landing Zone Automation:** AWS Control Tower automates the setup of a well-architected multi-account AWS environment (a "landing zone") that is secure, well-governed, and based on best practices from AWS Organizations. (See `aws-control-tower.md`)

## Purpose and Real-Life Use Cases

*   **Account Management:** Creating, inviting, and managing all your AWS accounts from a central point.
*   **Centralized Governance and Security:** Enforcing security, compliance, and cost-management policies across your entire AWS environment using SCPs and other policies.
*   **Cost Optimization:** Leveraging consolidated billing and volume discounts across multiple accounts.
*   **Environment Standardization:** Ensuring that all new accounts and OUs adhere to a consistent set of configurations and policies.
*   **Sandbox Environments:** Quickly creating and managing isolated sandbox accounts for developers to experiment, with SCPs to prevent unintended resource creation or excessive spending.
*   **Multi-Region and Multi-Account Strategy:** A foundational service for designing robust, secure, and scalable multi-account AWS architectures.

AWS Organizations is a critical service for any organization that operates more than a few AWS accounts, providing the tools needed for efficient and secure management at scale.
