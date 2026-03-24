# AWS Module & Service List

Complete list of all Terraform modules and wrapper plans available in this repository, organised by AWS service category.

> Back to [README](README.md)

---

## Coverage Summary

| Metric | Count |
|--------|-------|
|**Total AWS Services Documented** | **132** |
|**Terraform Modules Available** | **37** |
|**Resource Guides Available** | **130** |

---

## Modules

| AWS Service Type | Module Name | Documentation Link | Resource Guide | Terraform |
|------------------|-------------|-------------------|----------------|-----------|
| **Cloud Financial Management** | Budget | [Budget Module](modules/cloud_financial_management/aws_budget/README.md) | [Budget Overview](modules/cloud_financial_management/aws_budget/aws-budget.md) | ✅ [aws_budgets_budget](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) |
| **Analytics** | Athena | - | [Athena Overview](modules/analytics/aws_athena/aws-athena.md) | ✅ [aws_athena_workgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) |
| | EMR (MapReduce) | - | [EMR Overview](modules/analytics/aws_mapreduce/aws-emr.md) | ✅ [aws_emr_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster) |
| | Glue | - | [Glue Overview](modules/analytics/aws_glue/aws-glue.md) | ✅ [aws_glue_catalog_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_catalog_database) |
| | Kinesis | [Kinesis Module](modules/analytics/aws_kinesis/README.md) | [Kinesis Overview](modules/analytics/aws_kinesis/aws-kinesis.md) | ✅ [aws_kinesis_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) |
| | Lake Formation | - | [Lake Formation Overview](modules/storage/aws_lake_formation/aws-lake-formation.md) | ✅ [aws_lakeformation_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_resource) |
| | MSK | [MSK Module](modules/analytics/aws-msk/README.md) | [MSK Overview](modules/analytics/aws-msk/aws-msk.md) | ✅ [aws_msk_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) |
| | OpenSearch Service | - | [OpenSearch Overview](modules/analytics/aws_opensearch_service/aws-opensearch.md) | ✅ [aws_opensearch_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) |
| | QuickSight | - | [QuickSight Overview](modules/analytics/aws_quicksight/aws-quicksight.md) | ✅ [aws_quicksight_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_data_source) |
| | Redshift | - | [Redshift Overview](modules/analytics/aws_redshift/aws-redshift.md) | ✅ [aws_redshift_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster) |
| **Application Integration** | EventBridge | - | [EventBridge Overview](modules/application_integration/aws_eventbridge/aws-eventbridge.md) | ✅ [aws_cloudwatch_event_bus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) |
| | MQ | [MQ Module](modules/application_integration/aws_mq/README.md) | [MQ Overview](modules/application_integration/aws_mq/aws-mq.md) | ✅ [aws_mq_broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) |
| | SNS | [SNS Module](modules/application_integration/aws_sns/README.md) | [SNS Overview](modules/application_integration/aws_sns/aws-sns.md) | ✅ [aws_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) |
| | SQS | [SQS Module](modules/application_integration/aws_sqs/README.md) | [SQS Overview](modules/application_integration/aws_sqs/aws-sqs.md) | ✅ [aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) |
| | Step Functions | [Step Functions Module](modules/application_integration/aws_step_function/README.md) | [Step Functions Overview](modules/application_integration/aws_step_function/aws-step-functions.md) | ✅ [aws_sfn_state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) |
| **Compute** | ALB | [ALB Module](modules/compute/aws_elb/aws_alb/README.md) | [ALB Overview](modules/compute/aws_elb/aws_alb/aws-alb.md) | ✅ [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| | App Runner | - | [App Runner Overview](modules/compute/aws_containers/aws_app_runner/aws-app-runner.md) | ✅ [aws_apprunner_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service) |
| | App2Container | - | [App2Container Overview](modules/compute/aws_containers/aws_app2container/aws-app2container.md) | — Migration tool: `app2container containerize` |
| | ASG | [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) | [ASG Overview](modules/compute/aws_EC2s/aws_auto_scaling_grp/aws-auto-scaling-grp.md) | ✅ [aws_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) |
| | Batch | [Batch Module](modules/compute/aws_containers/aws_batch/README.md) | [Batch Overview](modules/compute/aws_containers/aws_batch/aws-batch.md) | ✅ [aws_batch_compute_environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) |
| | Containers Overview | - | [Containers Overview](modules/compute/aws_containers/aws-container.md) | — See ECS, EKS, Fargate, ECR |
| | EC2 | [EC2 Module](modules/compute/aws_EC2s/aws_ec2/README.md) | [EC2 Overview](modules/compute/aws_EC2s/aws_ec2/aws-ec2.md) | ✅ [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| | ECR | - | [ECR Overview](modules/compute/aws_containers/aws_ecr/aws-ecr.md) | ✅ [aws_ecr_repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) |
| | ECS | - | [ECS Overview](modules/compute/aws_containers/aws_ecs/aws-ecs.md) | ✅ [aws_ecs_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) |
| | EKS | - | [EKS Overview](modules/compute/aws_containers/aws_eks/aws-eks.md) | ✅ [aws_eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) |
| | Elastic Beanstalk | - | [Elastic Beanstalk Overview](modules/compute/aws_elastic_beanstalk/aws-elastic-beanstalk.md) | ✅ [aws_elastic_beanstalk_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_application) |
| | ELB Overview | - | [ELB Overview](modules/compute/aws_elb/aws-elb.md) | — See ALB, NLB, GWLB |
| | Fargate | - | [Fargate Overview](modules/compute/aws_serverless/aws_fargate/aws-fargate.md) | ✅ [aws_ecs_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) |
| | GWLB | [GWLB Module](modules/compute/aws_elb/aws_glb/README.md) | [GLB Overview](modules/compute/aws_elb/aws_glb/aws-glb.md) | ✅ [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| | Image Builder | - | [Image Builder Overview](modules/compute/aws_EC2s/aws_image_builder/aws-image-builder.md) | ✅ [aws_imagebuilder_image_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/imagebuilder_image_pipeline) |
| | Lambda | [Lambda Module](modules/compute/aws_serverless/aws_lambda/README.md) | [Lambda Overview](modules/compute/aws_serverless/aws_lambda/aws-lambda.md) | ✅ [aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) |
| | Lightsail | - | [Lightsail Overview](modules/compute/aws_EC2s/aws_lightsail/aws-lightsail.md) | ✅ [aws_lightsail_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lightsail_instance) |
| | NLB | [NLB Module](modules/compute/aws_elb/aws_nlb/README.md) | [NLB Overview](modules/compute/aws_elb/aws_nlb/aws-nlb.md) | ✅ [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| **Databases** | Aurora | [Aurora Module](modules/databases/relational/aws_aurora/README.md) | [Aurora Overview](modules/databases/relational/aws_aurora/aws-aurora.md) | ✅ [aws_rds_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) |
| | DocumentDB | [DocumentDB Module](modules/databases/non-relational/aws_documentdb/README.md) | [DocumentDB Overview](modules/databases/non-relational/aws_documentdb/aws-documentdb.md) | ✅ [aws_docdb_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) |
| | DynamoDB | [DynamoDB Module](modules/databases/non-relational/aws_dynamodb/README.md) | [DynamoDB Overview](modules/databases/non-relational/aws_dynamodb/aws-dynamodb.md) | ✅ [aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) |
| | ElastiCache | [ElastiCache Module](modules/databases/non-relational/aws_elasticache/README.md) | [ElastiCache Overview](modules/databases/non-relational/aws_elasticache/aws-elasticache.md) | ✅ [aws_elasticache_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) |
| | RDS | [RDS Module](modules/databases/relational/aws_rds/README.md) | [RDS Overview](modules/databases/relational/aws_rds/aws-rds.md) | ✅ [aws_db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) |
| **Developer Tools** | Cloud9 | - | [Cloud9 Overview](modules/developer_tools/aws_cloud9/aws-cloud9.md) | ✅ [aws_cloud9_environment_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloud9_environment_ec2) |
| | CloudShell | - | [CloudShell Overview](modules/developer_tools/aws_cloudshell/aws-cloudshell.md) | — Browser-based shell; no TF resource |
| | X-Ray | - | [X-Ray Overview](modules/developer_tools/aws_x-ray/aws-x-ray.md) | ✅ [aws_xray_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/xray_group) |
| **Frontend & Mobile** | AppSync | - | [AppSync Overview](modules/frontend_web_and_mobile_devices/aws_appSync/aws-appsync.md) | ✅ [aws_appsync_graphql_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appsync_graphql_api) |
| **Management & Governance** | Application Migration (MGN) | - | [Migration Overview](modules/management_and_governance/aws_migration/aws-migration.md) | ✅ [aws_mgn](https://docs.aws.amazon.com/mgn/latest/ug/what-is-application-migration-service.html) |
| | CloudFormation | - | [CloudFormation Overview](modules/management_and_governance/aws_cloudFormation/aws-cloudformation.md) | ✅ [aws_cloudformation_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) |
| | Config | - | [Config Overview](modules/management_and_governance/aws_config/aws-config.md) | ✅ [aws_config_configuration_recorder](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) |
| | Control Tower | - | [Control Tower Overview](modules/management_and_governance/aws_launch_wizard_control_tower/aws-control-tower.md) | ✅ [aws_controltower_landing_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/controltower_landing_zone) |
| | Health | - | [Health Overview](modules/management_and_governance/aws_health/aws-health.md) | — Read-only service dashboard |
| | Launch Wizard | - | [Launch Wizard Overview](modules/management_and_governance/aws_launch_wizard_control_tower/aws-launch-wizard.md) | — GUI-based deployment wizard |
| | OpsWorks | - | [OpsWorks Overview](modules/management_and_governance/aws_opsWorks/aws-opsworks.md) | ✅ [aws_opsworks_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opsworks_stack) |
| | Organizations | [Organizations Module](modules/management_and_governance/aws_organizations/README.md) | [Organizations Overview](modules/management_and_governance/aws_organizations/aws-organizations.md) | ✅ [aws_organizations_organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) |
| | Proton | - | [Proton Overview](modules/management_and_governance/aws_proton/aws-proton.md) | ✅ [aws_proton_environment_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/proton_environment_template) |
| | Server Migration — 6 R's | - | [6 R's Strategy](modules/management_and_governance/aws_migration/aws-migration.md#the-6-rs-of-aws-migration-strategy) | — Architectural strategy guide |
| | Service Catalog | - | [Service Catalog Overview](modules/management_and_governance/aws_service_catalog_systems_manager_trusted_advisor/aws-service-catalog.md) | ✅ [aws_servicecatalog_portfolio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicecatalog_portfolio) |
| | Systems Manager | - | [Systems Manager Overview](modules/management_and_governance/aws_systems_manager/aws-systems-manager.md) | ✅ [aws_ssm_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) |
| | Trusted Advisor | - | [Trusted Advisor Overview](modules/management_and_governance/aws_service_catalog_systems_manager_trusted_advisor/aws-trusted-advisor.md) | — Console/API only; no TF resource |
| | User Notifications | - | [User Notifications Overview](modules/management_and_governance/aws_user_notifications/aws-user-notifications.md) | — Notification management; no TF resource |
| **Migration & Transfer** | DataSync | - | [DataSync Overview](modules/storage/aws_datasync/aws-datasync.md) | ✅ [aws_datasync_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) |
| | Database Migration (DMS) | - | [DMS Overview](modules/storage/aws_database_migration/aws-database-migration.md) | ✅ [aws_dms_replication_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance) |
| | Transfer Family | - | [Transfer Family Overview](modules/storage/aws_transfer_family/aws-transfer-family.md) | ✅ [aws_transfer_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_server) |
| **ML & AI** | Amazon Q | - | [Amazon Q Overview](modules/ml_and_ai/aws_Q/aws-q.md) | — Generative AI assistant; no TF resource |
| | Augmented AI (A2I) | - | [Augmented AI Overview](modules/ml_and_ai/aws_augmented_ai/aws-augmented-ai.md) | ✅ [aws_sagemaker_human_task_ui](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_human_task_ui) |
| | Bedrock | - | [Bedrock Overview](modules/ml_and_ai/aws_bedrock/aws-bedrock.md) | ✅ [aws_bedrock_model_invocation_logging_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_model_invocation_logging_configuration) |
| | CodeGuru | - | [CodeGuru Overview](modules/ml_and_ai/aws_codeGuru/aws-codeguru.md) | ✅ [aws_codegurureviewer_repository_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codegurureviewer_repository_association) |
| | Comprehend | - | [Comprehend Overview](modules/ml_and_ai/aws_comprehend/aws-comprehend.md) | — Managed NLP API; no TF resource |
| | Comprehend Medical | - | [Comprehend Medical Overview](modules/ml_and_ai/aws_comprehend_medical/aws-comprehend-medical.md) | — Managed medical NLP API; no TF resource |
| | DeepComposer | - | [DeepComposer Overview](modules/ml_and_ai/aws_deepComposer/aws-deepcomposer.md) | — Hardware device; no TF resource |
| | DeepRacer | - | [DeepRacer Overview](modules/ml_and_ai/aws_deepRacer/aws-deepracer.md) | — Racing simulator; no TF resource |
| | DevOps Guru | - | [DevOps Guru Overview](modules/ml_and_ai/aws_devops_guru/aws-devops-guru.md) | ✅ [aws_devopsguru_resource_collection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/devopsguru_resource_collection) |
| | Forecast | - | [Forecast Overview](modules/ml_and_ai/aws_forecast/aws-forecast.md) | — Managed forecasting API; no TF resource |
| | Fraud Detector | - | [Fraud Detector Overview](modules/ml_and_ai/aws_fraud_detector/aws-fraud-detector.md) | ✅ [aws_frauddetector_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/frauddetector_detector) |
| | HealthLake | - | [HealthLake Overview](modules/ml_and_ai/aws_healthLake/aws-healthlake.md) | ✅ [aws_healthlake_fhir_datastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/healthlake_fhir_datastore) |
| | HealthScribe | - | [HealthScribe Overview](modules/ml_and_ai/aws_healthScribe/aws-healthscribe.md) | — Managed clinical notes AI; no TF resource |
| | Kendra | - | [Kendra Overview](modules/ml_and_ai/aws_kendra/aws-kendra.md) | ✅ [aws_kendra_index](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kendra_index) |
| | Lex | - | [Lex Overview](modules/ml_and_ai/aws_lex/aws-lex.md) | ✅ [aws_lexv2models_bot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lexv2models_bot) |
| | Lookout for Equipment | - | [Lookout for Equipment Overview](modules/ml_and_ai/aws_lookout_for_equipment/aws-lookout-for-equipment.md) | ✅ [aws_lookoutequipment_dataset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lookoutequipment_dataset) |
| | Lookout for Metrics | - | [Lookout for Metrics Overview](modules/ml_and_ai/aws_lookout_for_metrics/aws-lookout-for-metrics.md) | ✅ [aws_lookoutmetrics_anomaly_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lookoutmetrics_anomaly_detector) |
| | Lookout for Vision | - | [Lookout for Vision Overview](modules/ml_and_ai/aws_lookout_for_vision/aws-lookout-for-vision.md) | ✅ [aws_lookoutvision_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lookoutvision_project) |
| | Monitron | - | [Monitron Overview](modules/ml_and_ai/aws_monitron/aws-monitron.md) | — Hardware IoT device; no TF resource |
| | Panorama | - | [Panorama Overview](modules/ml_and_ai/aws_panorama/aws-panorama.md) | — Edge hardware device; no TF resource |
| | PartyRock | - | [PartyRock Overview](modules/ml_and_ai/aws_party_rock/aws-party-rock.md) | — No-code AI playground; no TF resource |
| | Personalize | - | [Personalize Overview](modules/ml_and_ai/aws_personalize/aws-personalize.md) | ✅ [aws_personalize_schema](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/personalize_schema) |
| | Polly | - | [Polly Overview](modules/ml_and_ai/aws_polly/aws-polly.md) | — Text-to-speech API; no TF resource |
| | Rekognition | - | [Rekognition Overview](modules/ml_and_ai/aws_rekognition/aws-rekognition.md) | — Computer vision API; no TF resource |
| | SageMaker AI | - | [SageMaker AI Overview](modules/ml_and_ai/aws_sageMaker-ai/aws-sagemaker.md) | ✅ [aws_sagemaker_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain) |
| | Textract | - | [Textract Overview](modules/ml_and_ai/aws_texttract/aws-textract.md) | — Document extraction API; no TF resource |
| | Transcribe | - | [Transcribe Overview](modules/ml_and_ai/aws_transcribe/aws-transcribe.md) | — Speech-to-text API; no TF resource |
| | Translate | - | [Translate Overview](modules/ml_and_ai/aws_translate/aws-translate.md) | — Translation API; no TF resource |
| **Monitoring** | CloudTrail | [CloudTrail Module](modules/monitoring/aws_cloudtrail/README.md) | [CloudTrail Overview](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) | ✅ [aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) |
| | CloudWatch | [CloudWatch Module](modules/monitoring/aws_cloudwatch/README.md) | [CloudWatch Overview](modules/monitoring/aws_cloudwatch/aws-cloudwatch.md) | ✅ [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| | Managed Grafana | - | [Managed Grafana Overview](modules/monitoring/aws_managed_grafana/aws-managed-grafana.md) | ✅ [aws_grafana_workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace) |
| | Managed Prometheus | - | [Managed Prometheus Overview](modules/monitoring/aws_managed_prometheus/aws-managed-prometheus.md) | ✅ [aws_prometheus_workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) |
| **Networking/CDN** | API Gateway | [API Gateway Module](modules/networking_content_delivery/aws_api_gateway/README.md) | [API Gateway Overview](modules/networking_content_delivery/aws_api_gateway/aws-api-gateway.md) | ✅ [aws_apigatewayv2_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) |
| | App Mesh | - | [App Mesh Overview](modules/networking_content_delivery/aws_app_mesh/aws-app-mesh.md) | ✅ [aws_appmesh_mesh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_mesh) |
| | Cloud Map | - | [Cloud Map Overview](modules/networking_content_delivery/aws_cloudMap/aws-cloud-map.md) | ✅ [aws_service_discovery_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) |
| | CloudFront | [CloudFront Module](modules/networking_content_delivery/aws_cloudFront/README.md) | [CloudFront Overview](modules/networking_content_delivery/aws_cloudFront/aws-cloudfront.md) | ✅ [aws_cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) |
| | Internet Gateway | [Internet Gateway Module](modules/networking_content_delivery/aws_internet_gateway/README.md) | [Internet Gateway Overview](modules/networking_content_delivery/aws_internet_gateway/aws-internet-gateway.md) | ✅ [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| | PrivateLink | - | [PrivateLink Overview](modules/networking_content_delivery/aws_privateLink/aws-privatelink.md) | ✅ [aws_vpc_endpoint_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) |
| | Route 53 | [Route 53 Module](modules/networking_content_delivery/aws_route_53/README.md) | [Route 53 Overview](modules/networking_content_delivery/aws_route_53/aws-route-53.md) | ✅ [aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) |
| | Route Table | [Route Table Module](modules/networking_content_delivery/aws_route_table/README.md) | [Route Table Overview](modules/networking_content_delivery/aws_route_table/aws-route-table.md) | ✅ [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| | Subnets | - | [Subnets Overview](modules/networking_content_delivery/aws_vpc/aws-subnets.md) | ✅ [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) |
| | Transit Gateway | - | [Transit Gateway Overview](modules/networking_content_delivery/aws_transit_gateway/aws-transit-gateway.md) | ✅ [aws_ec2_transit_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) |
| | VPC | [VPC Module](modules/networking_content_delivery/aws_vpc/README.md) | [VPC Overview](modules/networking_content_delivery/aws_vpc/aws-vpc.md) | ✅ [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| | VPC Lattice | - | [VPC Lattice Overview](modules/networking_content_delivery/aws_vpc_lattice/aws-vpc-lattice.md) | ✅ [aws_vpclattice_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service) |
| **Security** | Artifact | - | [Artifact Overview](modules/security_identity_compliance/aws_artifact/aws-artifact.md) | — Compliance reports portal; no TF resource |
| | Audit Manager | - | [Audit Manager Overview](modules/security_identity_compliance/aws_audit_manager/aws-audit-manager.md) | ✅ [aws_auditmanager_framework](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/auditmanager_framework) |
| | Certificate Manager (ACM) | [Certificate Manager Module](modules/security_identity_compliance/aws_certificate_manager/README.md) | [ACM Overview](modules/security_identity_compliance/aws_certificate_manager/aws-certificate-manager.md) | ✅ [aws_acm_certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) |
| | CloudHSM | - | [CloudHSM Overview](modules/security_identity_compliance/aws_cloudHSM/aws-cloudhsm.md) | ✅ [aws_cloudhsm_v2_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudhsm_v2_cluster) |
| | Cognito | - | [Cognito Overview](modules/security_identity_compliance/aws_cognito/aws-cognito.md) | ✅ [aws_cognito_user_pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) |
| | Detective | - | [Detective Overview](modules/security_identity_compliance/aws_detective/aws-detective.md) | ✅ [aws_detective_graph](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/detective_graph) |
| | Directory Service | - | [Directory Service Overview](modules/security_identity_compliance/aws_directory_service/aws-directory-service.md) | ✅ [aws_directory_service_directory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_directory) |
| | Firewall Manager | [Firewall Manager Module](modules/security_identity_compliance/aws_firwall_manager/README.md) | [Firewall Manager Overview](modules/security_identity_compliance/aws_firwall_manager/aws-firewall-manager.md) | ✅ [aws_fms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_policy) |
| | GuardDuty | - | [GuardDuty Overview](modules/security_identity_compliance/aws_guardDuty/aws-guardduty.md) | ✅ [aws_guardduty_detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) |
| | IAM | [IAM Module](modules/security_identity_compliance/aws_iam/README.md) | [IAM Overview](modules/security_identity_compliance/aws_iam/aws-iam.md) | ✅ [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| | Inspector | - | [Inspector Overview](modules/security_identity_compliance/aws_inspector/aws-inspector.md) | ✅ [aws_inspector2_enabler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler) |
| | KMS | [KMS Module](modules/security_identity_compliance/aws_kms/README.md) | [KMS Overview](modules/security_identity_compliance/aws_kms/aws-kms.md) | ✅ [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| | Macie | - | [Macie Overview](modules/security_identity_compliance/aws_macie/aws-macie.md) | ✅ [aws_macie2_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_account) |
| | NACLs | [NACL Module](modules/security_identity_compliance/aws_nacl/README.md) | [NACLs Overview](modules/security_identity_compliance/aws_nacl/aws-nacls.md) | ✅ [aws_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) |
| | Network Firewall | [Network Firewall Module](modules/security_identity_compliance/aws_network_firewall/README.md) | [Network Firewall Overview](modules/security_identity_compliance/aws_network_firewall/aws-network-firewall.md) | ✅ [aws_networkfirewall_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) |
| | RAM | - | [RAM Overview](modules/security_identity_compliance/aws_ram/aws-ram.md) | ✅ [aws_ram_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) |
| | Secrets Manager | [Secrets Manager Module](modules/security_identity_compliance/aws_secrets_manager/README.md) | [Secrets Manager Overview](modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) | ✅ [aws_secretsmanager_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) |
| | Security Group | [Security Group Module](modules/security_identity_compliance/aws_security_group/README.md) | [Security Groups Overview](modules/security_identity_compliance/aws_security_group/aws-security-groups.md) | ✅ [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| | Security Hub | - | [Security Hub Overview](modules/security_identity_compliance/aws_security_hub_CSPM/aws-security-hub.md) | ✅ [aws_securityhub_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) |
| | Security Lake | - | [Security Lake Overview](modules/security_identity_compliance/aws_security_lake/aws-security-lake.md) | ✅ [aws_securitylake_data_lake](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securitylake_data_lake) |
| | Shield | [Shield Module](modules/security_identity_compliance/aws_shield/README.md) | [Shield Overview](modules/security_identity_compliance/aws_shield/aws-shield.md) | ✅ [aws_shield_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) |
| | Verified Permissions | - | [Verified Permissions Overview](modules/security_identity_compliance/aws_verified_permission/aws-verified-permissions.md) | ✅ [aws_verifiedpermissions_policy_store](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/verifiedpermissions_policy_store) |
| | WAF | [WAF Module](modules/security_identity_compliance/aws_waf/README.md) | [WAF Overview](modules/security_identity_compliance/aws_waf/aws-waf.md) | ✅ [aws_wafv2_web_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) |
| **Storage** | Backup | - | [Backup Overview](modules/storage/aws_backup/aws-backup.md) | ✅ [aws_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) |
| | EBS | - | [EBS Overview](modules/storage/aws_ebs/aws-ebs.md) | ✅ [aws_ebs_volume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) |
| | EFS | - | [EFS Overview](modules/storage/aws_efs/aws-efs.md) | ✅ [aws_efs_file_system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) |
| | S3 | [S3 Module](modules/storage/aws_s3/README.md) | [S3 Overview](modules/storage/aws_s3/aws-s3.md) | ✅ [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) |
| | Snow Family | - | [Snow Family Overview](modules/storage/aws_snow_family/aws-snow-family.md) | Physical device — order via Console or CLI: `aws snowball create-job` |
| | Storage Gateway | - | [Storage Gateway Overview](modules/storage/aws-storage-gateway/aws-storage-gateway.md) | ✅ [aws_storagegateway_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway) |

> Each module directory contains its own README file with usage instructions, input/output variables, and examples.

---

## Wrappers (Examples)

Wrapper plans are available under `tf-plans/` to demonstrate usage with sensible defaults and example `terraform.tfvars` files.

| Wrapper | Module | Description |
|---------|--------|-------------|
| [tf-plans/aws_alb](tf-plans/aws_alb/README.md) | ALB | Application Load Balancer; multi-ALB via `albs` |
| [tf-plans/aws_api_gateway](tf-plans/aws_api_gateway/README.md) | API Gateway | HTTP/WebSocket APIs; integrations, routes, stages |
| [tf-plans/aws_asg](tf-plans/aws_asg/README.md) | ASG | Auto Scaling Groups; multi-ASG via `asgs`; hooks & policies |
| [tf-plans/aws_aurora](tf-plans/aws_aurora/README.md) | Aurora | Aurora MySQL/PostgreSQL; provisioned, Serverless v1/v2, global databases; auto-scaling |
| [tf-plans/aws_batch](tf-plans/aws_batch/README.md) | Batch | Compute environments, job queues, job definitions; EC2/SPOT/FARGATE support |
| [tf-plans/aws_budget](tf-plans/aws_budget/README.md) | Budget | Multiple budgets (COST/USAGE/RI/Savings Plans); multi-tier notifications; automated IAM/SCP/SSM actions |
| [tf-plans/aws_certificate_manager](tf-plans/aws_certificate_manager/README.md) | Certificate Manager (ACM) | Multiple ACM certificates (public/imported); optional DNS validation; map-based scaling |
| [tf-plans/aws_cloudfront](tf-plans/aws_cloudfront/README.md) | CloudFront | CDN distributions; S3/custom origins; cache behaviors; SSL/TLS certificates |
| [tf-plans/aws_cloudtrail](tf-plans/aws_cloudtrail/README.md) | CloudTrail | Trails; management events; data events (S3/Lambda/DynamoDB); standard and advanced event selectors; Insights anomaly detection; CloudWatch Logs delivery; KMS encryption; log file validation |
| [tf-plans/aws_cloudwatch](tf-plans/aws_cloudwatch/README.md) | CloudWatch | Log groups; standard + expression-based metric alarms; composite alarms; dashboards (inline `jsonencode()` or external `.json` files via `file()`); log metric filters; log subscription filters |
| [tf-plans/aws_documentdb](tf-plans/aws_documentdb/README.md) | DocumentDB | MongoDB-compatible clusters; multi-node HA; I/O-Optimized storage; custom parameter groups; CloudWatch log exports |
| [tf-plans/aws_dynamodb](tf-plans/aws_dynamodb/README.md) | DynamoDB | NoSQL tables; on-demand/provisioned billing; GSI/LSI; streams, TTL, global tables |
| [tf-plans/aws_ec2](tf-plans/aws_ec2/README.md) | EC2 | Instances; AMIs, EBS, networking examples |
| [tf-plans/aws_elasticache](tf-plans/aws_elasticache/README.md) | ElastiCache | Redis/Memcached/Valkey clusters; replication groups; HA, cluster mode, encryption |
| [tf-plans/aws_firewall_manager](tf-plans/aws_firewall_manager/README.md) | Firewall Manager | Multi-policy FMS: WAFv2, Shield Advanced, Network Firewall, DNS Firewall, Security Groups — org-wide or scoped to accounts/OUs via `include_map`/`exclude_map` |
| [tf-plans/aws_glb](tf-plans/aws_glb/README.md) | GWLB | Gateway Load Balancer; multi-GLB via `glbs` |
| [tf-plans/aws_iam](tf-plans/aws_iam/README.md) | IAM | Users, groups, policies; access keys & console options |
| [tf-plans/aws_internet_gateway](tf-plans/aws_internet_gateway/README.md) | Internet Gateway | IGW attach examples; route integration |
| [tf-plans/aws_kinesis](tf-plans/aws_kinesis/README.md) | Kinesis | Data streams; shards, retention, encryption |
| [tf-plans/aws_kms](tf-plans/aws_kms/README.md) | KMS | Keys, aliases, grants; rotation options |
| [tf-plans/aws_lambda](tf-plans/aws_lambda/README.md) | Lambda | Functions; Zip/Image; VPC/IAM integrations |
| [tf-plans/aws_mq](tf-plans/aws_mq/README.md) | MQ | Message brokers; ActiveMQ/RabbitMQ |
| [tf-plans/aws_msk](tf-plans/aws_msk/README.md) | MSK | Managed Kafka clusters; configurations |
| [tf-plans/aws_nacl](tf-plans/aws_nacl/README.md) | NACL | Multi-NACL subnet associations; stateless ingress/egress rule sets (IPv4/IPv6) |
| [tf-plans/aws_network_firewall](tf-plans/aws_network_firewall/README.md) | Network Firewall | Multi-firewall via `firewalls` list; all four rule source types (stateless 5-tuple, Suricata IPS, domain lists, stateful 5-tuple); dual-destination logging; AZ-keyed endpoint ID outputs for route table wiring |
| [tf-plans/aws_nlb](tf-plans/aws_nlb/README.md) | NLB | Network Load Balancer; multi-NLB via `nlbs`; cross-zone option |
| [tf-plans/aws_organizations](tf-plans/aws_organizations/README.md) | Organizations | Organization bootstrap/adoption; multi-OU, multi-account, policies, and policy attachments |
| [tf-plans/aws_rds](tf-plans/aws_rds/README.md) | RDS | Relational databases; MySQL/PostgreSQL/MariaDB/Oracle/SQL Server; Multi-AZ, read replicas, autoscaling |
| [tf-plans/aws_route_53](tf-plans/aws_route_53/README.md) | Route 53 | Zones & records; alias examples |
| [tf-plans/aws_route_table](tf-plans/aws_route_table/README.md) | Route Table | Routes, associations; VPC/Subnet wiring |
| [tf-plans/aws_s3](tf-plans/aws_s3/README.md) | S3 | Buckets; SSE-KMS/SSE-S3 options; logging examples |
| [tf-plans/aws_secrets_manager](tf-plans/aws_secrets_manager/README.md) | Secrets Manager | Multiple secrets (credentials, API keys, config bundles); optional rotation via Lambda, resource-based policies, multi-region replication |
| [tf-plans/aws_sec_grp](tf-plans/aws_sec_grp/README.md) | Security Group | Security rules; ingress/egress configurations |
| [tf-plans/aws_shield](tf-plans/aws_shield/README.md) | Shield Advanced | DDoS protections, protection groups (ALL/BY_RESOURCE_TYPE/ARBITRARY), DRT access, proactive engagement |
| [tf-plans/aws_sns](tf-plans/aws_sns/README.md) | SNS | Topics; subscriptions; message publishing |
| [tf-plans/aws_sqs](tf-plans/aws_sqs/README.md) | SQS | Queues; FIFO/standard; DLQ support |
| [tf-plans/aws_step_function](tf-plans/aws_step_function/README.md) | Step Functions | State machines; STANDARD/EXPRESS types; logging, tracing, encryption |
| [tf-plans/aws_vpc](tf-plans/aws_vpc/README.md) | VPC | Virtual networks; subnets, CIDR blocks |
| [tf-plans/aws_waf](tf-plans/aws_waf/README.md) | WAF | Multiple Web ACLs (REGIONAL/CLOUDFRONT); IP sets; regex pattern sets; AWS managed rule groups; rate-based rules; geo match rules; IP blocklists; logging to Kinesis Firehose |

> All modules consistently tag resources with a `CreatedDate` sourced from a one-time timestamp via the `time_static` provider.  
> Modules that support multi-resource creation (e.g., ALB via `albs`, NLB via `nlbs`, GWLB via `glbs`, ASG via `asgs`, CloudWatch resources via `log_groups`, `metric_alarms`, `dashboards`, etc.) expose outputs as maps keyed by the resource key.
