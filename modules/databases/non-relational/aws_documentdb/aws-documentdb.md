# Amazon DocumentDB (with MongoDB compatibility)

Amazon DocumentDB is a scalable, highly available, and fully managed database service for MongoDB-compatible workloads. As a document database, DocumentDB makes it easy to store, query, and index JSON-like data. It is not MongoDB, but it emulates the MongoDB 3.6, 4.0, or 5.0 API, allowing you to use your existing MongoDB drivers and tools with minimal changes.

## Core Concepts

*   **MongoDB Compatibility:** DocumentDB is compatible with the MongoDB API, which means you can use the same application code, drivers, and tools that you use with MongoDB to connect to and interact with a DocumentDB cluster.
*   **Fully Managed:** DocumentDB automates time-consuming administration tasks such as hardware provisioning, database setup, patching, and backups.
*   **Decoupled Storage and Compute:** DocumentDB has a unique architecture that separates storage and compute. The storage layer is a distributed, fault-tolerant, self-healing storage system that replicates six copies of your data across three Availability Zones. This provides high durability and availability.
*   **Cluster-based:** A DocumentDB deployment consists of a *cluster* which contains one or more *instances*.

## Key Components and Configuration

### 1. Cluster

A DocumentDB cluster consists of a cluster volume and one or more instances.

*   **Cluster Volume:** This is the virtual database storage volume that spans multiple Availability Zones. All instances in the cluster share the same cluster volume.
*   **Primary Instance:** There is always one primary instance in the cluster. It supports read and write operations and is responsible for all data modifications to the cluster volume.
*   **Replica Instances:** You can have up to 15 replica instances. These are read-only and are used to increase the read throughput of your application. They also serve as failover targets for the primary instance.

### 2. Instance Class and Storage

*   **Instance Class:** This determines the compute and memory capacity of the instances in your cluster (e.g., `db.t3.medium`, `db.r5.large`).
*   **Storage:** You do not provision storage in advance for DocumentDB. The cluster volume automatically grows as your data grows, up to a maximum of 128 TiB. You are billed for the storage you actually consume.

### 3. High Availability and Failover

*   **Automatic Failover:** DocumentDB is highly available by design. If the primary instance fails, one of the replica instances is automatically promoted to be the new primary with minimal interruption (typically less than 30 seconds).
*   **Multi-AZ Architecture:** The underlying storage volume is always replicated across 3 Availability Zones. For the instances, you should provision at least one replica instance in a different AZ from the primary for high availability.

### 4. Endpoints

When you create a cluster, DocumentDB provides two types of endpoints:

*   **Cluster Endpoint:** This is the main endpoint you should connect your application to. It always points to the current primary instance. If a failover occurs, DocumentDB automatically updates the cluster endpoint to point to the new primary. Using this endpoint ensures your application can always perform write operations.
*   **Reader Endpoint:** This endpoint load balances read-only connections across all of the available replica instances in the cluster. You can configure your application to send all read queries to the reader endpoint to scale out your read capacity.

### 5. Backups and Maintenance

*   **Automated Backups:** DocumentDB automatically and continuously backs up your cluster to Amazon S3. This allows for point-in-time recovery (PITR) for your cluster, up to the last five minutes.
*   **Manual Snapshots:** You can take manual snapshots of your cluster at any time. These are stored until you explicitly delete them.
*   **Maintenance Window:** DocumentDB performs patching and other maintenance during a configurable weekly maintenance window.

### 6. Security

*   **VPC Only:** DocumentDB clusters are deployed within your Amazon Virtual Private Cloud (VPC). You cannot directly expose a DocumentDB cluster to the public internet. Your application must be running in the same VPC or a peered VPC to connect.
*   **Security Groups:** You use security groups to control which EC2 instances or other resources can connect to your cluster.
*   **Encryption:**
    *   **Encryption at Rest:** All data in the cluster volume, as well as backups and snapshots, are encrypted by default using AWS Key Management Service (KMS).
    *   **Encryption in Transit:** Connections can be encrypted using TLS.

## Purpose and Real-Life Use Cases

The primary use case for DocumentDB is for workloads that were built for MongoDB but require a fully managed, scalable, and highly available database service.

*   **Content Management and Catalogs:** The flexible schema of a document model is ideal for managing product catalogs, content repositories, and user profiles where attributes can vary between items.
*   **Mobile and Web Applications:** Serving as a backend database for applications that need to handle semi-structured data and require fast, iterative development.
*   **Migrating from MongoDB:** Migrating self-managed MongoDB databases to DocumentDB to reduce operational overhead and improve scalability and availability.
*   **Personalization:** Storing user preferences and profile information for real-time personalization of application experiences.

**When to choose DocumentDB vs. DynamoDB?**

*   **Choose DocumentDB if:** You have an existing MongoDB application, you need rich query capabilities (including aggregations and ad-hoc queries), or your developers are already skilled with MongoDB.
*   **Choose DynamoDB if:** You are building a new application from scratch (especially a serverless one), your access patterns are well-defined, and you need extreme scalability with consistent single-digit millisecond latency.
