# AWS Directory Service

AWS Directory Service is a managed service that allows you to connect your AWS resources to an existing on-premises Microsoft Active Directory, or to set up a new, standalone directory in the AWS Cloud. It provides a highly available and scalable directory service without the need to deploy and manage domain controllers yourself.

## Core Concepts

*   **Managed Directory:** AWS manages the underlying infrastructure (domain controllers, DNS, hardware provisioning, software patching, and monitoring) for your directory.
*   **Identity and Access Management:** Provides a centralized directory for users, groups, and devices, enabling single sign-on (SSO) and access control for applications.
*   **Multiple Directory Types:** Offers various directory types to suit different use cases and integration needs.

## Key Directory Types and Configuration

### 1. AWS Managed Microsoft AD

*   **Purpose:** A fully managed, highly available Microsoft Active Directory (AD) hosted by AWS. It provides real Microsoft Active Directory features as a managed service.
*   **Functionality:** Supports standard AD features like Group Policy, trusts, LDAP, Kerberos, DNS, and integrates with on-premises AD via AD Connector.
*   **Deployment:** Deploys highly available domain controllers across multiple Availability Zones in your VPC.
*   **Trusts:** Can establish a trust relationship (one-way or two-way) with your on-premises AD, allowing users to authenticate to AWS resources using their existing corporate credentials.
*   **Real-life Example:** Your company has an on-premises Active Directory. You deploy AWS Managed Microsoft AD in your VPC and establish a two-way trust with your on-premises AD. Now, your EC2 instances joined to the AWS Managed AD can authenticate users from your on-premises AD, and users can sign in to AWS applications using their corporate credentials.

### 2. AD Connector

*   **Purpose:** A proxy service that connects your AWS resources directly to your existing on-premises Microsoft Active Directory. It does not store any user information in the AWS Cloud.
*   **Functionality:** Allows your on-premises users to access AWS applications and resources using their existing AD credentials, without synchronizing directories or establishing complex trust relationships.
*   **Deployment:** Deploys highly available connectors across multiple Availability Zones in your VPC.
*   **Real-life Example:** Your users are all managed by your on-premises AD. You deploy an AD Connector to authenticate users to applications running on EC2 instances in your VPC, or to allow them to access AWS services integrated with Directory Service (e.g., AWS WorkSpaces).

### 3. Simple AD

*   **Purpose:** A low-cost, managed directory that is compatible with Active Directory and LDAP. It's built on a Samba 4 Active Directory Compatible Server.
*   **Functionality:** Basic Active Directory features, user and group management, supports EC2 instance domain join.
*   **Limitations:** Does not support advanced AD features like trusts, multi-factor authentication (MFA), or Group Policy.
*   **Deployment:** Available in two sizes: Small (for up to 500 users) and Large (for up to 5,000 users).
*   **Real-life Example:** You need a simple, inexpensive directory for a small development environment or for testing applications that require LDAP authentication, but you don't need full Microsoft AD functionality.

### 4. AWS Managed Microsoft AD (Multi-Region Replication)

*   **Purpose:** Extends your AWS Managed Microsoft AD to multiple AWS Regions, providing improved resilience and performance for globally distributed applications and users.
*   **Functionality:** Automatically replicates your directory across chosen Regions. Users in a given Region authenticate against the local domain controllers, reducing latency.
*   **Real-life Example:** Your company has employees and applications in `us-east-1` and `eu-west-1`. You set up a multi-region AWS Managed Microsoft AD. Users in Europe can authenticate against the directory in `eu-west-1`, providing a faster and more reliable experience.

## Key Configuration Options (General)

### 1. VPC and Subnets

*   **Placement:** All AWS Directory Service instances are deployed into private subnets within your VPC for security.
*   **High Availability:** For high availability, you must select at least two subnets in different Availability Zones.

### 2. Size/Edition

*   **Varies by Type:** Dependent on the directory type, this determines the capacity (e.g., number of users) and features available.

### 3. Password Policies

*   **Enforcement:** You can configure password policies for users within your managed directories (e.g., minimum length, complexity requirements, expiration).

### 4. Integration with AWS Services

*   **Amazon EC2:** Join EC2 instances to the directory domain.
*   **Amazon RDS:** Authenticate users to Microsoft SQL Server RDS instances.
*   **AWS WorkSpaces:** Provide managed virtual desktops where users authenticate with the directory.
*   **AWS Single Sign-On (SSO) / IAM Identity Center:** Integrate with managed AD for centralized access to AWS accounts and applications.
*   **Amazon Connect:** For contact center user management.
*   **Amazon FSx for Windows File Server:** Provide fully managed Windows file shares with AD authentication.
*   **AWS Transfer Family:** Authenticate users for SFTP/FTPS/FTP access.

### 5. DNS Configuration

*   **Custom DNS Servers:** AWS Directory Service automatically configures DNS for your domain. Your VPC must use the DNS servers provided by the directory service for domain resolution.

## Purpose and Real-life Use Cases

*   **Single Sign-On (SSO):** Enabling users to use their existing corporate credentials to access AWS applications and services.
*   **Active Directory Integration:** Connecting AWS resources (e.g., EC2 instances, WorkSpaces, FSx) to an on-premises or AWS-managed Active Directory.
*   **Centralized User Management:** Managing users and groups in a single directory for access control.
*   **Compliance:** Meeting compliance requirements that mandate the use of Active Directory for identity management.
*   **Hybrid Cloud Identity:** Extending your on-premises identity infrastructure to the AWS Cloud seamlessly.
*   **Application Authentication:** Providing an authentication source for custom applications that use LDAP or Active Directory.

AWS Directory Service simplifies the management of user identities and access control, enabling seamless integration between your AWS resources and existing or new directory services.
