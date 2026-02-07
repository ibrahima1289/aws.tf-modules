# AWS Verified Permissions

AWS Verified Permissions is a scalable, fine-grained permissions management service for custom applications. It allows developers to centralize and manage access policies for their application's users and resources, using a new open-source policy language called Cedar. This helps ensure that users have consistent permissions across all parts of your application, and that these permissions are auditable and easily auditable.

## Core Concepts

*   **Fine-Grained Authorization:** Provides precise control over who can do what with which resources within your custom applications.
*   **Centralized Policy Management:** Decouples authorization logic from your application code, allowing policies to be managed and updated centrally.
*   **Cedar Policy Language:** Uses Cedar, a new open-source policy language designed for expressive and auditable authorization policies.
*   **Scalable and Performant:** Designed to handle high-volume authorization requests for large-scale applications.
*   **Auditable:** Provides a clear record of authorization decisions for compliance and security.

## Key Components and Configuration

### 1. Policy Store

*   **Purpose:** The central repository for all your Cedar authorization policies.
*   **Schema:** You define a schema (JSON) for your application's entities (users, resources) and actions. This schema helps validate your policies and ensures consistency.
*   **Real-life Example:** For a document management application, your schema might define:
    *   **Entities:** `User`, `Document`, `Folder`.
    *   **Actions:** `View`, `Edit`, `Delete`, `Share`.

### 2. Cedar Policy Language

*   **Expressive Language:** Cedar allows you to write human-readable policies that define authorization rules.
*   **Policy Structure:** Policies consist of `permit` or `forbid` statements, specifying principals, actions, and resources, with optional conditions.
*   **Principals:** The entity requesting an action (e.g., `User::"alice"`).
*   **Actions:** The action being requested (e.g., `Action::"view"`).
*   **Resources:** The entity on which the action is being performed (e.g., `Document::"doc123"`).
*   **Conditions:** Optional clauses (`when`, `unless`) that add context-based restrictions (e.g., `when { request.ip_address is in IpAddress::"192.0.2.0/24" }`).
*   **Real-life Example:**
    ```cedar
    permit (
        principal == User::"alice",
        action == Action::"view",
        resource == Document::"doc123"
    );

    forbid (
        principal,
        action == Action::"share",
        resource
    )
    when {
        resource.isPublic == true
    };

    permit (
        principal == User::"bob",
        action == Action::"edit",
        resource in Folder::"projectX"
    )
    unless {
        principal.isSuspended == true
    };
    ```

### 3. Authorization API

*   **IsAuthorized API:** This is the primary API call your application makes to Verified Permissions to determine if a user (principal) is authorized to perform a specific action on a resource.
*   **Input:** Your application sends the `principal`, `action`, `resource`, and any `context` (e.g., IP address, time of day) to Verified Permissions.
*   **Output:** Verified Permissions evaluates the request against all policies in the policy store and returns an `Allow` or `Deny` decision, along with the reasoning.
*   **Real-life Example:** When `User::"alice"` tries to `Action::"edit"` `Document::"doc456"`, your application calls `IsAuthorized`. Verified Permissions checks its policies and returns `Allow` if Alice has permission, `Deny` otherwise.

### 4. Integration with Identity Providers

*   **External Identities:** Verified Permissions can work with external identity providers like Amazon Cognito, Okta, or other OIDC-compliant providers. Your application passes the identity information (e.g., user ID, group memberships) to Verified Permissions as part of the authorization request.
*   **Real-life Example:** A user authenticates via Amazon Cognito. Your application extracts the user's ID and groups from the JWT token and passes this information to Verified Permissions when making authorization calls.

### 5. Management and Auditability

*   **Policy Management:** The Verified Permissions console and API allow you to create, update, delete, and view your policies.
*   **Policy Evaluation History:** Detailed logs of authorization requests and decisions are available, providing an audit trail for compliance and troubleshooting.
*   **Policy Validation:** The service helps validate your policies against your schema to catch errors.

## Purpose and Real-life Use Cases

*   **Custom Application Authorization:** Centralizing and externalizing authorization logic for complex applications (e.g., SaaS platforms, multi-tenant applications).
*   **Microservices Security:** Ensuring consistent authorization policies across a distributed microservices architecture.
*   **Dynamic and Contextual Permissions:** Implementing authorization rules that depend on real-time context (e.g., user's location, time of day, device type).
*   **Compliance and Regulatory Requirements:** Meeting strict compliance needs by providing auditable and easily manageable fine-grained access controls.
*   **Accelerated Development:** Decoupling authorization from application code allows developers to focus on core business logic, while security teams manage policies.
*   **Multi-tenant Applications:** Easily defining and enforcing tenant-specific access rules.
*   **Modernizing Authorization:** Moving away from hardcoded, fragmented authorization logic to a centralized, policy-based system.

AWS Verified Permissions simplifies the implementation of sophisticated authorization systems for custom applications, enhancing security, improving agility, and reducing operational overhead.
