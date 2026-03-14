# Amazon Managed Service for Prometheus (AMP)

Amazon Managed Service for Prometheus (AMP) is a fully managed, Prometheus-compatible monitoring service that makes it easy to monitor containerized applications and infrastructure at scale. AMP provides a highly available, scalable, and secure environment for ingesting, storing, and querying metrics using the open-source Prometheus query language (PromQL).

## Core Concepts

*   **Managed Prometheus:** AWS handles the provisioning, scaling, and operational management of Prometheus servers. You don't need to manage the underlying infrastructure for your monitoring system.
*   **Prometheus Compatible:** AMP supports the Prometheus data model and PromQL, allowing you to use your existing Prometheus client libraries, data collection agents (like Prometheus servers or AWS Distro for OpenTelemetry), and visualization tools (like Grafana).
*   **Scalability:** AMP automatically scales to ingest and store large volumes of metrics from thousands of containerized workloads.
*   **High Availability:** Metrics are stored across multiple Availability Zones for high durability and availability.
*   **Cost-Effective:** You pay only for the metrics you ingest, store, and query.

## Key Components and Configuration

### 1. AMP Workspace

An AMP workspace is a dedicated, isolated environment where your Prometheus metrics are ingested, stored, and queried.

*   **Creation:** You create a workspace in a specific AWS Region.
*   **Endpoint:** Each workspace has a unique remote write endpoint (for ingesting metrics) and a query endpoint (for querying metrics).
*   **Real-life Example:** You create an AMP workspace for your production environment. All your EKS clusters and other containerized applications in this environment will send their Prometheus metrics to this workspace.

### 2. Data Ingestion (Remote Write)

Metrics are ingested into AMP using the Prometheus remote write protocol.

*   **Prometheus Server:** You typically configure a self-managed Prometheus server (running on an EC2 instance, EKS cluster, etc.) to scrape metrics from your applications and then *remote write* them to your AMP workspace's ingestion endpoint.
*   **AWS Distro for OpenTelemetry (ADOT):** ADOT is a secure, production-ready, AWS-supported distribution of the OpenTelemetry project. You can use the ADOT collector to gather metrics from your applications and infrastructure and export them to AMP. This is often the recommended way for containerized environments.
*   **Real-life Example:** In your EKS cluster, you deploy the ADOT collector as a DaemonSet. The collector is configured to scrape Prometheus metrics from your application pods and then forward those metrics to your AMP workspace's remote write endpoint.

### 3. Data Querying (PromQL)

Metrics stored in AMP can be queried using PromQL.

*   **Grafana Integration:** Amazon Managed Grafana (AMG) provides direct integration with AMP, allowing you to easily set up AMP as a data source and build dashboards using PromQL queries.
*   **Prometheus Query Client:** You can also use standard Prometheus query clients or the AWS CLI/SDK to query metrics.
*   **Real-life Example:** In your Amazon Managed Grafana workspace, you add AMP as a data source. You then create a dashboard panel that uses a PromQL query like `sum(rate(http_requests_total{job="my-app"}[5m]))` to visualize the total HTTP request rate for your application over the last 5 minutes.

### 4. Alerting (Managed Rule Groups)

AMP supports Prometheus-compatible alerting by processing metrics against defined rule groups.

*   **Rule Groups:** You define Prometheus recording rules and alerting rules (using PromQL) within AMP.
*   **Alert Manager:** AMP integrates with a self-managed Prometheus Alertmanager (which you would typically deploy in your cluster) to handle alert routing, deduplication, and notification.
*   **Real-life Example:** You create an alerting rule in AMP that triggers when the `http_server_requests_total` rate for your application (with `status="5xx"`) exceeds a certain threshold. This alert is then sent to your Alertmanager, which notifies your on-call team via Slack.

### 5. Access Control

*   **IAM:** Access to AMP workspaces (ingestion and query endpoints) is controlled via AWS IAM policies.
*   **Authentication:** Requests to AMP endpoints must be signed with AWS SigV4.
*   **Real-life Example:** You create an IAM role for your ADOT collector that grants it `aps:RemoteWrite` permissions on your AMP workspace. For your Grafana data source, you create an IAM role that grants `aps:Query` permissions.

### 6. Data Retention

*   **Default Retention:** AMP retains metrics for 45 days by default.
*   **Configurable Retention:** You can configure custom retention periods.

## Purpose and Real-Life Use Cases

*   **Monitoring Containerized Workloads:** Ideal for monitoring applications running on Amazon ECS, Amazon EKS, and Kubernetes clusters, providing deep visibility into application and infrastructure health.
*   **Microservices Observability:** Collecting metrics from individual microservices and visualizing their performance and interdependencies.
*   **Large-Scale Metrics Ingestion:** Designed to handle high-volume, high-cardinality metrics from dynamic environments.
*   **Migration from Self-Managed Prometheus:** Offloading the operational burden of managing and scaling Prometheus servers, allowing teams to focus on building and querying dashboards.
*   **Observability with Open-Source Tools:** Leverage the power of Prometheus and Grafana while benefiting from a fully managed AWS service.

AMP provides a robust, scalable, and fully managed solution for Prometheus-compatible monitoring, enabling you to gain deeper insights into your cloud-native applications.
