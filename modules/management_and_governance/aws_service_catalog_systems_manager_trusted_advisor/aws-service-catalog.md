# AWS Service Catalog

AWS Service Catalog allows organizations to create and manage catalogs of IT services that are approved for use on AWS. These IT services can include everything from virtual machine images, servers, software, and databases to complete multi-tier application architectures. Service Catalog gives administrators centralized control of the IT services they want to offer, and helps users quickly deploy only the approved IT services they need.

## Core Concepts

*   **Self-Service Portal:** Provides a web-based portal for end-users (developers, data scientists, etc.) to browse and launch approved AWS resources.
*   **Centralized Governance:** Allows administrators to define, manage, and govern the AWS resources that users can deploy. This ensures compliance, security, and adherence to best practices.
*   **Standardization:** Promotes the use of standardized, pre-configured infrastructure templates.
*   **Version Control:** Allows administrators to manage multiple versions of a product, making it easy to update or roll back to previous versions.

## Key Components and Configuration

### 1. Portfolios

*   **Collections of Products:** A portfolio is a collection of products, along with configuration information. You can create different portfolios for different user groups or departments.
*   **Access Control:** You grant access to portfolios to specific IAM users, groups, or roles.
*   **Constraint Templates:** Administrators can apply constraints to portfolios or products within a portfolio to enforce architectural, security, or operational standards.
*   **Real-life Example:** You create a "Developer Portfolio" that contains products like "Dev EC2 Instance," "Dev RDS Database," and "Web App Stack." You grant your `Developers` IAM group access to this portfolio.

### 2. Products

*   **IT Services:** A product is an IT service that you want to make available to end-users. It's defined by an AWS CloudFormation template (or other providers like Terraform).
*   **Configuration:** A product definition includes the CloudFormation template, product name, description, owner, and support information.
*   **Version Management:** You can create multiple versions of a product. Each version points to a specific CloudFormation template.
*   **Real-life Example:**
    *   **Product:** "Linux Web Server"
    *   **Version 1:** Uses a CloudFormation template that launches an EC2 `t3.micro` instance with Apache pre-installed.
    *   **Version 2:** Uses an updated CloudFormation template that launches an EC2 `m5.large` instance with Nginx and a more recent Linux AMI.

### 3. Provisioned Products

*   **Deployed Instances:** A provisioned product is an instance of a product that has been launched by an end-user.
*   **Management:** Service Catalog maintains a record of all provisioned products, including the user who launched them, the product version used, and the CloudFormation stack ID.

### 4. Constraints

Constraints provide administrators with fine-grained control over how products can be deployed. They enforce governance and compliance.

*   **Launch Constraints:**
    *   **Purpose:** Allow end-users to launch products using an IAM role that you specify, rather than their own permissions. This ensures that users don't need direct permissions to the underlying AWS resources, but rather only permission to launch the product.
    *   **Real-life Example:** Your developers only have permission to access the Service Catalog. When they launch the "Dev RDS Database" product, Service Catalog assumes a pre-defined `ServiceCatalogLaunchRole` that has permissions to create RDS instances, subnets, and security groups.
*   **Template Constraints:**
    *   **Purpose:** Define rules that govern the parameter values that end-users can input when launching a product.
    *   **Real-life Example:** For a "Web Server" product, you might use a template constraint to ensure that the `InstanceType` parameter can only be `t3.medium` or `t3.large`, preventing users from launching expensive instance types.
*   **Notification Constraints:**
    *   **Purpose:** Send notifications to an Amazon SNS topic when certain events occur (e.g., product launch, update, termination).
*   **TagOption Constraints:**
    *   **Purpose:** Enforce consistent tagging on resources provisioned through Service Catalog.
    *   **Real-life Example:** Automatically apply `CostCenter:Development` and `Environment:Dev` tags to all resources launched from the "Developer Portfolio".

### 5. Access and Permissions

*   **IAM Integration:** Service Catalog heavily relies on IAM for defining who can access portfolios, launch products, and manage the catalog.
*   **Administrator Role:** IAM users/roles who manage portfolios, products, and constraints.
*   **End-User Role:** IAM users/roles who can browse portfolios and launch provisioned products.

### 6. CloudFormation Integration

*   **Underlying Engine:** AWS CloudFormation is the primary engine used by Service Catalog to provision and manage AWS resources defined in product templates.
*   **Benefits:** This leverages the power of CloudFormation for declarative infrastructure management, version control, and drift detection.

## Purpose and Real-Life Use Cases

*   **Centralized IT Governance:** Allowing central IT teams to define and control the types of AWS resources that can be deployed by various departments or projects.
*   **Self-Service Provisioning:** Empowering development teams, data scientists, or other end-users to provision the resources they need quickly and independently, without manual IT intervention.
*   **Compliance and Security:** Enforcing security standards and compliance requirements by only offering pre-approved and configured services.
*   **Cost Management:** Controlling costs by limiting the types and configurations of resources that can be launched and enforcing tagging for cost allocation.
*   **Standardization:** Promoting the use of consistent and tested infrastructure patterns across the organization.
*   **Onboarding New Teams/Projects:** Quickly providing new teams with a baseline set of pre-configured resources.
*   **Cloud Cost Control:** Preventing users from launching overly expensive resources or non-compliant configurations.

AWS Service Catalog is particularly useful for larger organizations that need to balance developer agility with centralized governance and control over their AWS environment.
