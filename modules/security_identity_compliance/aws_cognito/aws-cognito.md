# Amazon Cognito

Amazon Cognito provides authentication, authorization, and user management for your web and mobile apps. It scales to millions of users and supports sign-in with social identity providers (like Facebook, Google, Apple) and enterprise identity providers (like Microsoft Azure AD via SAML 2.0).

## Core Concepts

*   **Identity Management:** Cognito simplifies the process of adding user sign-up, sign-in, and access control to your applications.
*   **Authentication and Authorization:** Handles user authentication (verifying identity) and authorization (what authenticated users can do).
*   **Scalable:** Designed to scale to support millions of users.
*   **Integration:** Integrates with other AWS services like API Gateway, Lambda, and S3, as well as external identity providers.

## Key Components and Configuration

Cognito is typically used through two main components: User Pools and Identity Pools.

### 1. User Pools

*   **Purpose:** User directories that provide sign-up and sign-in options for your application users.
*   **Functionality:** Handles user registration, authentication, account recovery (forgot password), and multi-factor authentication (MFA).

#### Configuration Options

*   **Attributes:** Define the user profile attributes (e.g., email, phone number, name, custom attributes). You can mark attributes as required, mutable, or verifiable.
    *   **Real-life Example:** For a social media app, you might require an email and a username, and allow users to add an optional profile picture URL.
*   **Policies:**
    *   **Password Policy:** Configure password complexity requirements (minimum length, special characters, numbers).
    *   **User Account Recovery:** Choose how users can recover their accounts (e.g., via email or phone).
*   **Multi-Factor Authentication (MFA):**
    *   **Off:** No MFA.
    *   **Optional:** Users can enable MFA.
    *   **Required:** MFA is mandatory for all users.
    *   **Types:** SMS text messages, Time-based One-Time Passwords (TOTP) using authenticator apps.
*   **App Clients:** You create "App Clients" within your User Pool to represent applications (e.g., a web app, a mobile app) that will interact with your User Pool. Each App Client gets an ID and optionally a secret.
*   **Customization:**
    *   **UI Customization:** Customize the look and feel of the hosted UI for sign-up and sign-in.
    *   **Email/SMS Customization:** Customize the messages sent for verification, password resets, etc.
    *   **Lambda Triggers:** Use AWS Lambda functions to customize various stages of the user lifecycle (e.g., pre-sign-up to validate user data, post-authentication to log user activity).
*   **Domain:** You can host your sign-up/sign-in pages on a Cognito domain (e.g., `your-domain.auth.region.amazoncognito.com`) or use your own custom domain.
*   **Social and Enterprise Federation:** Configure User Pools to allow users to sign in with external identity providers:
    *   **Social:** Google, Facebook, Apple, Amazon.
    *   **Enterprise:** SAML 2.0 (e.g., Okta, Azure AD), OpenID Connect (OIDC).

### 2. Identity Pools (Federated Identities)

*   **Purpose:** Authorize users to access other AWS services. After users authenticate with a User Pool, a social identity provider, or an enterprise identity provider, an Identity Pool grants them temporary AWS credentials to access services like S3 or DynamoDB.
*   **Functionality:** Exchanges external tokens for temporary AWS credentials.

#### Configuration Options

*   **Authentication Providers:** Specify which authentication providers you trust (e.g., a specific User Pool, Facebook, Google, SAML).
*   **Unauthenticated Identities:** You can enable access for "guests" who don't sign in, granting them limited access to AWS resources (e.g., to browse products in an e-commerce app).
*   **Roles:**
    *   **Authenticated Role:** An IAM role assumed by users who have successfully authenticated through one of the configured providers.
    *   **Unauthenticated Role:** An IAM role assumed by unauthenticated users.
    *   **Role Attachment:** You define the IAM policies attached to these roles, which determine what AWS resources the users can access.
*   **Real-life Example:** Your mobile app allows users to upload photos to a specific S3 bucket.
    1.  User signs in to your app using a Cognito User Pool.
    2.  The app uses the token from the User Pool to get temporary AWS credentials from a Cognito Identity Pool.
    3.  The Identity Pool's authenticated role has an IAM policy that allows `s3:PutObject` only on the `user-photos` S3 bucket, and only for objects with a key prefix corresponding to the user's ID.
    4.  The user's app uses these temporary credentials to upload photos directly to S3.

## Purpose and Real-Life Use Cases

*   **User Authentication for Web and Mobile Apps:** Adding secure sign-up, sign-in, and user management to your customer-facing applications.
*   **Single Sign-On (SSO):** Allowing users to sign in with their preferred social (Google, Facebook) or enterprise (SAML, OIDC) credentials.
*   **Access Control to AWS Resources:** Granting your application users fine-grained, temporary access to AWS services (e.g., uploading files to S3, accessing specific DynamoDB items) without embedding static credentials in the application.
*   **Serverless Architectures:** Commonly used with AWS API Gateway and Lambda functions to secure API endpoints and manage user access.
*   **Customer Relationship Management (CRM) Portals:** Providing secure login for customers to access their information and services.
*   **Gaming Applications:** Managing player accounts and providing access to game data stored in AWS.

Cognito abstracts away much of the complexity of managing user identities, allowing developers to focus on their application's core features while maintaining a secure and scalable authentication system.
