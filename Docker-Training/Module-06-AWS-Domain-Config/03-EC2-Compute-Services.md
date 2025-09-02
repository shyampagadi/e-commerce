# EC2 and Compute Services

## Table of Contents
1. [EC2 Fundamentals](#ec2-fundamentals)
2. [Instance Types and Selection](#instance-types-and-selection)
3. [AMI Management](#ami-management)
4. [Storage Options](#storage-options)
5. [Auto Scaling](#auto-scaling)
6. [Load Balancing](#load-balancing)

## EC2 Fundamentals

### EC2 Instance Lifecycle
```bash
# Instance States:
# pending → running → stopping → stopped → terminating → terminated
# rebooting (temporary state during reboot)

# Launch instance
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --instance-type t3.micro \
    --key-name my-key-pair \
    --security-group-ids sg-12345678 \
    --subnet-id subnet-12345678 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Docker-Server}]'

# Start/Stop instances
aws ec2 start-instances --instance-ids i-1234567890abcdef0
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

### User Data Scripts
```bash
#!/bin/bash
# Docker installation user data script

# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Create application directory
mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

# Start sample application
cat > /opt/app/docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
    restart: unless-stopped
EOF

mkdir -p /opt/app/html
echo "<h1>Docker Server Running on AWS</h1>" > /opt/app/html/index.html
chown -R ec2-user:ec2-user /opt/app

# Start application
cd /opt/app
docker-compose up -d
```

## Instance Types and Selection

### Instance Family Overview
```bash
# General Purpose (T3, T4g, M5, M6i)
# - Balanced CPU, memory, networking
# - Web servers, small databases, development

# Compute Optimized (C5, C6i, C6g)
# - High-performance processors
# - CPU-intensive applications, HPC

# Memory Optimized (R5, R6i, X1e, z1d)
# - Fast performance for memory-intensive workloads
# - In-memory databases, real-time analytics

# Storage Optimized (I3, I4i, D2, H1)
# - High sequential read/write access
# - Distributed file systems, data warehouses

# Accelerated Computing (P3, P4, G4, F1)
# - Hardware accelerators (GPUs, FPGAs)
# - Machine learning, HPC, graphics workstations
```

### Container-Optimized Instance Selection
```bash
# For Docker workloads:

# Development/Testing:
# t3.micro, t3.small - Burstable performance, cost-effective
# 1-2 vCPUs, 1-8 GB RAM

# Production Web Applications:
# m5.large, m5.xlarge - Balanced compute, memory, networking
# 2-4 vCPUs, 8-16 GB RAM

# High-Performance Applications:
# c5.large, c5.xlarge - Compute optimized
# 2-4 vCPUs, 4-8 GB RAM, enhanced networking

# Memory-Intensive Applications:
# r5.large, r5.xlarge - Memory optimized
# 2-4 vCPUs, 16-32 GB RAM

# Example selection script:
WORKLOAD_TYPE="web"
ENVIRONMENT="production"

case $WORKLOAD_TYPE in
    "web")
        if [ "$ENVIRONMENT" = "production" ]; then
            INSTANCE_TYPE="m5.large"
        else
            INSTANCE_TYPE="t3.small"
        fi
        ;;
    "compute")
        INSTANCE_TYPE="c5.large"
        ;;
    "memory")
        INSTANCE_TYPE="r5.large"
        ;;
esac

echo "Recommended instance type: $INSTANCE_TYPE"
```

### Launch Template Configuration
```json
{
  "LaunchTemplateName": "docker-server-template",
  "LaunchTemplateData": {
    "ImageId": "ami-0c02fb55956c7d316",
    "InstanceType": "t3.small",
    "KeyName": "my-key-pair",
    "SecurityGroupIds": ["sg-12345678"],
    "IamInstanceProfile": {
      "Name": "EC2-Docker-Role"
    },
    "UserData": "base64-encoded-user-data-script",
    "BlockDeviceMappings": [
      {
        "DeviceName": "/dev/xvda",
        "Ebs": {
          "VolumeSize": 20,
          "VolumeType": "gp3",
          "DeleteOnTermination": true,
          "Encrypted": true
        }
      }
    ],
    "TagSpecifications": [
      {
        "ResourceType": "instance",
        "Tags": [
          {
            "Key": "Name",
            "Value": "Docker-Server"
          },
          {
            "Key": "Environment",
            "Value": "Production"
          }
        ]
      }
    ],
    "MetadataOptions": {
      "HttpTokens": "required",
      "HttpPutResponseHopLimit": 1,
      "HttpEndpoint": "enabled"
    }
  }
}
```

## AMI Management

### Custom AMI Creation
```bash
# Create AMI from running instance
aws ec2 create-image \
    --instance-id i-1234567890abcdef0 \
    --name "Docker-Server-AMI-$(date +%Y%m%d)" \
    --description "Docker server with pre-installed applications" \
    --no-reboot

# Wait for AMI to be available
aws ec2 wait image-available --image-ids ami-12345678

# Copy AMI to another region
aws ec2 copy-image \
    --source-region us-east-1 \
    --source-image-id ami-12345678 \
    --name "Docker-Server-AMI-Copy" \
    --description "Copy of Docker server AMI" \
    --region us-west-2
```

### AMI Automation Script
```bash
#!/bin/bash
# ami-builder.sh

INSTANCE_ID="i-1234567890abcdef0"
AMI_NAME="Docker-Server-$(date +%Y%m%d-%H%M%S)"
DESCRIPTION="Automated Docker server AMI build"

echo "Creating AMI from instance $INSTANCE_ID..."

# Create AMI
AMI_ID=$(aws ec2 create-image \
    --instance-id $INSTANCE_ID \
    --name "$AMI_NAME" \
    --description "$DESCRIPTION" \
    --no-reboot \
    --query 'ImageId' --output text)

echo "AMI creation initiated: $AMI_ID"

# Wait for AMI to be available
echo "Waiting for AMI to be available..."
aws ec2 wait image-available --image-ids $AMI_ID

# Tag the AMI
aws ec2 create-tags \
    --resources $AMI_ID \
    --tags Key=Name,Value="$AMI_NAME" \
           Key=CreatedBy,Value="Automation" \
           Key=Environment,Value="Production"

# Get AMI details
aws ec2 describe-images --image-ids $AMI_ID

echo "AMI $AMI_ID is ready for use"

# Clean up old AMIs (keep last 5)
echo "Cleaning up old AMIs..."
OLD_AMIS=$(aws ec2 describe-images \
    --owners self \
    --filters Name=name,Values="Docker-Server-*" \
    --query 'Images[?CreationDate<=`2023-01-01`].ImageId' \
    --output text)

for ami in $OLD_AMIS; do
    echo "Deregistering old AMI: $ami"
    aws ec2 deregister-image --image-id $ami
done
```

## Storage Options

### EBS Volume Types
```bash
# General Purpose SSD (gp3) - Default choice
# - 3,000-16,000 IOPS baseline
# - 125-1,000 MB/s throughput
# - Cost-effective for most workloads

# Provisioned IOPS SSD (io2)
# - Up to 64,000 IOPS
# - 99.999% durability
# - Critical business applications

# Throughput Optimized HDD (st1)
# - Up to 500 MB/s throughput
# - Big data, data warehouses, log processing

# Cold HDD (sc1)
# - Lowest cost
# - Infrequently accessed data
```

### EBS Volume Management
```bash
# Create EBS volume
aws ec2 create-volume \
    --size 100 \
    --volume-type gp3 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=Docker-Data}]'

# Attach volume to instance
aws ec2 attach-volume \
    --volume-id vol-12345678 \
    --instance-id i-1234567890abcdef0 \
    --device /dev/sdf

# Format and mount volume (on instance)
sudo mkfs -t xfs /dev/xvdf
sudo mkdir /docker-data
sudo mount /dev/xvdf /docker-data
sudo chown ec2-user:ec2-user /docker-data

# Add to fstab for persistent mounting
echo '/dev/xvdf /docker-data xfs defaults,nofail 0 2' | sudo tee -a /etc/fstab

# Create snapshot
aws ec2 create-snapshot \
    --volume-id vol-12345678 \
    --description "Docker data backup $(date)"
```

### Instance Store Configuration
```bash
# Instance store (ephemeral) storage setup
# Available on certain instance types (m5d, c5d, r5d, etc.)

# Format instance store volumes
sudo mkfs -t xfs /dev/nvme1n1
sudo mkfs -t xfs /dev/nvme2n1

# Create mount points
sudo mkdir -p /mnt/instance-store-0
sudo mkdir -p /mnt/instance-store-1

# Mount volumes
sudo mount /dev/nvme1n1 /mnt/instance-store-0
sudo mount /dev/nvme2n1 /mnt/instance-store-1

# Configure for Docker temporary storage
sudo mkdir -p /mnt/instance-store-0/docker-tmp
sudo chown ec2-user:ec2-user /mnt/instance-store-0/docker-tmp

# Update Docker daemon configuration
sudo tee /etc/docker/daemon.json << EOF
{
  "data-root": "/mnt/instance-store-0/docker",
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker
```

## Auto Scaling

### Auto Scaling Group Configuration
```bash
# Create launch template
aws ec2 create-launch-template \
    --launch-template-name docker-server-template \
    --launch-template-data file://launch-template.json

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name docker-server-asg \
    --launch-template LaunchTemplateName=docker-server-template,Version='$Latest' \
    --min-size 2 \
    --max-size 6 \
    --desired-capacity 3 \
    --vpc-zone-identifier "subnet-12345678,subnet-23456789" \
    --health-check-type ELB \
    --health-check-grace-period 300 \
    --tags Key=Name,Value=Docker-Server,PropagateAtLaunch=true
```

### Scaling Policies
```bash
# Create scale-up policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name docker-server-asg \
    --policy-name scale-up-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration file://scale-up-config.json

# scale-up-config.json
{
  "TargetValue": 70.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  },
  "ScaleOutCooldown": 300,
  "ScaleInCooldown": 300
}

# Create custom metric scaling policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name docker-server-asg \
    --policy-name memory-scale-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
      "TargetValue": 80.0,
      "CustomizedMetricSpecification": {
        "MetricName": "MemoryUtilization",
        "Namespace": "CWAgent",
        "Dimensions": [
          {
            "Name": "AutoScalingGroupName",
            "Value": "docker-server-asg"
          }
        ],
        "Statistic": "Average"
      }
    }'
```

### Lifecycle Hooks
```bash
# Create lifecycle hook for graceful shutdown
aws autoscaling put-lifecycle-hook \
    --lifecycle-hook-name graceful-shutdown \
    --auto-scaling-group-name docker-server-asg \
    --lifecycle-transition autoscaling:EC2_INSTANCE_TERMINATING \
    --heartbeat-timeout 300 \
    --default-result ABANDON \
    --notification-target-arn arn:aws:sns:us-east-1:123456789012:asg-notifications

# Lifecycle hook script (on instance)
cat > /opt/lifecycle-hook.sh << 'EOF'
#!/bin/bash
# Graceful shutdown script

# Get instance ID and lifecycle hook details
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
ASG_NAME="docker-server-asg"
LIFECYCLE_HOOK_NAME="graceful-shutdown"

# Drain containers gracefully
docker ps -q | xargs -r docker stop -t 30

# Remove instance from load balancer targets
# (This would be handled by ALB health checks automatically)

# Complete lifecycle action
aws autoscaling complete-lifecycle-action \
    --lifecycle-hook-name $LIFECYCLE_HOOK_NAME \
    --auto-scaling-group-name $ASG_NAME \
    --instance-id $INSTANCE_ID \
    --lifecycle-action-result CONTINUE
EOF

chmod +x /opt/lifecycle-hook.sh
```

## Load Balancing

### Application Load Balancer Setup
```bash
# Create Application Load Balancer
aws elbv2 create-load-balancer \
    --name docker-server-alb \
    --subnets subnet-12345678 subnet-23456789 \
    --security-groups sg-12345678 \
    --scheme internet-facing \
    --type application \
    --ip-address-type ipv4

# Create target group
aws elbv2 create-target-group \
    --name docker-server-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-12345678 \
    --health-check-protocol HTTP \
    --health-check-path /health \
    --health-check-interval-seconds 30 \
    --health-check-timeout-seconds 5 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3

# Create listener
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/docker-server-alb/1234567890123456 \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/docker-server-targets/1234567890123456

# Register Auto Scaling Group with target group
aws autoscaling attach-load-balancer-target-groups \
    --auto-scaling-group-name docker-server-asg \
    --target-group-arns arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/docker-server-targets/1234567890123456
```

### Health Check Configuration
```bash
# Configure detailed health checks
aws elbv2 modify-target-group \
    --target-group-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/docker-server-targets/1234567890123456 \
    --health-check-protocol HTTP \
    --health-check-path /health \
    --health-check-interval-seconds 15 \
    --health-check-timeout-seconds 10 \
    --healthy-threshold-count 2 \
    --unhealthy-threshold-count 3 \
    --matcher HttpCode=200

# Health check endpoint (in application)
cat > /opt/app/health.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Health Check</title>
</head>
<body>
    <h1>OK</h1>
    <p>Server is healthy</p>
    <p>Timestamp: <span id="timestamp"></span></p>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF
```

### Complete Deployment Script
```bash
#!/bin/bash
# deploy-docker-infrastructure.sh

set -e

# Variables
VPC_ID="vpc-12345678"
SUBNET_IDS="subnet-12345678,subnet-23456789"
SECURITY_GROUP_ID="sg-12345678"
KEY_NAME="my-key-pair"
AMI_ID="ami-0c02fb55956c7d316"

echo "Deploying Docker infrastructure..."

# Create launch template
LAUNCH_TEMPLATE_ID=$(aws ec2 create-launch-template \
    --launch-template-name docker-server-template \
    --launch-template-data '{
        "ImageId": "'$AMI_ID'",
        "InstanceType": "t3.small",
        "KeyName": "'$KEY_NAME'",
        "SecurityGroupIds": ["'$SECURITY_GROUP_ID'"],
        "UserData": "'$(base64 -w 0 user-data.sh)'"
    }' \
    --query 'LaunchTemplate.LaunchTemplateId' --output text)

echo "Created launch template: $LAUNCH_TEMPLATE_ID"

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name docker-server-asg \
    --launch-template LaunchTemplateName=docker-server-template,Version='$Latest' \
    --min-size 2 \
    --max-size 6 \
    --desired-capacity 3 \
    --vpc-zone-identifier "$SUBNET_IDS" \
    --health-check-type ELB \
    --health-check-grace-period 300

echo "Created Auto Scaling Group"

# Create Application Load Balancer
ALB_ARN=$(aws elbv2 create-load-balancer \
    --name docker-server-alb \
    --subnets $(echo $SUBNET_IDS | tr ',' ' ') \
    --security-groups $SECURITY_GROUP_ID \
    --query 'LoadBalancers[0].LoadBalancerArn' --output text)

echo "Created Application Load Balancer: $ALB_ARN"

# Create target group
TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
    --name docker-server-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --health-check-path /health \
    --query 'TargetGroups[0].TargetGroupArn' --output text)

echo "Created target group: $TARGET_GROUP_ARN"

# Create listener
aws elbv2 create-listener \
    --load-balancer-arn $ALB_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN

# Attach ASG to target group
aws autoscaling attach-load-balancer-target-groups \
    --auto-scaling-group-name docker-server-asg \
    --target-group-arns $TARGET_GROUP_ARN

# Create scaling policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name docker-server-asg \
    --policy-name cpu-scaling-policy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration '{
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "ASGAverageCPUUtilization"
        }
    }'

echo "Deployment complete!"
echo "Load Balancer DNS: $(aws elbv2 describe-load-balancers --load-balancer-arns $ALB_ARN --query 'LoadBalancers[0].DNSName' --output text)"
```

This comprehensive guide covers EC2 and compute services for containerized applications, providing the foundation for scalable and resilient deployments on AWS.
