# AWS Service List — Definitions

All AWS services documented in this repository, grouped by category, with their definitions.

---

## Analytics

| Service | Definition |
|---------|------------|
| [Amazon Athena](modules/analytics/aws_athena/aws-athena.md) | Serverless, interactive query service that lets you analyse data directly in Amazon S3 using standard SQL — with no infrastructure to provision or manage. Uses Presto and Apache Spark, integrates natively with the AWS Glue Data Catalog, and charges only for the data scanned per query. |
| [AWS Glue](modules/analytics/aws_glue/aws-glue.md) | Fully managed serverless ETL (Extract, Transform, Load) service that makes it simple to discover, prepare, and combine data for analytics, machine learning, and application development. Automatically discovers and catalogs data from various sources, generates ETL code in Python or Scala, and runs jobs on a serverless Apache Spark environment. |
| [Amazon Kinesis](modules/analytics/aws_kinesis/aws-kinesis.md) | Family of services designed to process large streams of data in real-time. Enables you to collect, process, and analyze real-time data so you can get timely insights and react quickly to new information. |
| [Amazon EMR](modules/analytics/aws_mapreduce/aws-emr.md) | Fully managed big data platform for processing and analysing large datasets using open-source frameworks such as Apache Hadoop, Apache Spark, Apache Hive, Presto/Trino, and Flink. Supports EMR on EC2 (classic clusters), EMR on EKS (Spark on Kubernetes), and EMR Serverless. |
| [Amazon MSK](modules/analytics/aws-msk/aws-msk.md) | Fully managed service that makes it easy to build and run applications that use Apache Kafka to process streaming data. Simplifies the provisioning, configuration, and maintenance of Apache Kafka clusters. |
| [Amazon OpenSearch Service](modules/analytics/aws_opensearch_service/aws-opensearch.md) | Fully managed service that makes it easy to deploy, operate, and scale OpenSearch and Elasticsearch clusters in AWS. Purpose-built for real-time search, log analytics, full-text search, application monitoring, and security analytics at any scale. |
| [Amazon QuickSight](modules/analytics/aws_quicksight/aws-quicksight.md) | Fully managed, serverless business intelligence (BI) and data visualisation service. Enables organisations to create interactive dashboards, perform ad-hoc analysis, and embed analytics into applications using the in-memory SPICE engine. |
| [Amazon Redshift](modules/analytics/aws_redshift/aws-redshift.md) | Fully managed, petabyte-scale cloud data warehouse service. Enables fast, cost-effective analysis of structured and semi-structured data using standard SQL and existing BI tools, built on a massively parallel processing (MPP) architecture. |

---

## Application Integration

| Service | Definition |
|---------|------------|
| [Amazon EventBridge](modules/application_integration/aws_eventbridge/aws-eventbridge.md) | Serverless event bus service that makes it easy to connect applications together using data from your own applications, integrated SaaS applications, and AWS services. Simplifies building event-driven architectures without tight coupling. |
| [Amazon MQ](modules/application_integration/aws_mq/aws-mq.md) | Managed message broker service for Apache ActiveMQ and RabbitMQ. Supports industry-standard APIs and protocols so you can migrate applications that use existing message brokers to AWS without rewriting code. |
| [Amazon SNS](modules/application_integration/aws_sns/aws-sns.md) | Highly available, durable, secure, fully managed pub/sub messaging service. Allows you to send messages or notifications to a large number of subscribers including other AWS services, email addresses, or mobile devices. |
| [Amazon SQS](modules/application_integration/aws_sqs/aws-sqs.md) | Fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications. Eliminates the complexity of managing message-oriented middleware. |
| [AWS Step Functions](modules/application_integration/aws_step_function/aws-step-functions.md) | Fully managed serverless orchestration service that enables you to coordinate multiple AWS services into serverless workflows. Manages state, checkpoints, and restarts automatically to ensure your application executes in order even when failures occur. |

---

## Cloud Financial Management

| Service | Definition |
|---------|------------|
| [AWS Budgets](modules/cloud_financial_management/aws_budget/aws-budget.md) | Cost management service that lets you set custom budgets for cost and usage, track actual and forecasted spend against those budgets, and trigger SNS/email notifications or automated remediation actions when thresholds are crossed. |
| [AWS Savings Plans](modules/cloud_financial_management/aws_savings_plan/aws-savings-plan.md) | Flexible pricing model that offers up to 72% savings on AWS compute usage in exchange for a 1- or 3-year commitment to a consistent hourly spend. Unlike Reserved Instances, Savings Plans apply automatically across eligible usage without instance-type or region lock-in. |

---

## Compute

### Containers

| Service | Definition |
|---------|------------|
| [AWS App Runner](modules/compute/aws_containers/aws_app_runner/aws-app-runner.md) | Fully managed service that makes it easy for developers to quickly deploy containerized web applications and APIs at scale with no prior infrastructure experience required. Automatically builds and deploys the application, load balances traffic, and scales based on demand. |
| [AWS App2Container](modules/compute/aws_containers/aws_app2container/aws-app2container.md) | Command-line tool for modernizing existing .NET and Java applications into containerized applications. Analyzes and builds an inventory of applications running in virtual machines and provides a streamlined process to containerize and deploy them to AWS. |
| [AWS Batch](modules/compute/aws_containers/aws_batch/aws-batch.md) | Fully managed service that enables developers, scientists, and engineers to easily run hundreds of thousands of batch computing jobs on AWS. Dynamically provisions the optimal compute resources based on the volume and resource requirements of submitted batch jobs. |
| [Amazon ECR](modules/compute/aws_containers/aws_ecr/aws-ecr.md) | Fully managed Docker container registry that makes it easy for developers to store, manage, and deploy Docker container images. Integrated with Amazon ECS, Amazon EKS, and AWS Lambda to simplify the development-to-production workflow. |
| [Amazon ECS](modules/compute/aws_containers/aws_ecs/aws-ecs.md) | Fully managed container orchestration service that helps you easily deploy, manage, and scale containerized applications. Deeply integrates with the AWS ecosystem and offers a simpler alternative to more complex orchestration tools like Kubernetes. |
| [Amazon EKS](modules/compute/aws_containers/aws_eks/aws-eks.md) | Managed service that makes it easy to run Kubernetes on AWS without needing to install, operate, and maintain your own Kubernetes control plane. Certified Kubernetes-conformant, so you can use existing tools and plugins from the Kubernetes community. |
| [AWS Containers Overview](modules/compute/aws_containers/aws-container.md) | Containers are a method of OS virtualization that allow you to run an application and its dependencies in resource-isolated processes. AWS offers a range of services for running and managing containers, providing options for different levels of abstraction and control. |

### EC2 & Virtual Machines

| Service | Definition |
|---------|------------|
| [AWS Auto Scaling Groups](modules/compute/aws_EC2s/aws_auto_scaling_grp/aws-auto-scaling-grp.md) | Collection of Amazon EC2 instances treated as a logical grouping for automatic scaling and management. Allows use of EC2 Auto Scaling features such as health check replacements and scaling policies, ensuring the group never goes above or below defined size limits. |
| [Amazon EC2](modules/compute/aws_EC2s/aws_ec2/aws-ec2.md) | Web service that provides secure, resizable compute capacity in the cloud. One of the foundational services of AWS, providing virtual servers (instances) on which you can run your applications. |
| [EC2 Image Builder](modules/compute/aws_EC2s/aws_image_builder/aws-image-builder.md) | Fully managed service that makes it easier to automate the creation, management, and deployment of customized, secure, and up-to-date "golden" server images — both AMIs for EC2 and container images for ECS/EKS. |
| [Amazon Lightsail](modules/compute/aws_EC2s/aws_lightsail/aws-lightsail.md) | Easy-to-use cloud platform that offers everything needed to build an application or website with a cost-effective monthly plan. Designed as the easiest way to get started with AWS, ideal for developers, small businesses, and students needing a simple VPS solution. |

### Serverless

| Service | Definition |
|---------|------------|
| [AWS Fargate](modules/compute/aws_serverless/aws_fargate/aws-fargate.md) | Serverless, pay-as-you-go compute engine that lets you focus on building applications without managing servers. Used with Amazon ECS and Amazon EKS to run containers without managing the underlying EC2 instances. |
| [AWS Lambda](modules/compute/aws_serverless/aws_lambda/aws-lambda.md) | Serverless, event-driven compute service that lets you run code for virtually any type of application or backend service without provisioning or managing servers. Triggered from over 200 AWS services and SaaS applications; you only pay for what you use. |

### Load Balancing

| Service | Definition |
|---------|------------|
| [Elastic Load Balancing (ELB)](modules/compute/aws_elb/aws-elb.md) | Automatically distributes incoming application traffic across multiple targets such as EC2 instances, containers, IP addresses, and Lambda functions to achieve greater fault tolerance and availability. |
| [Application Load Balancer (ALB)](modules/compute/aws_elb/aws_alb/aws-alb.md) | Layer 7 load balancer designed for HTTP and HTTPS traffic with advanced routing capabilities. Ideal for modern application architectures including microservices and containers. |
| [Gateway Load Balancer (GLB)](modules/compute/aws_elb/aws_glb/aws-glb.md) | Layer 3 load balancer that makes it easy to deploy, scale, and manage fleets of third-party virtual network appliances such as firewalls, IDS/IPS, and deep packet inspection systems. |
| [Network Load Balancer (NLB)](modules/compute/aws_elb/aws_nlb/aws-nlb.md) | Layer 4 load balancer capable of handling millions of requests per second with ultra-low latencies. Best suited for TCP, UDP, and TLS traffic where extreme performance is required. |

### Other Compute

| Service | Definition |
|---------|------------|
| [AWS Elastic Beanstalk](modules/compute/aws_elastic_beanstalk/aws-elastic-beanstalk.md) | Easy-to-use service for deploying and scaling web applications and services developed with Java, .NET, PHP, Node.js, Python, Ruby, Go, and Docker on familiar servers such as Apache, Nginx, Passenger, and IIS. |

---

## Databases

### Relational

| Service | Definition |
|---------|------------|
| [Amazon Aurora](modules/databases/relational/aws_aurora/aws-aurora.md) | MySQL and PostgreSQL-compatible relational database built for the cloud, combining the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases. |
| [Amazon RDS](modules/databases/relational/aws_rds/aws-rds.md) | Fully managed relational database service that makes it easy to set up, operate, and scale databases in the cloud. Supports MySQL, PostgreSQL, MariaDB, Oracle Database, and Microsoft SQL Server. |

### Non-Relational

| Service | Definition |
|---------|------------|
| [Amazon DocumentDB](modules/databases/non-relational/aws_documentdb/aws-documentdb.md) | Scalable, highly available, fully managed database service for MongoDB-compatible workloads. Makes it easy to store, query, and index JSON-like data using the MongoDB API with minimal code changes. |
| [Amazon DynamoDB](modules/databases/non-relational/aws_dynamodb/aws-dynamodb.md) | Fully managed, serverless, key-value and document NoSQL database designed to run high-performance applications at any scale. Offers built-in security, backup and restore, and in-memory caching. |
| [Amazon ElastiCache](modules/databases/non-relational/aws_elasticache/aws-elasticache.md) | Fully managed in-memory data store and cache service. Improves web application performance by retrieving information from fast, managed, in-memory caches instead of slower disk-based databases. Supports Redis and Memcached. |

---

## Developer Tools

| Service | Definition |
|---------|------------|
| [AWS Cloud9](modules/developer_tools/aws_cloud9/aws-cloud9.md) | Cloud-based integrated development environment (IDE) that provides a complete development workspace in your browser, combining a code editor, debugger, and terminal with seamless AWS integration. |
| [AWS CloudShell](modules/developer_tools/aws_cloudshell/aws-cloudshell.md) | Browser-based, pre-authenticated shell environment launchable directly from the AWS Management Console. Provides instant command-line access to AWS resources using your existing console credentials without installing the AWS CLI locally. |
| [AWS X-Ray](modules/developer_tools/aws_x-ray/aws-x-ray.md) | Helps developers analyze and debug distributed applications such as those built using microservices architectures. Provides visibility into how your application and its underlying services are performing to identify root causes of issues. |

---

## Frontend, Web & Mobile

| Service | Definition |
|---------|------------|
| [AWS AppSync](modules/frontend_web_and_mobile_devices/aws_appSync/aws-appsync.md) | Fully managed service that makes it easy to develop GraphQL APIs that interact with data from multiple sources. Handles secure connection, efficient data retrieval, and real-time updates so developers can focus on building rich application experiences. |

---

## Management & Governance

| Service | Definition |
|---------|------------|
| [AWS CloudFormation](modules/management_and_governance/aws_cloudFormation/aws-cloudformation.md) | Service that helps you model and set up your AWS resources so you can spend less time managing infrastructure. You create a template describing all resources you want and CloudFormation handles the provisioning and configuration. |
| [AWS Config](modules/management_and_governance/aws_config/aws-config.md) | Service that enables you to assess, audit, and evaluate the configurations of your AWS resources. Continuously monitors and records resource configurations and allows you to automate evaluation against desired configurations for compliance and security. |
| [AWS Control Tower](modules/management_and_governance/aws_launch_wizard_control_tower/aws-control-tower.md) | Service that provides an easy way to set up and govern a secure, multi-account AWS environment ("landing zone"). Automates core account setup, establishes guardrails, and provides ongoing governance based on AWS Organizations best practices. |
| [AWS Health](modules/management_and_governance/aws_health/aws-health.md) | Provides ongoing visibility into the health of your AWS resources and services. Delivers personalized information about events that might affect your application such as scheduled changes, planned maintenance, and service disruptions. |
| [AWS Launch Wizard](modules/management_and_governance/aws_launch_wizard_control_tower/aws-launch-wizard.md) | Service that guides you through the sizing, configuration, and deployment of third-party application workloads on AWS, such as Microsoft SQL Server, SAP HANA, and SAP NetWeaver, according to AWS best practices. |
| [AWS Migration Services](modules/management_and_governance/aws_migration/aws-migration.md) | Comprehensive suite of migration services that help organizations move applications, servers, databases, and data to the AWS Cloud securely and efficiently, including AWS Application Migration Service (MGN) and AWS Server Migration Service (SMS). |
| [AWS OpsWorks](modules/management_and_governance/aws_opsWorks/aws-opsworks.md) | Configuration management service that provides managed instances of Chef and Puppet, allowing you to automate how you configure, deploy, and manage servers and applications in AWS and on-premises. |
| [AWS Organizations](modules/management_and_governance/aws_organizations/aws-organizations.md) | Helps you centrally govern your environment as you grow and scale your AWS resources. Enables programmatic account creation, resource grouping, policy application, and simplified billing through consolidated payment. |
| [AWS Proton](modules/management_and_governance/aws_proton/aws-proton.md) | Fully managed deployment service for container and serverless applications. Enables platform teams to define and share standardized environments and application stacks so development teams can self-service their deployments while maintaining governance. |
| [AWS Service Catalog](modules/management_and_governance/aws_service_catalog_systems_manager_trusted_advisor/aws-service-catalog.md) | Allows organizations to create and manage catalogs of approved IT services on AWS — from virtual machine images and servers to complete multi-tier application architectures — giving administrators centralized control and users quick access to approved services. |
| [AWS Systems Manager](modules/management_and_governance/aws_systems_manager/aws-systems-manager.md) | Collection of capabilities that helps you automate operational tasks for your AWS resources. Provides a unified interface to view operational data from multiple AWS services and automate tasks across your infrastructure. |
| [AWS Trusted Advisor](modules/management_and_governance/aws_service_catalog_systems_manager_trusted_advisor/aws-trusted-advisor.md) | Online tool that provides real-time guidance to help you provision resources following AWS best practices. Inspects your AWS environment and makes recommendations across cost optimization, performance, security, fault tolerance, and service limits. |
| [AWS User Notifications](modules/management_and_governance/aws_user_notifications/aws-user-notifications.md) | Service that consolidates notifications from across AWS services into a central notification center. Allows you to configure rules to receive alerts and messages via email, AWS Chatbot (Slack/Chime), and the AWS Console Mobile Application. |

---

## ML & AI

| Service | Definition |
|---------|------------|
| [Amazon Augmented AI (A2I)](modules/ml_and_ai/aws_augmented_ai/aws-augmented-ai.md) | Makes it easy to build human review workflows required for ML use cases such as content moderation and text extraction from documents. Removes the heavy lifting of building human review systems or managing large numbers of human reviewers. |
| [Amazon Bedrock](modules/ml_and_ai/aws_bedrock/aws-bedrock.md) | Fully managed service offering a choice of high-performing foundation models from leading AI companies via a single API. Provides capabilities to build generative AI applications while maintaining privacy and security. |
| [AWS CodeGuru](modules/ml_and_ai/aws_codeGuru/aws-codeguru.md) | Machine learning-powered service that provides intelligent recommendations to improve code quality and identify an application's most expensive lines of code. Automates code reviews and finds performance issues. |
| [Amazon Comprehend](modules/ml_and_ai/aws_comprehend/aws-comprehend.md) | Natural language processing (NLP) service that uses machine learning to find insights and relationships in text — identifying language, key phrases, entities, sentiment, and topic clusters. |
| [Amazon Comprehend Medical](modules/ml_and_ai/aws_comprehend_medical/aws-comprehend-medical.md) | HIPAA-eligible NLP service that uses machine learning to extract relevant medical information from unstructured clinical text, including medical conditions, medications, dosages, anatomy, and PHI. |
| [AWS DeepComposer](modules/ml_and_ai/aws_deepComposer/aws-deepcomposer.md) | Generative AI music keyboard and cloud-based service designed to help developers get started with machine learning through music composition, using generative adversarial networks (GANs) to create music. |
| [AWS DeepRacer](modules/ml_and_ai/aws_deepRacer/aws-deepracer.md) | 1/18th scale autonomous race car powered by reinforcement learning, designed to help developers of all skill levels get started with RL through a hands-on racing experience in a simulated environment. |
| [AWS DevOps Guru](modules/ml_and_ai/aws_devops_guru/aws-devops-guru.md) | Machine learning powered service that automatically detects operational anomalies (increased latency, error rates, resource saturation) and provides intelligent, actionable recommendations to resolve them. |
| [Amazon Forecast](modules/ml_and_ai/aws_forecast/aws-forecast.md) | Fully managed service that uses machine learning to deliver highly accurate forecasts without requiring prior machine learning experience. Based on the same technology used internally at Amazon.com. |
| [Amazon Fraud Detector](modules/ml_and_ai/aws_fraud_detector/aws-fraud-detector.md) | Fully managed service that makes it easy to identify potentially fraudulent online activities such as payment fraud, identity fraud, and fake account creation using ML and Amazon's fraud detection expertise. |
| [AWS HealthLake](modules/ml_and_ai/aws_healthLake/aws-healthlake.md) | HIPAA-eligible service that stores, transforms, queries, and analyzes health data in the FHIR industry standard format, enabling healthcare organizations to get a complete view of individual or population health. |
| [AWS HealthScribe](modules/ml_and_ai/aws_healthScribe/aws-healthscribe.md) | HIPAA-eligible generative AI service that automatically transcribes patient-clinician conversations and generates rich clinical notes for integration into Electronic Health Records (EHR) systems. |
| [Amazon Kendra](modules/ml_and_ai/aws_kendra/aws-kendra.md) | Intelligent search service powered by machine learning that allows organizations to search across content repositories using natural language, understanding the meaning and user intent beyond simple keyword matching. |
| [Amazon Lex](modules/ml_and_ai/aws_lex/aws-lex.md) | Service for building conversational interfaces using voice and text — the same deep learning technology that powers Amazon Alexa — with automatic speech recognition (ASR) and natural language understanding (NLU). |
| [Amazon Lookout for Equipment](modules/ml_and_ai/aws_lookout_for_equipment/aws-lookout-for-equipment.md) | Machine learning service that uses sensor data to detect abnormal equipment behavior, enabling action before a machine failure occurs to reduce unplanned downtime without requiring ML expertise. |
| [Amazon Lookout for Metrics](modules/ml_and_ai/aws_lookout_for_metrics/aws-lookout-for-metrics.md) | Machine learning service that automatically detects anomalies in business and operational data to help quickly diagnose root causes of issues such as drops in sales or unexpected rises in customer churn. |
| [Amazon Lookout for Vision](modules/ml_and_ai/aws_lookout_for_vision/aws-lookout-for-vision.md) | Machine learning service that automates quality inspection using computer vision to detect defects in industrial products, identify missing components, or spot damage in manufactured goods at scale. |
| [AWS Monitron](modules/ml_and_ai/aws_monitron/aws-monitron.md) | End-to-end system using machine learning to detect abnormal behavior in industrial machinery via wireless sensors, a secure gateway, and ML-powered cloud analysis — enabling predictive maintenance without deep ML expertise. |
| [AWS Panorama](modules/ml_and_ai/aws_panorama/aws-panorama.md) | Machine learning appliance and SDK that allows organizations to bring computer vision to their on-premises cameras for automated inspection and visual assistance decisions, improving quality control and worker safety. |
| [AWS PartyRock](modules/ml_and_ai/aws_party_rock/aws-party-rock.md) | Hands-on, no-code generative AI playground that allows users to quickly build, experiment with, and share mini-apps using Amazon Bedrock foundation models. Designed to make generative AI accessible for rapid prototyping. |
| [Amazon Personalize](modules/ml_and_ai/aws_personalize/aws-personalize.md) | Machine learning service that makes it easy for developers to add sophisticated personalization and recommendation capabilities to their applications without requiring prior ML expertise. |
| [Amazon Polly](modules/ml_and_ai/aws_polly/aws-polly.md) | Cloud service that turns text into lifelike speech. Supports dozens of languages and a wide selection of natural-sounding male and female voices to enable entirely new categories of speech-enabled products. |
| [Amazon Q](modules/ml_and_ai/aws_Q/aws-q.md) | Generative AI-powered assistant designed for work. Answers questions, summarizes content, generates content, and takes actions based on your company's data and enterprise systems, tailored to your security and compliance needs. |
| [Amazon Rekognition](modules/ml_and_ai/aws_rekognition/aws-rekognition.md) | Fully managed computer vision service that uses deep learning to identify objects, people, text, scenes, and activities in images and videos, and to detect inappropriate content. |
| [Amazon SageMaker](modules/ml_and_ai/aws_sageMaker-ai/aws-sagemaker.md) | Fully managed machine learning service that enables developers and data scientists to build, train, and deploy ML models quickly by removing the heavy lifting from each step of the ML process. |
| [Amazon Textract](modules/ml_and_ai/aws_texttract/aws-textract.md) | Machine learning service that automatically extracts text, handwriting, and structured data from scanned documents, going beyond OCR to also identify form fields and table contents without custom code. |
| [Amazon Transcribe](modules/ml_and_ai/aws_transcribe/aws-transcribe.md) | Automatic speech recognition (ASR) service that accurately transcribes audio and video files into text for use cases ranging from customer service call analysis to media production. |
| [Amazon Translate](modules/ml_and_ai/aws_translate/aws-translate.md) | Neural machine translation service that delivers fast, high-quality, and affordable language translation using advanced deep learning models for more natural-sounding results than traditional techniques. |

---

## Monitoring

| Service | Definition |
|---------|------------|
| [AWS CloudTrail](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) | Service that enables governance, compliance, and risk auditing of your AWS account by recording API calls and delivering log files that provide visibility into user activity and resource changes. |
| [Amazon CloudWatch](modules/monitoring/aws_cloudWatch/aws-cloudwatch.md) | Monitoring and observability service that collects metrics, logs, and events from AWS resources, on-premises servers, and hybrid environments, enabling anomaly detection, alerting, log visualization, and automated responses from a single platform. |
| [Amazon Managed Grafana](modules/monitoring/aws_managed_grafana/aws-managed-grafana.md) | Fully managed service for Grafana that allows you to create, operate, and scale Grafana instances to visualize operational data from multiple sources without provisioning servers or performing ongoing maintenance. |
| [Amazon Managed Service for Prometheus](modules/monitoring/aws_managed_prometheus/aws-managed-prometheus.md) | Fully managed, Prometheus-compatible monitoring service that makes it easy to monitor containerized applications and infrastructure at scale using the open-source Prometheus query language (PromQL). |

---

## Networking & Content Delivery

| Service | Definition |
|---------|------------|
| [Amazon API Gateway](modules/networking_content_delivery/aws_api_gateway/aws-api-gateway.md) | Fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. Acts as a front door for applications to access backend services running on EC2, Lambda, or any web application. |
| [AWS App Mesh](modules/networking_content_delivery/aws_app_mesh/aws-app-mesh.md) | Fully managed service mesh that provides application-level networking to make it easy for microservices to communicate across multiple types of compute infrastructure with consistent visibility and traffic control. |
| [Amazon CloudFront](modules/networking_content_delivery/aws_cloudFront/aws-cloudfront.md) | Fast content delivery network (CDN) service that securely delivers data, videos, applications, and APIs to customers globally with low latency and high transfer speeds. |
| [AWS Cloud Map](modules/networking_content_delivery/aws_cloudMap/aws-cloud-map.md) | Cloud resource discovery service that allows you to define custom names for application resources and maintains their updated locations, increasing availability by ensuring services always discover the most current resource endpoints. |
| [AWS Internet Gateway](modules/networking_content_delivery/aws_internet_gateway/aws-internet-gateway.md) | Horizontally scaled, redundant, and highly available VPC component that allows communication between instances in your VPC and the internet. Required for resources in public subnets to access or be accessed from the internet. |
| [AWS PrivateLink](modules/networking_content_delivery/aws_privateLink/aws-privatelink.md) | Provides private connectivity between VPCs, AWS services, and on-premises networks without exposing traffic to the public internet, using private IP addresses to eliminate the need for internet gateways or NAT devices. |
| [Amazon Route 53](modules/networking_content_delivery/aws_route_53/aws-route-53.md) | Highly available and scalable cloud DNS web service that routes end users to internet applications by translating human-readable domain names into IP addresses. |
| [AWS Route Table](modules/networking_content_delivery/aws_route_table/aws-route-table.md) | Contains a set of rules (routes) that determine where network traffic from your subnets or gateway is directed. Each subnet in a VPC must be associated with a route table. |
| [AWS Subnets](modules/networking_content_delivery/aws_vpc/aws-subnets.md) | Range of IP addresses within a VPC into which you launch AWS resources. Enable you to partition your VPC into logical segments for organization, security, and availability across Availability Zones. |
| [AWS Transit Gateway](modules/networking_content_delivery/aws_transit_gateway/aws-transit-gateway.md) | Network transit hub that connects VPCs and on-premises networks through a central hub, acting as a cloud router where each new connection is made only once, eliminating complex peering relationships. |
| [Amazon VPC](modules/networking_content_delivery/aws_vpc/aws-vpc.md) | Enables you to launch AWS resources into a virtual network you define, closely resembling a traditional data center network with complete control over IP address ranges, subnets, route tables, and network gateways. |
| [AWS VPC Lattice](modules/networking_content_delivery/aws_vpc_lattice/aws-vpc-lattice.md) | Fully managed application networking service that simplifies connecting, securing, and monitoring services across multiple VPCs and AWS accounts, providing consistent service-to-service communication regardless of compute type. |

---

## Security, Identity & Compliance

| Service | Definition |
|---------|------------|
| [AWS Artifact](modules/security_identity_compliance/aws_artifact/aws-artifact.md) | Centralized resource for compliance-related information and documentation from AWS. Provides on-demand access to AWS security and compliance reports (SOC, PCI) and online agreements (BAA) to meet regulatory requirements. |
| [AWS Audit Manager](modules/security_identity_compliance/aws_audit_manager/aws-audit-manager.md) | Continuously audits your AWS usage to simplify how you assess risk and compliance with regulations and industry standards. Automates evidence collection and provides pre-built frameworks mapping to PCI DSS, HIPAA, GDPR, and more. |
| [AWS Certificate Manager (ACM)](modules/security_identity_compliance/aws_certificate_manager/aws-certificate-manager.md) | Service that lets you easily provision, manage, and deploy public and private SSL/TLS certificates for AWS services and internal resources, removing the manual process of purchasing, uploading, and renewing certificates. |
| [AWS CloudHSM](modules/security_identity_compliance/aws_cloudHSM/aws-cloudhsm.md) | Provides dedicated, single-tenant hardware security modules (HSMs) in your VPC, giving you exclusive control over cryptographic keys for strong authentication and cryptoprocessing. |
| [Amazon Cognito](modules/security_identity_compliance/aws_cognito/aws-cognito.md) | Provides authentication, authorization, and user management for web and mobile apps. Scales to millions of users and supports sign-in with social identity providers (Facebook, Google, Apple) and enterprise providers (Azure AD via SAML 2.0). |
| [AWS Detective](modules/security_identity_compliance/aws_detective/aws-detective.md) | Security service that automatically collects log data and uses machine learning, statistical analysis, and graph theory to build linked data enabling faster, more efficient security investigations and root-cause analysis. |
| [AWS Directory Service](modules/security_identity_compliance/aws_directory_service/aws-directory-service.md) | Managed service that allows you to connect AWS resources to an existing on-premises Microsoft Active Directory, or set up a standalone directory in the cloud, without deploying and managing domain controllers yourself. |
| [AWS Firewall Manager](modules/security_identity_compliance/aws_firwall_manager/aws-firewall-manager.md) | Security management service that allows you to centrally configure and manage firewall rules — AWS WAF, Shield Advanced, VPC security groups, Network Firewall, and Route 53 DNS Firewall — across all AWS accounts in your organization. |
| [Amazon GuardDuty](modules/security_identity_compliance/aws_guardDuty/aws-guardduty.md) | Threat detection service that continuously monitors AWS accounts and workloads for malicious activity and unauthorized behavior using machine learning, anomaly detection, and integrated threat intelligence. |
| [AWS IAM](modules/security_identity_compliance/aws_iam/aws-iam.md) | Web service that helps you securely control access to AWS resources. Manages who is authenticated (signed in) and authorized (has permissions) to use resources across your AWS environment. |
| [Amazon Inspector](modules/security_identity_compliance/aws_inspector/aws-inspector.md) | Automated vulnerability management service that continuously scans EC2 instances, container images in ECR, and Lambda functions for software vulnerabilities and unintended network exposure. |
| [AWS KMS](modules/security_identity_compliance/aws_kms/aws-kms.md) | Makes it easy to create and manage cryptographic keys and control their use across a wide range of AWS services and applications, using hardware security modules (HSMs) to protect your keys. |
| [Amazon Macie](modules/security_identity_compliance/aws_macie/aws-macie.md) | Data security and privacy service that uses machine learning and pattern matching to discover, classify, and protect sensitive data in AWS S3, detecting potential data security risks and unauthorized access. |
| [AWS Network ACLs](modules/security_identity_compliance/aws_nacl/aws-nacls.md) | Optional layer of security for your VPC that acts as a stateless firewall controlling traffic in and out of one or more subnets at the subnet boundary, enabling powerful network segmentation. |
| [AWS Network Firewall](modules/security_identity_compliance/aws_network_firewall/aws-network-firewall.md) | Fully managed, highly available network security service for your VPC providing essential network protections including intrusion prevention and detection without deploying and managing third-party firewalls. |
| [AWS RAM](modules/security_identity_compliance/aws_ram/aws-ram.md) | Enables you to easily and securely share AWS resources with any AWS account or within your AWS Organization, eliminating resource duplication and reducing operational overhead. |
| [AWS Secrets Manager](modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) | Helps you protect access to applications, services, and IT resources by enabling easy rotation, management, and retrieval of database credentials, API keys, and other secrets throughout their lifecycle. |
| [AWS Security Groups](modules/security_identity_compliance/aws_security_group/aws-security-groups.md) | Stateful virtual firewall for EC2 instances that controls inbound and outbound traffic. Response traffic is automatically allowed regardless of inbound rules, providing instance-level network protection. |
| [AWS Security Hub](modules/security_identity_compliance/aws_security_hub_CSPM/aws-security-hub.md) | Provides a comprehensive view of high-priority security alerts and compliance status across AWS accounts by aggregating and prioritizing findings from GuardDuty, Inspector, Macie, and third-party products. |
| [AWS Security Lake](modules/security_identity_compliance/aws_security_lake/aws-security-lake.md) | Fully managed security data lake that centralizes security data from cloud, on-premises, and custom sources, normalizing it into the Open Cybersecurity Schema Framework (OCSF) for consistent analysis across your organization. |
| [AWS Shield](modules/security_identity_compliance/aws_shield/aws-shield.md) | Managed DDoS protection service that safeguards applications running on AWS with always-on detection and automatic inline mitigations to minimize downtime and latency. Available in Standard and Advanced tiers. |
| [AWS Verified Permissions](modules/security_identity_compliance/aws_verified_permission/aws-verified-permissions.md) | Scalable, fine-grained permissions management service for custom applications. Allows developers to centralize access policies using the Cedar policy language, ensuring consistent, auditable, and manageable permissions. |
| [AWS WAF](modules/security_identity_compliance/aws_waf/aws-waf.md) | Web application firewall that protects web applications and APIs from common exploits such as SQL injection and cross-site scripting. Provides control over traffic based on IP addresses, HTTP headers, and custom URI strings. |

---

## Storage

| Service | Definition |
|---------|------------|
| [AWS Backup](modules/storage/aws_backup/aws-backup.md) | Fully managed, centralized backup service that automates and consolidates backup of data across AWS services and on-premises storage, allowing a single backup plan to apply to any supported resource across your organization. |
| [AWS Database Migration Service (DMS)](modules/storage/aws_database_migration/aws-database-migration.md) | Fully managed cloud service that migrates relational databases, data warehouses, NoSQL databases, and other data stores to AWS with the source database remaining fully operational during migration to minimize downtime. |
| [AWS DataSync](modules/storage/aws_datasync/aws-datasync.md) | Fully managed online data transfer service that automates and accelerates moving data between on-premises storage, edge locations, other cloud providers, and AWS storage services, handling scheduling, monitoring, encryption, and retries. |
| [Amazon EBS](modules/storage/aws_ebs/aws-ebs.md) | Provides persistent block storage volumes for use with Amazon EC2 instances. Behaves like raw, unformatted block devices that can be partitioned, formatted, and mounted. Designed for consistent, low-latency performance and high availability. |
| [Amazon EFS](modules/storage/aws_efs/aws-efs.md) | Fully managed, elastic, cloud-native Network File System (NFS) that automatically grows and shrinks as you add and remove files, eliminating the need for capacity planning and manual scaling. |
| [AWS Lake Formation](modules/storage/aws_lake_formation/aws-lake-formation.md) | Fully managed service that makes it easy to build, secure, and manage data lakes on AWS, providing fine-grained access control down to individual columns and rows enforced consistently across all integrated analytics services. |
| [Amazon S3](modules/storage/aws_s3/aws-s3.md) | Object storage service offering industry-leading scalability, data availability, security, and performance for storing and protecting any amount of data for websites, applications, backup, archival, IoT devices, and big data analytics. |
| [AWS Snow Family](modules/storage/aws_snow_family/aws-snow-family.md) | Collection of physical edge computing and data transfer devices designed to move large amounts of data into and out of AWS where network transfer is too slow, too costly, or unavailable, combining local compute with petabyte-scale offline migration. |
| [AWS Storage Gateway](modules/storage/aws-storage-gateway/aws-storage-gateway.md) | Hybrid cloud storage service that gives on-premises applications access to virtually unlimited AWS cloud storage through standard protocols (NFS, SMB, iSCSI, VTL), providing local cache for low-latency access while tiering cold data to S3, EBS, or Glacier. |
| [AWS Transfer Family](modules/storage/aws_transfer_family/aws-transfer-family.md) | Fully managed file transfer service for SFTP, FTPS, FTP, and AS2 workflows directly into and out of Amazon S3 and EFS without changing clients, scripts, or partners. AWS manages server infrastructure, high availability, and protocol handling. |
