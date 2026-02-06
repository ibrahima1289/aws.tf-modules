# AWS Key Management Service (KMS)

AWS Key Management Service (KMS) makes it easy for you to create and manage cryptographic keys and control their use across a wide range of AWS services and in your applications. KMS is a secure and resilient service that uses hardware security modules (HSMs) to protect your keys.

## Core Concepts

*   **Managed Encryption:** KMS centralizes key management, allowing you to encrypt your data within AWS services and in your own applications.
*   **Hardware Security Modules (HSMs):** KMS uses FIPS 140-2 validated HSMs to protect the security of your keys. This means your keys are generated and stored in a secure hardware device that is tamper-resistant.
*   **Auditability:** All API calls to KMS are logged in AWS CloudTrail, providing an audit trail of who used which keys, when, and for what purpose.
*   **Integration with AWS Services:** Many AWS services are integrated with KMS, allowing you to easily encrypt data at rest within those services using keys managed by KMS.

## Key Components and Configuration

### 1. Customer Master Keys (CMKs) - now called KMS keys

A KMS key (formerly Customer Master Key or CMK) is the primary resource in KMS. It is a logical representation of a master key.

*   **Types of KMS Keys:**
    *   **Customer Managed Keys (CMKs):**
        *   You create, own, and manage these keys. You have full control over the key policy, enabling/disabling the key, scheduling key deletion, and rotating the key.
        *   **Use Case:** When you need fine-grained control over your encryption keys, such as for compliance requirements.
        *   **Real-life Example:** You create a Customer Managed Key to encrypt an S3 bucket that contains sensitive financial data. You then attach a key policy that only allows specific IAM roles to use this key for encryption and decryption.
    *   **AWS Managed Keys:**
        *   These keys are created, managed, and used on your behalf by an AWS service that is integrated with KMS. (e.g., `aws/s3`, `aws/rds`).
        *   You can view these keys but have limited control over them (e.g., you can't change their key policy or schedule them for deletion).
        *   **Use Case:** When you want simple, automatic encryption for a service without needing to manage the key's lifecycle.
        *   **Real-life Example:** You enable server-side encryption for an S3 bucket using an AWS Managed Key. S3 automatically handles the creation and use of the key for encrypting and decrypting objects.
    *   **AWS Owned Keys:**
        *   AWS owns and manages these keys for use in multiple AWS accounts. You don't see or manage these keys.
        *   **Use Case:** When a service needs to encrypt data but you don't need any control over the key itself.
*   **Key Material:**
    *   **KMS-generated key material (default):** KMS generates the key material within its HSMs.
    *   **Imported key material:** You can import your own key material into KMS.
    *   **Custom key store:** You can use a custom key store backed by AWS CloudHSM or an external key store to manage your keys outside of AWS.

### 2. Key Policies

*   **Access Control:** A key policy is the primary way to control access to a KMS key. It's a JSON document that defines who can use the key and how.
*   **Required for Customer Managed Keys:** Every Customer Managed Key must have a key policy.
*   **IAM Integration:** Key policies work in conjunction with IAM policies. An entity needs permission from *both* the key policy and its IAM policy to use a KMS key.
*   **Real-life Example:** A key policy for a CMK might grant permission to a specific IAM user to perform `kms:Encrypt` and `kms:Decrypt` operations, while also allowing an IAM role (e.g., an EC2 instance profile) to use the key for data encryption by AWS services.

### 3. Envelope Encryption

*   **Protecting Data Keys:** When you encrypt data with KMS, you don't directly send your large data blocks to KMS for encryption. Instead, KMS uses a technique called envelope encryption.
*   **How it Works:**
    1.  Your application requests KMS to generate a data key.
    2.  KMS generates a plaintext data key and an encrypted copy of that data key.
    3.  Your application uses the plaintext data key to encrypt your data.
    4.  Your application discards the plaintext data key and stores the encrypted data key alongside the encrypted data.
    5.  To decrypt, your application sends the encrypted data key to KMS.
    6.  KMS decrypts the data key and returns the plaintext data key to your application.
    7.  Your application uses the plaintext data key to decrypt your data.
*   **Real-life Example:** You have a large file stored in S3. Instead of sending the entire file to KMS, you ask KMS for a data key. You encrypt the file locally using the data key, then store the encrypted file and the encrypted data key in S3.

## Purpose and Real-Life Use Cases

*   **Encrypting Data at Rest:**
    *   **S3:** Server-side encryption for S3 objects.
    *   **EBS:** Encrypting EBS volumes attached to EC2 instances.
    *   **RDS/Aurora:** Encrypting RDS and Aurora database instances.
    *   **DynamoDB:** Encrypting DynamoDB tables.
    *   **Lambda:** Encrypting environment variables for Lambda functions.
    *   **Real-life Example:** A company stores customer invoices in an S3 bucket. They configure the S3 bucket to use server-side encryption with a Customer Managed Key in KMS, ensuring that all stored invoices are encrypted with a key they control.

*   **Encrypting Data in Your Applications:**
    *   Using the KMS API to generate data keys and encrypt/decrypt sensitive data within your own custom applications.
    *   **Real-life Example:** An application needs to store highly sensitive user credentials in a database. Instead of storing them in plaintext or encrypting with an application-level key, the application uses KMS to encrypt each credential before storing it, and decrypts it only when needed.

*   **Compliance Requirements:** For organizations that need to meet regulatory compliance standards (e.g., HIPAA, PCI DSS) that require strong encryption and strict control over cryptographic keys.
*   **Centralized Key Management:** Providing a single, auditable service for managing all your encryption keys across AWS.

KMS is a fundamental security service in AWS, enabling you to protect your sensitive data by managing your encryption keys securely and easily.
