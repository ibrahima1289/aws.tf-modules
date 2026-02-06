# AWS Identity and Access Management (IAM)

AWS Identity and Access Management (IAM) is a web service that helps you securely control access to AWS resources. With IAM, you manage who is authenticated (signed in) and authorized (has permissions) to use resources.

## Core Concepts

*   **Centralized Control:** Manage users, groups, roles, and their permissions for accessing AWS services and resources.
*   **Granular Permissions:** Define highly specific permissions (e.g., allow read-only access to a specific S3 bucket).
*   **Shared Responsibility Model:** While AWS secures the underlying infrastructure, you are responsible for managing access to your resources using IAM.
*   **No Cost:** IAM is a feature of your AWS account offered at no additional charge.

## Key Components and Configuration

### 1. Users

*   **IAM User:** An entity that you create in AWS to represent the person or service that interacts with AWS. An IAM user consists of a name, password (for console access), and access keys (for programmatic access via CLI/SDK).
*   **Root User:** The account owner. It has full administrative access and should be used only for initial setup or very specific tasks that require root privileges. Best practice is to secure the root user with MFA and store its credentials securely.

### 2. Groups

*   **Collection of Users:** An IAM group is a collection of IAM users. You can attach policies to a group, and all users in the group inherit those permissions.
*   **Best Practice:** Instead of attaching policies directly to individual users, it's generally recommended to assign permissions to groups and then add users to the appropriate groups.
*   **Real-life Example:** You create a `Developers` group with policies that allow them to launch EC2 instances and deploy code. You create an `Auditors` group with policies that allow read-only access to various AWS services.

### 3. Roles

*   **Temporary Permissions:** An IAM role is an IAM identity that you can create in your account that has specific permissions. IAM roles are meant to be assumed by trusted entities (IAM users, applications running on EC2, other AWS services, or external users).
*   **No Credentials:** A role has no standard long-term credentials (password or access keys) associated with it. When an entity assumes a role, it receives temporary security credentials.
*   **Trust Policy:** Defines *who* can assume the role.
*   **Permissions Policy:** Defines *what* the role can do after it's assumed.
*   **Real-life Examples:**
    *   **EC2 Instance Role:** An EC2 instance needs to read from an S3 bucket. You create an IAM role with S3 read permissions and attach it to the EC2 instance. The applications running on that instance automatically inherit those permissions.
    *   **Cross-Account Access:** You need to grant a third-party auditor access to your AWS account. You create a role in your account that allows the auditor's AWS account to assume it.
    *   **AWS Service Role:** An AWS Lambda function needs to write logs to CloudWatch. You create a role that grants CloudWatch write permissions and assign it to the Lambda function.

### 4. Policies

*   **Documents of Permissions:** An IAM policy is an object in AWS that, when associated with an identity or resource, defines their permissions.
*   **JSON Format:** Policies are written in JSON and specify `Actions` (what can be done), `Resources` (on what can it be done), and `Effects` (Allow or Deny).
*   **Types of Policies:**
    *   **Managed Policies:**
        *   **AWS Managed Policies:** Created and managed by AWS (e.g., `AmazonS3ReadOnlyAccess`). You cannot edit these.
        *   **Customer Managed Policies:** You create and manage these policies yourself. They are reusable and can be attached to multiple entities.
    *   **Inline Policies:** Policies that are embedded directly into a single user, group, or role. They are deleted when the identity is deleted.
*   **Access Policy Evaluation Logic:**
    1.  By default, all requests are denied.
    2.  If an explicit `Allow` is present, the request is allowed.
    3.  If an explicit `Deny` is present, the request is denied (even if an `Allow` is also present—`Deny` always overrides `Allow`).
*   **Best Practice:** Always apply the **Principle of Least Privilege**, which means granting only the permissions required to perform a task.

### 5. Multi-Factor Authentication (MFA)

*   **Added Security:** MFA adds an extra layer of security on top of a username and password. When enabled, users must provide their credentials and a one-time code from an MFA device.
*   **Types:** Virtual MFA (e.g., Google Authenticator), U2F security keys (e.g., YubiKey), hardware MFA devices.
*   **Best Practice:** Enable MFA for your AWS root account and for all IAM users with administrative privileges.

### 6. Access Keys

*   **Programmatic Access:** Consists of an access key ID and a secret access key. Used for making programmatic calls to AWS (via CLI, SDK, or API).
*   **Best Practice:**
    *   Do not embed access keys directly in your code.
    *   Rotate access keys regularly.
    *   Remove or disable unused access keys.
    *   Use IAM roles for EC2 instances and other AWS services instead of distributing access keys.

## Purpose and Real-Life Use Cases

*   **Secure Access to AWS Resources:** The fundamental service for controlling who can do what in your AWS account.
*   **Compliance:** Meeting security compliance requirements by enforcing strong access controls and audit trails.
*   **Delegating Permissions:** Granting temporary access to third-party services or auditors without sharing your root account credentials.
*   **Automating Tasks:** Assigning specific permissions to automated scripts or applications running on AWS.
*   **Federated Access:** Integrating with corporate directories (like Active Directory) to allow users to sign into AWS using their existing corporate credentials.

IAM is a critical service for securing your AWS environment. Proper configuration of IAM users, groups, roles, and policies is essential for maintaining a strong security posture.
