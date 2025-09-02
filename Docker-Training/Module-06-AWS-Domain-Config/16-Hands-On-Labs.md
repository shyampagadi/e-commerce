# AWS Domain Configuration Hands-On Labs

## Table of Contents
1. [Lab Setup](#lab-setup)
2. [Basic Labs (Beginner)](#basic-labs-beginner)
3. [Intermediate Labs](#intermediate-labs)
4. [Advanced Labs](#advanced-labs)
5. [Lab Solutions](#lab-solutions)
6. [Troubleshooting](#troubleshooting)

## Lab Setup

### Prerequisites
- AWS Account with billing enabled
- AWS CLI installed and configured
- Domain name (can purchase through Route 53)
- Basic understanding of DNS concepts
- Completed Modules 1-5

### Lab Environment Setup
```bash
# Create lab directory
mkdir aws-domain-labs
cd aws-domain-labs

# Create lab structure
mkdir -p {lab01,lab02,lab03,lab04,lab05,lab06,lab07,lab08,lab09,lab10}/solution

# Set AWS region
export AWS_DEFAULT_REGION=us-east-1

# Verify AWS CLI configuration
aws sts get-caller-identity
```

## Basic Labs (Beginner)

### Lab 1: AWS Account and IAM Setup
**Objective**: Set up secure AWS account with proper IAM configuration

**Requirements**:
- Enable MFA for root account
- Create administrative user with MFA
- Set up billing alerts
- Configure AWS CLI

**Tasks**:
1. Enable MFA for root account using virtual device
2. Create IAM user with AdministratorAccess policy
3. Configure MFA for IAM user
4. Set up billing budget with $20 limit
5. Configure AWS CLI with new user credentials

**Expected Output**:
- Root account secured with MFA
- Administrative user with MFA enabled
- Billing alerts configured
- AWS CLI working with new credentials

**Validation Commands**:
```bash
# Test AWS CLI configuration
aws sts get-caller-identity

# Check MFA devices
aws iam list-mfa-devices

# Verify billing alerts
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text)
```

---

### Lab 2: VPC and Networking Setup
**Objective**: Create custom VPC with public and private subnets

**Requirements**:
- Custom VPC with 10.0.0.0/16 CIDR
- Public and private subnets in 2 AZs
- Internet Gateway and NAT Gateway
- Proper route table configuration

**Tasks**:
1. Create VPC with DNS hostnames enabled
2. Create public subnets (10.0.1.0/24, 10.0.2.0/24)
3. Create private subnets (10.0.11.0/24, 10.0.12.0/24)
4. Set up Internet Gateway and attach to VPC
5. Create NAT Gateway in public subnet
6. Configure route tables for public and private subnets

**Expected Output**:
- Functional VPC with internet connectivity
- Public subnets can reach internet directly
- Private subnets can reach internet via NAT Gateway
- Proper DNS resolution working

---

### Lab 3: EC2 Instance Deployment
**Objective**: Deploy containerized application on EC2

**Requirements**:
- EC2 instance in public subnet
- Docker installed and configured
- Security groups properly configured
- Application accessible via public IP

**Tasks**:
1. Create security group allowing HTTP, HTTPS, and SSH
2. Launch EC2 instance with Docker pre-installed
3. Deploy simple containerized web application
4. Configure security group rules
5. Test application accessibility

**Expected Output**:
- EC2 instance running in public subnet
- Docker application accessible via HTTP
- Security groups properly configured
- SSH access working from your IP

---

### Lab 4: Domain Registration and Basic DNS
**Objective**: Register domain and set up basic DNS configuration

**Requirements**:
- Domain registered through Route 53 or external registrar
- Hosted zone created in Route 53
- Basic A record pointing to EC2 instance
- DNS propagation verified

**Tasks**:
1. Register domain name (or use existing)
2. Create hosted zone in Route 53
3. Configure name servers if using external registrar
4. Create A record pointing to EC2 public IP
5. Test DNS resolution

**Expected Output**:
- Domain resolving to EC2 instance
- DNS queries working globally
- Hosted zone properly configured
- Application accessible via domain name

## Intermediate Labs

### Lab 5: SSL/TLS Certificate Setup
**Objective**: Implement HTTPS with AWS Certificate Manager

**Requirements**:
- SSL certificate from AWS Certificate Manager
- Application Load Balancer with HTTPS listener
- HTTP to HTTPS redirect
- Security headers configured

**Tasks**:
1. Request SSL certificate through ACM
2. Validate certificate using DNS validation
3. Create Application Load Balancer
4. Configure HTTPS listener with SSL certificate
5. Set up HTTP to HTTPS redirect
6. Update Route 53 records to point to ALB

**Expected Output**:
- HTTPS working with valid SSL certificate
- HTTP automatically redirects to HTTPS
- SSL Labs rating of A or higher
- Load balancer distributing traffic

---

### Lab 6: CloudFront CDN Implementation
**Objective**: Set up CloudFront distribution for global content delivery

**Requirements**:
- CloudFront distribution with custom domain
- SSL certificate for CloudFront
- Caching policies configured
- Origin shield enabled

**Tasks**:
1. Create CloudFront distribution
2. Configure custom domain with SSL certificate
3. Set up caching behaviors for static and dynamic content
4. Enable compression and HTTP/2
5. Configure custom error pages
6. Update DNS to point to CloudFront

**Expected Output**:
- Global CDN distribution working
- Improved page load times worldwide
- Proper caching headers
- Custom domain working with CloudFront

---

### Lab 7: Multi-Environment Setup
**Objective**: Configure staging and production environments

**Requirements**:
- Separate environments with subdomains
- Different SSL certificates for each environment
- Environment-specific configurations
- Blue-green deployment capability

**Tasks**:
1. Set up staging.yourdomain.com environment
2. Configure production www.yourdomain.com environment
3. Create separate SSL certificates
4. Implement environment-specific configurations
5. Set up blue-green deployment process

**Expected Output**:
- Staging and production environments working
- Separate SSL certificates for each environment
- Environment isolation maintained
- Deployment process documented

---

### Lab 8: Advanced Security Configuration
**Objective**: Implement comprehensive security measures

**Requirements**:
- WAF rules configured
- Security headers implemented
- DDoS protection enabled
- Access logging configured

**Tasks**:
1. Configure AWS WAF with common attack protection
2. Implement security headers (HSTS, CSP, etc.)
3. Enable AWS Shield Advanced (if budget allows)
4. Set up CloudTrail for audit logging
5. Configure VPC Flow Logs
6. Implement rate limiting

**Expected Output**:
- WAF protecting against common attacks
- Security headers properly configured
- Comprehensive logging enabled
- Rate limiting preventing abuse

## Advanced Labs

### Lab 9: Automated Infrastructure Deployment
**Objective**: Use Infrastructure as Code for complete setup

**Requirements**:
- CloudFormation or Terraform templates
- Automated SSL certificate validation
- Complete infrastructure deployment
- Rollback capability

**Tasks**:
1. Create CloudFormation template for entire infrastructure
2. Implement automated certificate validation
3. Set up parameter store for configuration
4. Create deployment pipeline
5. Test rollback procedures

**Expected Output**:
- Complete infrastructure deployable via IaC
- Automated certificate management
- Parameterized configurations
- Tested rollback procedures

---

### Lab 10: Monitoring and Alerting
**Objective**: Implement comprehensive monitoring and alerting

**Requirements**:
- CloudWatch dashboards
- Custom metrics and alarms
- SNS notifications
- Log aggregation and analysis

**Tasks**:
1. Create CloudWatch dashboard for infrastructure
2. Set up custom metrics for application performance
3. Configure alarms for critical thresholds
4. Implement SNS notifications
5. Set up log aggregation with CloudWatch Logs
6. Create automated responses to common issues

**Expected Output**:
- Comprehensive monitoring dashboard
- Proactive alerting for issues
- Automated incident response
- Historical performance data

## Lab Solutions

### Lab 1 Solution: AWS Account and IAM Setup

**Step 1: Enable Root Account MFA**
```bash
# This must be done through AWS Console
# AWS Console → Security Credentials → Multi-factor authentication (MFA)
# Choose "Virtual MFA device" and follow setup process
```

**Step 2: Create Administrative User**
```bash
# Create IAM user
aws iam create-user --user-name admin-user

# Attach AdministratorAccess policy
aws iam attach-user-policy \
    --user-name admin-user \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Create access keys
aws iam create-access-key --user-name admin-user

# Create login profile
aws iam create-login-profile \
    --user-name admin-user \
    --password TempPassword123! \
    --password-reset-required
```

**Step 3: Set Up Billing Budget**
```bash
# Create budget configuration
cat > budget.json << EOF
{
  "BudgetName": "Learning-Budget",
  "BudgetLimit": {
    "Amount": "20.0",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
EOF

# Create notifications configuration
cat > notifications.json << EOF
[
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80.0,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "EMAIL",
        "Address": "your-email@example.com"
      }
    ]
  }
]
EOF

# Create budget
aws budgets create-budget \
    --account-id $(aws sts get-caller-identity --query Account --output text) \
    --budget file://budget.json \
    --notifications-with-subscribers file://notifications.json
```

### Lab 2 Solution: VPC and Networking Setup

**Complete VPC Setup Script**:
```bash
#!/bin/bash
# vpc-setup.sh

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Lab-VPC}]' \
    --query 'Vpc.VpcId' --output text)

# Enable DNS hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support

# Create Internet Gateway
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Lab-IGW}]' \
    --query 'InternetGateway.InternetGatewayId' --output text)

# Attach Internet Gateway
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID

# Create public subnets
PUBLIC_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-1}]' \
    --query 'Subnet.SubnetId' --output text)

PUBLIC_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-2}]' \
    --query 'Subnet.SubnetId' --output text)

# Enable auto-assign public IP
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_1 --map-public-ip-on-launch
aws ec2 modify-subnet-attribute --subnet-id $PUBLIC_SUBNET_2 --map-public-ip-on-launch

# Create private subnets
PRIVATE_SUBNET_1=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.11.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet-1}]' \
    --query 'Subnet.SubnetId' --output text)

PRIVATE_SUBNET_2=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 10.0.12.0/24 \
    --availability-zone us-east-1b \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet-2}]' \
    --query 'Subnet.SubnetId' --output text)

# Create NAT Gateway
EIP_ALLOC=$(aws ec2 allocate-address --domain vpc --query 'AllocationId' --output text)
NAT_GW=$(aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_1 \
    --allocation-id $EIP_ALLOC \
    --tag-specifications 'ResourceType=nat-gateway,Tags=[{Key=Name,Value=Lab-NAT-Gateway}]' \
    --query 'NatGateway.NatGatewayId' --output text)

# Wait for NAT Gateway
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW

# Create route tables
PUBLIC_RT=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Public-Route-Table}]' \
    --query 'RouteTable.RouteTableId' --output text)

PRIVATE_RT=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-Table}]' \
    --query 'RouteTable.RouteTableId' --output text)

# Add routes
aws ec2 create-route --route-table-id $PUBLIC_RT --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
aws ec2 create-route --route-table-id $PRIVATE_RT --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $NAT_GW

# Associate subnets with route tables
aws ec2 associate-route-table --route-table-id $PUBLIC_RT --subnet-id $PUBLIC_SUBNET_1
aws ec2 associate-route-table --route-table-id $PUBLIC_RT --subnet-id $PUBLIC_SUBNET_2
aws ec2 associate-route-table --route-table-id $PRIVATE_RT --subnet-id $PRIVATE_SUBNET_1
aws ec2 associate-route-table --route-table-id $PRIVATE_RT --subnet-id $PRIVATE_SUBNET_2

echo "VPC Setup Complete!"
echo "VPC ID: $VPC_ID"
echo "Public Subnets: $PUBLIC_SUBNET_1, $PUBLIC_SUBNET_2"
echo "Private Subnets: $PRIVATE_SUBNET_1, $PRIVATE_SUBNET_2"
```

### Lab Validation Commands

```bash
# Validate VPC setup
aws ec2 describe-vpcs --vpc-ids $VPC_ID

# Test internet connectivity from public subnet
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t2.micro \
    --subnet-id $PUBLIC_SUBNET_1 \
    --security-group-ids $SECURITY_GROUP_ID \
    --key-name your-key-pair

# Test NAT Gateway functionality
# SSH to instance in private subnet and test internet access
curl -I http://www.google.com
```

## Troubleshooting

### Common Issues and Solutions

**Issue 1: Certificate Validation Failing**
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn arn:aws:acm:region:account:certificate/certificate-id

# Verify DNS records for validation
dig _acme-challenge.yourdomain.com TXT

# Re-request certificate if needed
aws acm request-certificate \
    --domain-name yourdomain.com \
    --subject-alternative-names *.yourdomain.com \
    --validation-method DNS
```

**Issue 2: CloudFront Not Serving Updated Content**
```bash
# Create invalidation
aws cloudfront create-invalidation \
    --distribution-id E1234567890123 \
    --paths "/*"

# Check cache headers
curl -I https://yourdomain.com
```

**Issue 3: Route 53 DNS Not Resolving**
```bash
# Check hosted zone configuration
aws route53 list-hosted-zones

# Verify name servers
dig NS yourdomain.com

# Check specific record
aws route53 list-resource-record-sets --hosted-zone-id Z1234567890123
```

This comprehensive lab series provides hands-on experience with AWS domain configuration from basic setup to advanced production deployments.
