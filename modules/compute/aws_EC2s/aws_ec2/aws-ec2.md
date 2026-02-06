# Amazon Elastic Compute Cloud (EC2)

Amazon Elastic Compute Cloud (EC2) is a web service that provides secure, resizable compute capacity in the cloud. It is designed to make web-scale cloud computing easier for developers. EC2 is one of the foundational services of AWS, providing virtual servers, known as instances, on which you can run your applications.

## Core Concepts

*   **Instances:** A virtual server in the AWS cloud. It is a copy of an Amazon Machine Image (AMI) running as a virtual server.
*   **Amazon Machine Image (AMI):** A template that contains a software configuration (for example, an operating system, an application server, and applications). From an AMI, you launch an *instance*.
*   **Instance Types:** Various combinations of CPU, memory, storage, and networking capacity for your instances.
*   **Storage:** EC2 instances can use different types of storage, including Elastic Block Store (EBS) for persistent block storage and Instance Store for temporary storage.
*   **Networking and Security:** Instances are launched into a Virtual Private Cloud (VPC) and are protected by Security Groups.

## Configuration Options

### 1. Amazon Machine Image (AMI)

When you launch an instance, you must specify an AMI.

*   **AWS-provided AMIs:** A wide range of AMIs for popular operating systems like Amazon Linux, Ubuntu, Windows Server, etc.
*   **AWS Marketplace AMIs:** Pre-configured AMIs from third-party vendors, often including commercial software.
*   **Custom AMIs:** You can create your own AMIs from your existing EC2 instances. This is useful for creating a "golden image" with your standard configuration and software pre-installed.
*   **Real-life Example:** You need to deploy a web application that requires a specific version of Node.js and several system libraries. You can launch a standard Amazon Linux AMI, install all the required software, and then create a custom AMI from it. You can then use this custom AMI to launch new instances that are pre-configured and ready to run your application.

### 2. Instance Type

EC2 provides a wide variety of instance types optimized for different use cases.

*   **General Purpose (e.g., `t3`, `m5`):** Balanced CPU, memory, and networking. Good for a wide range of workloads like web servers and development environments.
*   **Compute Optimized (e.g., `c5`):** High-performance processors. Ideal for compute-intensive applications like batch processing, media transcoding, and scientific modeling.
*   **Memory Optimized (e.g., `r5`):** Large memory footprint. Designed for memory-intensive applications like in-memory databases and real-time big data analytics.
*   **Storage Optimized (e.g., `i3`, `d2`):** High-performance local storage. Ideal for workloads that require high, sequential read and write access to very large data sets on local storage, such as data warehousing and distributed file systems.
*   **Accelerated Computing (e.g., `p3`, `g4`):** Hardware accelerators (GPUs, FPGAs). Used for machine learning, high-performance computing, and graphics-intensive applications.
*   **Real-life Example:** You are running a relational database that needs to cache a large amount of data in memory. You would choose a memory-optimized instance type like `r5.large`. For a simple blog, a `t3.micro` might be sufficient.

### 3. Purchasing Options

*   **On-Demand:** Pay for compute capacity by the hour or the second with no long-term commitments. Ideal for applications with short-term, spiky, or unpredictable workloads.
*   **Reserved Instances (RIs):** Provide a significant discount (up to 72%) compared to On-Demand pricing in exchange for a commitment to a one- or three-year term.
*   **Savings Plans:** A more flexible pricing model that offers lower prices in exchange for a commitment to a consistent amount of usage (measured in $/hour) for a one- or three-year term.
*   **Spot Instances:** Request spare EC2 computing capacity for up to 90% off the On-Demand price. Ideal for fault-tolerant, flexible workloads like batch jobs, data analysis, and testing. Spot Instances can be interrupted by AWS with a two-minute warning.
*   **Real-life Example:** For your production web server that runs 24/7, you would purchase a Savings Plan or a Reserved Instance to save money. For a nightly batch job that can be restarted if it fails, you would use Spot Instances to get the lowest cost.

### 4. Storage

*   **Elastic Block Store (EBS):** A network-attached storage volume that can be attached to your instances. It is persistent, meaning the data remains even after the instance is stopped or terminated. EBS has different volume types (e.g., `gp2`/`gp3` for general purpose, `io1`/`io2` for high-performance). This is the most common storage option.
*   **Instance Store:** Temporary block-level storage for your instance. This storage is located on disks that are physically attached to the host computer. It's ideal for temporary data that changes frequently, like caches or buffers. The data on an instance store volume persists only for the life of the associated instance.

### 5. Networking

*   **VPC and Subnet:** You launch instances into a subnet within a Virtual Private Cloud (VPC).
*   **IP Addressing:** Instances can have private IP addresses, and optionally, a public IP address to be reachable from the internet.
*   **Elastic IP Addresses:** A static, public IPv4 address designed for dynamic cloud computing. You can associate an Elastic IP with any instance in your account.
*   **Security Groups:** A virtual firewall for your instances to control inbound and outbound traffic.

### 6. Auto Scaling

*   **Auto Scaling Groups (ASG):** A collection of EC2 instances managed as a group. You can configure an ASG to automatically scale the number of instances up or down based on demand or on a schedule.
*   **Launch Templates/Configurations:** A template that an ASG uses to launch new instances.
*   **Real-life Example:** Your e-commerce website experiences high traffic during the day and low traffic at night. You can configure an Auto Scaling group to automatically increase the number of instances in the morning and decrease them at night, saving you money while ensuring you have enough capacity to handle the load.

## Purpose and Real-Life Use Cases

*   **Web Hosting:** Running web servers (like Apache, Nginx) and application servers (like Node.js, Tomcat).
*   **Databases:** Hosting relational databases (like MySQL, PostgreSQL) or NoSQL databases (like MongoDB, Cassandra). For managed database services, AWS offers RDS and DynamoDB.
*   **Application Hosting:** Running any kind of enterprise application, from CRMs to ERPs.
*   **Big Data and Analytics:** Running Hadoop clusters or other data processing frameworks.
*   **Development and Test Environments:** Quickly spinning up and tearing down environments for developers.
*   **Backend for Mobile and IoT Applications:** Providing the server-side processing for mobile and IoT apps.

EC2 provides the fundamental building blocks for a vast range of computing solutions on AWS.
