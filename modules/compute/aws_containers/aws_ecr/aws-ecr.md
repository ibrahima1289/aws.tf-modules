# Amazon Elastic Container Registry (ECR)

Amazon Elastic Container Registry (ECR) is a fully managed Docker container registry that makes it easy for developers to store, manage, and deploy Docker container images. ECR is integrated with Amazon Elastic Container Service (ECS), Amazon Elastic Kubernetes Service (EKS), and AWS Lambda, simplifying your development to production workflow.

## Core Concepts

*   **Private and Public Repositories:** ECR provides both private repositories (within your AWS account) and a public gallery for sharing container images with the world.
*   **Highly Available and Secure:** Images are stored in Amazon S3, providing a durable and highly available storage backend. ECR automatically encrypts images at rest and supports transfer over HTTPS.
*   **Integrated with AWS:** ECR has deep integration with IAM for resource-level control of repositories, and works seamlessly with ECS, EKS, Fargate, and App Runner.

## Configuration Options

### 1. Repositories

A repository is where you store your Docker images.

*   **Visibility:**
    *   **Private:** Only accessible to IAM users and roles within your AWS account that have been granted permissions.
    *   **Public:** Anyone can pull images from a public repository.
*   **URI:** Each repository has a unique URI that you use to push and pull images (e.g., `account_id.dkr.ecr.region.amazonaws.com/my-repo`).
*   **Tag Immutability:**
    *   **Mutable (default):** You can overwrite an image tag (e.g., push a new image with the `latest` tag).
    *   **Immutable:** Once an image is pushed with a tag, that tag cannot be overwritten. This is a best practice to ensure that your image tags are unique and that you can reliably roll back to a specific version.
*   **Real-life Example:** You create a private repository called `my-app`. You set tag immutability to `true`. Your CI/CD pipeline builds your application, tags the Docker image with the Git commit hash (e.g., `my-app:a1b2c3d`), and pushes it to your ECR repository.

### 2. Image Scanning

ECR can automatically scan your container images for common vulnerabilities and exposures (CVEs).

*   **Scan on Push:** You can configure your repository to automatically scan an image every time a new one is pushed.
*   **Scan Frequency:** For existing images, you can set up weekly or manual scans.
*   **Findings:** ECR provides a list of vulnerabilities found, along with their severity (e.g., Critical, High, Medium, Low) and a link to the CVE details.
*   **Real-life Example:** You enable "scan on push" for your `my-app` repository. When your CI/CD pipeline pushes a new image, ECR automatically scans it. The pipeline can then be configured to check the scan results and fail the deployment if any "Critical" vulnerabilities are found.

### 3. Lifecycle Policies

Lifecycle policies help you manage the lifecycle of images in your repositories to save on storage costs. You can create rules to automatically clean up old or unused images.

*   **Rule Priority:** Rules are evaluated in order, from lowest to highest.
*   **Rule Criteria:**
    *   **`sinceImagePushed`:** Match images pushed more than a certain number of days ago.
    *   **`imageCountMoreThan`:** Match when the number of images in a repository exceeds a certain count.
    *   **`tagged`:** Match images with a specific tag (or untagged images).
*   **Action:** The only action is `expire`, which deletes the matched images.
*   **Real-life Example:** To keep your repository clean, you can set up a lifecycle policy with two rules:
    1.  **Rule 1 (priority 100):** Keep the 5 most recently pushed images, regardless of their age (`imageCountMoreThan: 5`).
    2.  **Rule 2 (priority 200):** Delete any image tagged with `dev-*` that is older than 14 days (`sinceImagePushed: 14`, `tagged: dev-*`).

### 4. Repository Permissions

You control access to your ECR repositories using IAM policies and repository policies.

*   **IAM Policies:** Grant permissions to users, groups, and roles to perform actions (e.g., `ecr:GetDownloadUrlForLayer`, `ecr:PutImage`) on specific repositories.
*   **Repository Policies:** A resource-based policy that you attach to a repository to grant permissions to other AWS accounts (for cross-account access) or to define public access.
*   **Real-life Example:** You have an ECS task running in your account that needs to pull an image. You would attach an IAM policy to the ECS task role that grants it `ecr:GetDownloadUrlForLayer`, `ecr:BatchGetImage`, and `ecr:BatchCheckLayerAvailability` permissions on the specific ECR repository.

### 5. Replication

ECR supports automatic replication of your repositories to other AWS Regions or other accounts.

*   **Cross-Region Replication:** Automatically replicate your images to another region for disaster recovery or to reduce pull latency for users in different geographic locations.
*   **Cross-Account Replication:** Replicate images to a central "shared services" account.
*   **Real-life Example:** Your primary development region is `us-east-1`, but you have a production environment in `eu-west-1`. You can configure cross-region replication to automatically copy images from your ECR repository in `us-east-1` to a repository in `eu-west-1`, ensuring the images are close to your production compute resources.

## Purpose and Real-Life Use Cases

*   **CI/CD (Continuous Integration/Continuous Deployment):** ECR is a fundamental component of a modern CI/CD pipeline. Your build server (e.g., Jenkins, AWS CodeBuild) builds a Docker image and pushes it to ECR. Your deployment service (e.g., ECS, EKS) then pulls the image from ECR to run it.
*   **Private Software Distribution:** Companies can use ECR to store and distribute their proprietary software as container images to different teams or customers.
*   **Vulnerability Management:** Using ECR's image scanning feature, security teams can enforce policies that prevent the deployment of vulnerable container images.
*   **Serverless Containers:** AWS Lambda can now be packaged as a container image, which you can store in ECR.
