# AWS CloudFormation Configurations

AWS CloudFormation helps you model and set up your Amazon Web Services resources so that you can spend less time managing those resources and more time focusing on your applications that run in AWS. You create a template that describes all the AWS resources that you want (like Amazon EC2 instances or Amazon RDS DB instances), and CloudFormation takes care of provisioning and configuring those resources for you.

A CloudFormation template is a JSON or YAML formatted text file. It comprises several major sections, most of which are optional, but some are essential for defining your AWS infrastructure.

## Template Anatomy

A CloudFormation template can include the following top-level sections:

| Section Name        | Required | Description                                                                                                                                                                                                                                                                   |
| :------------------ | :------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AWSTemplateFormatVersion` | Optional | Specifies the CloudFormation template version. The latest version is `2010-09-09`.                                                                                                                                                                                              |
| `Description`       | Optional | A text string that describes the template.                                                                                                                                                                                                                                    |
| `Metadata`          | Optional | Objects that provide additional information about the template. For example, you can use the `AWS::CloudFormation::Interface` metadata key to define how parameters are grouped and ordered in the CloudFormation console.                                                           |
| `Parameters`        | Optional | Values to pass to your template at runtime (e.g., EC2 instance type, database name). You can reference parameters in the `Resources` and `Outputs` sections of the template.                                                                                                     |
| `Mappings`          | Optional | A static lookup table for values that you can reference in your template. For example, you can use a mapping to choose an AMI ID based on an AWS region.                                                                                                                        |
| `Conditions`        | Optional | Conditional statements that control whether resources are created or properties are assigned a value during stack creation or update. For example, you could create a condition to create a resource only if the stack is being created in a production environment.             |
| `Transform`         | Optional | For serverless applications, specifies the version of the AWS Serverless Application Model (SAM) to use. `Transform` is a macro that processes the template before CloudFormation uses it.                                                                                    |
| `Resources`         | **Required** | The core of your template. This section declares the AWS resources that you want to create in the stack, such as Amazon EC2 instances, Amazon S3 buckets, or Amazon RDS databases. Each resource must include a `Type` and can include `Properties`.                      |
| `Outputs`           | Optional | Values that you can use to view properties of resources in your stack, import into other stacks, or return to the user who created the stack. For example, you could output the public IP address of an EC2 instance.                                                              |

## Key Configuration Elements within Resources

The `Resources` section is the most critical and complex part of a CloudFormation template. Each resource declaration requires a `Type` and often includes `Properties`.

| Resource Property Name | Context | Required | Description                                                                                                                                                                        |
| :--------------------- | :------ | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Type`                 | Resource | **Required** | The type of AWS resource that you want to create (e.g., `AWS::EC2::Instance`, `AWS::S3::Bucket`).                                                                    |
| `Properties`           | Resource | Optional (often required for functionality) | A set of properties that are specific to the resource type. These define the configuration of the resource. The specific properties and their requirements vary greatly by resource type. |
| `Condition`            | Resource | Optional | A logical ID of a condition from the `Conditions` section. If the condition evaluates to `true`, the resource is created; otherwise, it's ignored.                 |
| `CreationPolicy`       | Resource | Optional | Specifies creation-specific base-level policies for a resource. Used for signaling when a resource is ready.                                                      |
| `DeletionPolicy`       | Resource | Optional | Specifies what happens to the resource when the stack is deleted. Options include `Delete` (default), `Retain`, or `Snapshot`.                                   |
| `DependsOn`            | Resource | Optional | Declares that this resource depends on another resource. CloudFormation creates the resources in the correct order.                                                  |
| `Metadata`             | Resource | Optional | Arbitrary metadata about the resource.                                                                                                                               |
| `UpdatePolicy`         | Resource | Optional | Policies to apply when the resource is updated. Used for controlling rolling updates for Auto Scaling groups, for example.                                         |
| `UpdateReplacePolicy`  | Resource | Optional | Specifies what happens to the old resource when CloudFormation has to replace it during an update. Options include `Delete` (default) or `Retain`.                   |







It's important to consult the [AWS CloudFormation User Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) for detailed information on specific resource types and their properties, as requirements can vary significantly.







## Complete Example







This example demonstrates a simple web server setup, including a VPC, a security group, an EC2 instance, and an S3 bucket, utilizing several of the sections mentioned above.







```yaml

AWSTemplateFormatVersion: '2010-09-09'

Description: A comprehensive example CloudFormation template for a simple web server setup.

Metadata:
  Authors:
    - Gemini CLI
  Project: CloudFormation Examples

Parameters:
  EnvironmentName:
    Description: Name of the environment (e.g., dev, prod).
    Type: String
    Default: dev
    AllowedValues:
      - dev
      - prod
    ConstraintDescription: must be either dev or prod.
  
  InstanceType:
    Description: WebServer EC2 instance type.
    Type: String
    Default: t2.micro
    AllowedValues:
      - t2.micro
      - t2.small
      - t2.medium
    ConstraintDescription: must be a valid EC2 instance type.

  LatestAmiId:
    Type: 'AWS::SSM::Parameter::Value<AWS::EC2::Image::Id>'
    Default: '/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2'
    Description: ID of the latest Amazon Linux 2 AMI.

  S3BucketName:
    Description: Name for the S3 bucket.
    Type: String
    Default: my-unique-example-bucket-12345
    ConstraintDescription: Must be a globally unique S3 bucket name.

Mappings:
  RegionMap:
    us-east-1:
      AMI: ami-0abcdef1234567890
      TestAz: us-east-1a
    us-west-2:
      AMI: ami-0fedcba9876543210
      TestAz: us-west-2a

Conditions:
  CreateProdResources: !Equals [!Ref EnvironmentName, prod]

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsSupport: true
      EnableDnsHostnames: true
      Tags:
        - Key: Name
          Value: !Sub "${EnvironmentName}-VPC"

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Enable HTTP access via port 80 and SSH access via port 22
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
      Tags:
        - Key: Name
          Value: !Sub "${EnvironmentName}-WebServerSecurityGroup"

  WebServerInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: !Ref LatestAmiId # Using SSM Parameter for latest AMI
      InstanceType: !Ref InstanceType
      NetworkInterfaces:
        - DeviceIndex: '0'
          AssociatePublicIpAddress: 'true'
          GroupSet:
            - !Ref WebServerSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub "${EnvironmentName}-WebServer"
      UserData:
        Fn::Base64: |
          #!/bin/bash
          yum update -y
          yum install -y httpd
          systemctl start httpd
          systemctl enable httpd
          echo "<h1>Hello from CloudFormation!</h1>" > /var/www/html/index.html

  # Conditional S3 Bucket creation
  ProdS3Bucket:
    Type: AWS::S3::Bucket
    Condition: CreateProdResources
    Properties:
      BucketName: !Ref S3BucketName
      Tags:
        - Key: Environment
          Value: !Ref EnvironmentName
        - Key: Purpose
          Value: ProductionDataStorage

Outputs:
  VPCId:
    Description: The ID of the newly created VPC.
    Value: !Ref VPC
  WebServerPublicIp:
    Description: Public IP address of the WebServer EC2 instance.
    Value: !GetAtt WebServerInstance.PublicIp
  S3BucketNameOutput:
    Description: Name of the S3 bucket (only if in prod environment).
    Value: !If
      - CreateProdResources
      - !Ref ProdS3Bucket
      - "No production S3 bucket created."

```
