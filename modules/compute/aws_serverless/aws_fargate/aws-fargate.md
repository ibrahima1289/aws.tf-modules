# AWS Fargate

AWS Fargate is a serverless, pay-as-you-go compute engine that lets you focus on building applications without managing servers. It is a technology that can be used with Amazon Elastic Container Service (ECS) and Amazon Elastic Kubernetes Service (EKS) to run containers without having to manage the underlying EC2 instances.

## Core Concepts

*   **Serverless for Containers:** Fargate is to containers what Lambda is to functions. It removes the need to provision, patch, and scale clusters of virtual machines to run your containers.
*   **Task/Pod-level Resourcing:** You define the CPU and memory resources required for each task (in ECS) or pod (in EKS). You are billed for these resources for the duration that your task/pod is running.
*   **Secure by Design:** Each Fargate task or pod runs in its own isolated kernel environment. They do not share an underlying kernel, CPU, memory, or network interface with other tasks or pods, which provides a more secure operational model.
*   **Not a Standalone Service:** Fargate is not a service you use directly. It is a "launch type" or capacity option that you select within ECS or EKS.

## Fargate with Amazon ECS

When using Fargate with ECS, you no longer need to create a cluster of EC2 instances.

### Configuration

1.  **Cluster:** You still create an ECS cluster, but it's just a logical grouping for your services. You choose the "AWS Fargate" infrastructure option.
2.  **Task Definition:**
    *   **`networkMode`:** Must be set to `awsvpc`. This gives each task its own Elastic Network Interface (ENI).
    *   **`requiresCompatibilities`:** Must include `FARGATE`.
    *   **Task Size:** You define the total CPU (vCPU) and memory for the *entire task*. Fargate will then launch a compute environment that exactly matches this specification.
3.  **Service:** You create an ECS service and specify the `launchType` as `FARGATE`. You also specify the desired number of tasks and the VPC subnets where the tasks should be launched.

*   **Real-life Example:** You want to run a web service defined in an ECS task definition that requires 1 vCPU and 2 GB of memory. You create an ECS service, set the launch type to Fargate, and set the desired count to 3. ECS will then launch three separate, isolated compute environments, each with 1 vCPU and 2 GB of memory, and run one copy of your task in each.

## Fargate with Amazon EKS

When using Fargate with EKS, you can run pods without needing to provision and manage EC2 worker nodes.

### Configuration

1.  **Cluster:** You create a standard EKS cluster.
2.  **Fargate Profile:** You create one or more Fargate profiles for your cluster. A Fargate profile tells EKS which pods should run on Fargate.
    *   **Selector:** A profile has selectors that specify a namespace and optional labels. Any pod that matches these selectors will be scheduled on Fargate.
    *   **Pod Execution Role:** You specify an IAM role that gives the `kubelet` running on the Fargate infrastructure permission to pull images and perform other AWS API calls.
3.  **Pods:** When you deploy a pod (e.g., as part of a Deployment) that matches a Fargate profile's selectors, EKS automatically provisions a Fargate environment for it to run on.

*   **Real-life Example:** You have an EKS cluster and you want to run your stateless web applications on Fargate, but your stateful applications (which require persistent EBS storage) on EC2-based worker nodes.
    *   You create a Fargate profile with a selector for the namespace `stateless-apps`.
    *   You deploy your web application pods to the `stateless-apps` namespace. EKS will automatically run them on Fargate.
    *   You deploy your stateful application pods to a different namespace, and EKS will schedule them on your managed EC2 node group.

## Configuration and Pricing

*   **CPU and Memory Combinations:** Fargate offers a wide range of vCPU and memory configurations. You select the combination that best fits your application's needs.
*   **Pricing:** You are billed based on the vCPU and memory resources your task/pod requests, calculated from the time the container image is pulled until the task/pod terminates, rounded up to the nearest second.
*   **Fargate Spot:** Similar to EC2 Spot Instances, Fargate Spot allows you to run fault-tolerant ECS tasks at a significant discount (up to 70%) compared to the regular Fargate price. Fargate Spot tasks can be interrupted if AWS needs the capacity back.

## Purpose and Real-Life Use Cases

*   **Focus on Applications, Not Infrastructure:** The primary benefit of Fargate is removing the operational overhead of managing the underlying compute infrastructure. This is ideal for teams that want to focus solely on developing their containerized applications.
*   **Microservices:** Running individual microservices that can be scaled independently without worrying about cluster capacity or bin-packing tasks onto instances.
*   **Bursty or Sporadic Workloads:** Fargate is excellent for applications with unpredictable traffic. It can scale from zero to hundreds of tasks very quickly without you needing to pre-provision any instances.
*   **Batch Processing:** Running containerized batch jobs as standalone ECS tasks on Fargate.
*   **Secure Environments:** For applications that require a high degree of isolation between tasks, Fargate provides this by default.
*   **Simplifying Kubernetes:** Using Fargate with EKS can significantly reduce the operational complexity of managing a Kubernetes cluster, as you no longer need to worry about patching, scaling, or securing your worker nodes.

Fargate provides a powerful serverless foundation for running containers, striking a balance between the simplicity of a platform-as-a-service (PaaS) and the flexibility of a container orchestrator.
