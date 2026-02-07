# Amazon Augmented AI (A2I)

Amazon Augmented AI (A2I) makes it easy to build the human review workflows required for many machine learning (ML) use cases, such as content moderation and text extraction from documents. A2I brings human review to all developers, removing the undifferentiated heavy lifting associated with building human review systems or managing large numbers of human reviewers.

## Core Concepts

*   **Human-in-the-Loop ML:** A2I is designed to facilitate human review of predictions made by machine learning models.
*   **Quality and Accuracy:** Improves the accuracy of ML predictions by ensuring that humans review uncertain or problematic cases.
*   **Workflow Automation:** Automates the creation and management of human review workflows.
*   **Integrated with SageMaker:** Integrates directly with Amazon SageMaker, as well as with other AWS services and custom ML models.

## Key Components and Configuration

### 1. Human Review Workflow (Flow Definition)

A human review workflow (also called a flow definition) defines the steps and conditions for human review.

*   **Task Type:** Specifies the type of human review task (e.g., image moderation, document processing).
*   **Worker Task Template:** This is the user interface that human workers will see. You can use AWS-provided templates or create your own custom templates. The template defines:
    *   **Instructions:** Guidance for the workers.
    *   **Input fields:** Where the data to be reviewed is displayed.
    *   **Output fields:** Where workers submit their decisions.
    *   **Real-life Example:** For content moderation, the template might show an image, ask workers to identify inappropriate content, and provide options to categorize it.
*   **Worker Pool:** Specifies the group of human workers who will perform the review tasks. You can use:
    *   **Amazon Mechanical Turk:** A crowdsourcing marketplace for a large, on-demand workforce.
    *   **Vendor Workforces:** Managed workforces provided by AWS Marketplace vendors.
    *   **Private Workforce:** Your own employees or contractors.
*   **Real-life Example:** You define a human review workflow for moderating user-uploaded images. The task template provides instructions and display the image. Workers from a private workforce (your internal team) are assigned to review.

### 2. HumanLoopConfig

This section of the flow definition defines when a human review loop is triggered.

*   **Human Review Condition:** Specifies the criteria that trigger a human review. This can be based on confidence scores from an ML model or random sampling.
    *   **Confidence Threshold:** If an ML model's prediction confidence is below a certain threshold (e.g., 90%), send it for human review.
    *   **Random Sampling:** Send a percentage of predictions for human review, regardless of confidence, for quality assurance.
*   **Max Number of Results:** The maximum number of human review tasks to generate.
*   **Real-life Example:** Your sentiment analysis model flags a comment as negative with 60% confidence. If your `HumanLoopConfig` is set to trigger human review for all predictions below 70% confidence, this comment will be sent to a human for review.

### 3. Integrations

A2I integrates with other AWS services that generate ML predictions.

*   **Amazon SageMaker:** Integrate A2I directly into SageMaker inference pipelines.
    *   **Real-life Example:** A SageMaker model predicts sentiment. If the model's confidence is low, A2I automatically creates a human review task for a worker to verify the sentiment.
*   **Amazon Textract:** Integrate A2I with Textract for document processing.
    *   **Real-life Example:** Textract extracts data from invoices. If Textract has low confidence in extracting a specific field (e.g., `invoice_total`), A2I sends that field for human review.
*   **Amazon Rekognition:** Integrate A2I with Rekognition for content moderation.
    *   **Real-life Example:** Rekognition detects potentially inappropriate images. If its confidence score is below your threshold, A2I routes these images to human reviewers for final verification.
*   **Custom Models:** You can also integrate A2I with your own custom ML models deployed outside of SageMaker.

### 4. Human Loop Activation

*   **API Calls:** You activate human loops programmatically through the A2I API.
*   **HumanLoopInput:** The data that needs to be reviewed by a human.
*   **Real-life Example:** Your application calls a Lambda function after a user uploads an image. The Lambda function uses the Rekognition API. If Rekognition's confidence is low, the Lambda function then calls the A2I API to start a human review loop with the image and Rekognition's initial findings as input.

### 5. Task Output

*   **S3 Bucket:** The results of human review tasks (e.g., worker answers, timestamps) are stored in an S3 bucket you specify.
*   **Real-life Example:** After a human worker reviews a flagged image and categorizes it as "acceptable," A2I saves this decision to an S3 bucket. Your application can then retrieve this result and act upon it.

## Purpose and Real-Life Use Cases

*   **Content Moderation:** Reviewing user-generated content (images, videos, text) for appropriateness, brand safety, or policy violations.
*   **Document Processing:** Verifying extracted data from documents (invoices, forms, receipts) where OCR confidence is low or the data is complex.
*   **Sentiment Analysis and Entity Recognition:** Correcting ML model predictions for natural language processing tasks.
*   **Data Labeling Verification:** Ensuring the accuracy of labeled datasets used for training ML models.
*   **Quality Assurance for ML:** Providing a safety net for ML models, ensuring that high-stakes predictions are reviewed by humans.
*   **Financial Document Verification:** Reviewing details on loan applications or insurance claims.

Amazon A2I simplifies the process of integrating human intelligence into your machine learning workflows, leading to more accurate models and improved customer experiences.
