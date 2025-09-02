# Automation and Infrastructure as Code

## Overview
Automate AWS infrastructure deployment using CloudFormation, Terraform, and AWS CDK.

## CloudFormation Templates

### Complete Application Stack
```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Complete web application infrastructure'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
  
  InstanceType:
    Type: String
    Default: t3.micro
    AllowedValues: [t3.micro, t3.small, t3.medium]

Mappings:
  EnvironmentMap:
    dev:
      MinSize: 1
      MaxSize: 2
      DesiredCapacity: 1
    staging:
      MinSize: 2
      MaxSize: 4
      DesiredCapacity: 2
    prod:
      MinSize: 3
      MaxSize: 10
      DesiredCapacity: 3

Resources:
  # VPC
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}-VPC"

  # Internet Gateway
  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}-IGW"

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  # Subnets
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: 10.0.1.0/24
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName} Public Subnet (AZ1)"

  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: 10.0.2.0/24
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName} Private Subnet (AZ1)"

  # Route Tables
  PublicRouteTable:
    Type: AWS::EC2::RouteTable
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName} Public Routes"

  DefaultPublicRoute:
    Type: AWS::EC2::Route
    DependsOn: InternetGatewayAttachment
    Properties:
      RouteTableId: !Ref PublicRouteTable
      DestinationCidrBlock: 0.0.0.0/0
      GatewayId: !Ref InternetGateway

  PublicSubnet1RouteTableAssociation:
    Type: AWS::EC2::SubnetRouteTableAssociation
    Properties:
      RouteTableId: !Ref PublicRouteTable
      SubnetId: !Ref PublicSubnet1

  # Auto Scaling Group
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateName: !Sub "${AWS::StackName}-template"
      LaunchTemplateData:
        ImageId: ami-0abcdef1234567890
        InstanceType: !Ref InstanceType
        SecurityGroupIds:
          - !Ref InstanceSecurityGroup
        IamInstanceProfile:
          Arn: !GetAtt InstanceProfile.Arn
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            yum update -y
            yum install -y docker
            systemctl start docker
            systemctl enable docker
            docker run -d -p 80:3000 myapp:latest

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier:
        - !Ref PublicSubnet1
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      MinSize: !FindInMap [EnvironmentMap, !Ref Environment, MinSize]
      MaxSize: !FindInMap [EnvironmentMap, !Ref Environment, MaxSize]
      DesiredCapacity: !FindInMap [EnvironmentMap, !Ref Environment, DesiredCapacity]
      TargetGroupARNs:
        - !Ref TargetGroup
      HealthCheckType: ELB
      HealthCheckGracePeriod: 300

Outputs:
  VPCId:
    Description: VPC ID
    Value: !Ref VPC
    Export:
      Name: !Sub "${AWS::StackName}-VPC-ID"
      
  LoadBalancerDNS:
    Description: Load Balancer DNS Name
    Value: !GetAtt ApplicationLoadBalancer.DNSName
```

### Nested Stacks
```yaml
# master-stack.yaml
Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-templates/network.yaml
      Parameters:
        Environment: !Ref Environment
        
  DatabaseStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-templates/database.yaml
      Parameters:
        VPCId: !GetAtt NetworkStack.Outputs.VPCId
        PrivateSubnets: !GetAtt NetworkStack.Outputs.PrivateSubnets
        
  ApplicationStack:
    Type: AWS::CloudFormation::Stack
    DependsOn: DatabaseStack
    Properties:
      TemplateURL: https://s3.amazonaws.com/my-templates/application.yaml
      Parameters:
        VPCId: !GetAtt NetworkStack.Outputs.VPCId
        PublicSubnets: !GetAtt NetworkStack.Outputs.PublicSubnets
        DatabaseEndpoint: !GetAtt DatabaseStack.Outputs.DatabaseEndpoint
```

## Terraform Configuration

### Main Infrastructure
```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  environment    = var.environment
  vpc_cidr      = var.vpc_cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  availability_zones = var.availability_zones
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security"
  
  vpc_id = module.vpc.vpc_id
  environment = var.environment
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  security_groups = [module.security_groups.alb_sg_id]
  certificate_arn = var.certificate_arn
}

# Auto Scaling Group
module "asg" {
  source = "./modules/asg"
  
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnets
  security_groups      = [module.security_groups.web_sg_id]
  target_group_arn     = module.alb.target_group_arn
  instance_type        = var.instance_type
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
}

# RDS Database
module "rds" {
  source = "./modules/rds"
  
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  security_groups     = [module.security_groups.db_sg_id]
  db_instance_class   = var.db_instance_class
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}
```

### VPC Module
```hcl
# modules/vpc/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)
  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
    Type = "Public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
    Type = "Private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

### Variables and Outputs
```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}
```

## AWS CDK (TypeScript)

### Application Stack
```typescript
// lib/app-stack.ts
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import * as autoscaling from 'aws-cdk-lib/aws-autoscaling';
import * as rds from 'aws-cdk-lib/aws-rds';
import { Construct } from 'constructs';

export class AppStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // VPC
    const vpc = new ec2.Vpc(this, 'VPC', {
      maxAzs: 2,
      natGateways: 1,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: 'Public',
          subnetType: ec2.SubnetType.PUBLIC,
        },
        {
          cidrMask: 24,
          name: 'Private',
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
        },
      ],
    });

    // Security Groups
    const albSg = new ec2.SecurityGroup(this, 'ALBSecurityGroup', {
      vpc,
      description: 'Security group for ALB',
      allowAllOutbound: true,
    });

    albSg.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(80),
      'Allow HTTP traffic'
    );

    albSg.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(443),
      'Allow HTTPS traffic'
    );

    const webSg = new ec2.SecurityGroup(this, 'WebSecurityGroup', {
      vpc,
      description: 'Security group for web servers',
      allowAllOutbound: true,
    });

    webSg.addIngressRule(
      albSg,
      ec2.Port.tcp(80),
      'Allow traffic from ALB'
    );

    // Application Load Balancer
    const alb = new elbv2.ApplicationLoadBalancer(this, 'ALB', {
      vpc,
      internetFacing: true,
      securityGroup: albSg,
    });

    const listener = alb.addListener('Listener', {
      port: 80,
      defaultAction: elbv2.ListenerAction.fixedResponse(200, {
        contentType: 'text/plain',
        messageBody: 'OK',
      }),
    });

    // Launch Template
    const launchTemplate = new ec2.LaunchTemplate(this, 'LaunchTemplate', {
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T3,
        ec2.InstanceSize.MICRO
      ),
      machineImage: ec2.MachineImage.latestAmazonLinux(),
      securityGroup: webSg,
      userData: ec2.UserData.forLinux(),
    });

    launchTemplate.userData.addCommands(
      'yum update -y',
      'yum install -y docker',
      'systemctl start docker',
      'systemctl enable docker',
      'docker run -d -p 80:3000 myapp:latest'
    );

    // Auto Scaling Group
    const asg = new autoscaling.AutoScalingGroup(this, 'ASG', {
      vpc,
      launchTemplate,
      minCapacity: 1,
      maxCapacity: 5,
      desiredCapacity: 2,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
      },
    });

    // Target Group
    const targetGroup = new elbv2.ApplicationTargetGroup(this, 'TargetGroup', {
      vpc,
      port: 80,
      targets: [asg],
      healthCheckPath: '/health',
    });

    listener.addTargetGroups('DefaultTargetGroup', {
      targetGroups: [targetGroup],
    });

    // RDS Database
    const database = new rds.DatabaseInstance(this, 'Database', {
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_15_4,
      }),
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T3,
        ec2.InstanceSize.MICRO
      ),
      vpc,
      credentials: rds.Credentials.fromGeneratedSecret('postgres'),
      multiAz: false,
      allocatedStorage: 20,
      storageEncrypted: true,
      deletionProtection: false,
      backupRetention: cdk.Duration.days(7),
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
      },
    });

    // Outputs
    new cdk.CfnOutput(this, 'LoadBalancerDNS', {
      value: alb.loadBalancerDnsName,
      description: 'DNS name of the load balancer',
    });

    new cdk.CfnOutput(this, 'DatabaseEndpoint', {
      value: database.instanceEndpoint.hostname,
      description: 'Database endpoint',
    });
  }
}
```

## Deployment Automation

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
    paths: ['infrastructure/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Init
      run: terraform init
      working-directory: ./infrastructure
    
    - name: Terraform Plan
      run: terraform plan -var-file="environments/prod.tfvars"
      working-directory: ./infrastructure
    
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: terraform apply -auto-approve -var-file="environments/prod.tfvars"
      working-directory: ./infrastructure
```

### Deployment Script
```bash
#!/bin/bash
# deploy.sh

set -e

ENVIRONMENT=${1:-dev}
REGION=${2:-us-east-1}

echo "Deploying to $ENVIRONMENT environment in $REGION"

# Validate CloudFormation template
aws cloudformation validate-template \
    --template-body file://infrastructure/main.yaml \
    --region $REGION

# Deploy stack
aws cloudformation deploy \
    --template-file infrastructure/main.yaml \
    --stack-name myapp-$ENVIRONMENT \
    --parameter-overrides \
        Environment=$ENVIRONMENT \
        InstanceType=t3.micro \
    --capabilities CAPABILITY_IAM \
    --region $REGION \
    --tags \
        Environment=$ENVIRONMENT \
        Project=MyApp \
        ManagedBy=CloudFormation

# Get outputs
aws cloudformation describe-stacks \
    --stack-name myapp-$ENVIRONMENT \
    --region $REGION \
    --query 'Stacks[0].Outputs'

echo "Deployment completed successfully!"
```
