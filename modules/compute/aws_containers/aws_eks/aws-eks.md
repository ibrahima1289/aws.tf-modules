# Amazon Elastic Kubernetes Service (EKS)

Amazon Elastic Kubernetes Service (EKS) is a managed service that makes it easy to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane. EKS is certified Kubernetes-conformant, so you can use existing tools and plugins from the Kubernetes community.

## Core Concepts

*   **Managed Kubernetes:** EKS provides a managed control plane that is highly available and scalable across multiple AWS Availability Zones. You are responsible for the worker nodes where your containers run.
*   **Kubernetes Conformant:** EKS runs upstream, vanilla Kubernetes. This means you can easily migrate any standard Kubernetes application to EKS and use your favorite Kubernetes tools.
*   **Deep AWS Integration:** EKS integrates with AWS services for networking (VPC), authentication (IAM), load balancing (ELB), and storage (EBS).

## Key Components and Configuration

### 1. EKS Cluster

An EKS cluster consists of two main components: the control plane and the worker nodes.

*   **Control Plane:**
    *   Managed by AWS. It runs the core Kubernetes components (like `etcd`, the API server, etc.) in a highly available configuration.
    *   **Endpoint Access:** You can configure whether the Kubernetes API server endpoint is public, private, or both.
*   **Worker Nodes:**
    *   These are the compute resources where your pods (containers) run. EKS supports several options for worker nodes.

### 2. Worker Node Options

You have a few choices for how to provision and manage your worker nodes.

*   **Managed Node Groups:**
    *   **What it is:** An automated way to provision and manage EC2 instances for your cluster. EKS handles the provisioning, scaling, and lifecycle of the nodes.
    *   **Configuration:** You define an Auto Scaling group with properties like instance type, disk size, and desired/min/max number of nodes.
    *   **Real-life Example:** You create a managed node group with `t3.medium` instances, set to scale from 2 to 10 nodes. If a node fails, EKS will automatically terminate it and the Auto Scaling group will launch a replacement.

*   **Self-Managed Nodes:**
    *   **What it is:** You manually provision and manage EC2 instances in an Auto Scaling group. You are responsible for configuring the instances, installing the necessary software (like the `kubelet`), and registering them with the EKS cluster.
    *   **Use Case:** When you need more control over the node configuration, such as using a custom AMI or applying specific kernel parameters.

*   **AWS Fargate:**
    *   **What it is:** A serverless option for running pods. With Fargate, you don't need to manage any worker nodes at all.
    *   **Fargate Profiles:** You create Fargate profiles that specify which pods should run on Fargate. You can select pods based on their namespace and labels.
    *   **Real-life Example:** You create a Fargate profile for the `kube-system` namespace and another for a namespace called `serverless-apps`. Any pods deployed to the `serverless-apps` namespace will automatically run on Fargate, while other pods might run on a managed node group.

### 3. Networking

*   **VPC and Subnets:** Your EKS cluster runs within your own VPC. You must specify the VPC and subnets where the cluster and worker nodes will be located.
*   **AWS VPC CNI Plugin:** EKS uses a specific Container Network Interface (CNI) plugin that allows pods to have their own IP addresses directly from your VPC. This simplifies networking and allows you to use VPC security groups to control traffic to and from your pods.
*   **Load Balancing (Services and Ingress):**
    *   **Service type `LoadBalancer`:** When you create a Kubernetes service of type `LoadBalancer`, EKS will automatically provision an AWS Classic or Network Load Balancer to distribute traffic to the pods in that service.
    *   **AWS Load Balancer Controller:** This is an add-on that you can install in your cluster. It allows you to create Application Load Balancers (ALBs) by creating a Kubernetes `Ingress` object. This is the recommended way to expose HTTP/S services.
    *   **Real-life Example:** You have a web application deployment. You create a Kubernetes `Ingress` resource with rules for routing traffic (e.g., `/api` goes to the backend service, `/` goes to the frontend service). The AWS Load Balancer Controller sees this Ingress and automatically provisions an ALB with the corresponding listeners and target groups.

### 4. Authentication and Authorization

*   **IAM Integration:** EKS uses IAM for authenticating with the Kubernetes API server. You can map IAM users and roles to Kubernetes users and groups.
*   **`aws-auth` ConfigMap:** This is a configuration map in Kubernetes that you use to define the mapping between IAM entities and Kubernetes RBAC (Role-Based Access Control) users.
*   **RBAC:** Within the cluster, you use standard Kubernetes RBAC (Roles, ClusterRoles, RoleBindings, ClusterRoleBindings) to control what actions a user can perform.
*   **Real-life Example:** You grant your DevOps team's IAM role access to the cluster by adding it to the `aws-auth` ConfigMap and mapping it to a Kubernetes group called `cluster-admins`. You then create a ClusterRoleBinding that gives the `cluster-admins` group full administrative privileges in the cluster.

### 5. Add-ons

EKS supports a range of add-ons that extend the functionality of your cluster.

*   **CoreDNS, kube-proxy, VPC CNI:** These are core components that are managed as EKS add-ons.
*   **EBS CSI Driver:** Allows you to manage Amazon EBS volumes using standard Kubernetes persistent storage interfaces (`PersistentVolume`, `PersistentVolumeClaim`, `StorageClass`).
*   **Other common add-ons:** `cluster-autoscaler` (for scaling worker nodes), `metrics-server`, AWS Load Balancer Controller.

## Purpose and Real-Life Use Cases

*   **Standardization on Kubernetes:** For organizations that are already using Kubernetes or want to adopt it as their standard for container orchestration, EKS provides a managed and production-ready environment.
*   **Hybrid and Multi-Cloud Environments:** Because EKS is conformant Kubernetes, it's easier to build applications that can run consistently across on-premises data centers and multiple cloud providers.
*   **Complex Microservices Architectures:** Kubernetes provides a rich set of features for managing complex applications with many services, including service discovery, advanced networking policies, and secrets management.
*   **Leveraging the Kubernetes Ecosystem:** To take advantage of the vast ecosystem of open-source tools and projects that are built for Kubernetes (e.g., Helm, Prometheus, Istio).

EKS is ideal for teams that want the power and flexibility of Kubernetes without the operational overhead of managing the control plane.
