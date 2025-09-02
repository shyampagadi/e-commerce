# VPC and Networking Fundamentals

## Table of Contents
1. [VPC Overview](#vpc-overview)
2. [Subnets and Availability Zones](#subnets-and-availability-zones)
3. [Internet Gateway and NAT](#internet-gateway-and-nat)
4. [Route Tables](#route-tables)
5. [Network Security](#network-security)
6. [VPC Endpoints](#vpc-endpoints)

## VPC Overview

### What is a VPC?
```bash
# Virtual Private Cloud (VPC) Components:
# - Isolated network environment in AWS
# - Complete control over network configuration
# - Spans multiple Availability Zones
# - Supports both IPv4 and IPv6

# Default VPC vs Custom VPC:
# Default VPC: Pre-configured, public subnets, internet gateway
# Custom VPC: Full control, custom CIDR blocks, security
```

### VPC CIDR Block Planning
```bash
# CIDR Block Examples:
# 10.0.0.0/16    - 65,536 IP addresses (10.0.0.0 to 10.0.255.255)
# 172.16.0.0/16  - 65,536 IP addresses (172.16.0.0 to 172.16.255.255)
# 192.168.0.0/16 - 65,536 IP addresses (192.168.0.0 to 192.168.255.255)

# Subnet Planning:
# /24 subnet = 256 IP addresses (251 usable, 5 reserved by AWS)
# /25 subnet = 128 IP addresses (123 usable)
# /26 subnet = 64 IP addresses (59 usable)
# /27 subnet = 32 IP addresses (27 usable)
```

### Create Custom VPC
```bash
# Using AWS CLI
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=Docker-VPC}]'

# Enable DNS hostnames and resolution
aws ec2 modify-vpc-attribute \
    --vpc-id vpc-12345678 \
    --enable-dns-hostnames

aws ec2 modify-vpc-attribute \
    --vpc-id vpc-12345678 \
    --enable-dns-support
```

### VPC Configuration Template
```json
{
  "VPCConfiguration": {
    "VpcId": "vpc-12345678",
    "CidrBlock": "10.0.0.0/16",
    "State": "available",
    "DhcpOptionsId": "dopt-12345678",
    "InstanceTenancy": "default",
    "EnableDnsHostnames": true,
    "EnableDnsSupport": true,
    "Tags": [
      {
        "Key": "Name",
        "Value": "Docker-VPC"
      },
      {
        "Key": "Environment",
        "Value": "Learning"
      },
      {
        "Key": "Purpose",
        "Value": "Container-Deployment"
      }
    ]
  }
}
```

## Subnets and Availability Zones

### Subnet Types and Design
```bash
# Public Subnets:
# - Have route to Internet Gateway
# - Resources get public IP addresses
# - Used for: Load balancers, bastion hosts, NAT gateways

# Private Subnets:
# - No direct route to Internet Gateway
# - Route to NAT Gateway for outbound internet
# - Used for: Application servers, databases

# Database Subnets:
# - Isolated private subnets
# - No internet access (inbound or outbound)
# - Used for: Databases, sensitive data storage
```

### Multi-AZ Subnet Architecture
```bash
# Availability Zone Distribution:
# us-east-1a: Public (10.0.1.0/24), Private (10.0.11.0/24), DB (10.0.21.0/24)
# us-east-1b: Public (10.0.2.0/24), Private (10.0.12.0/24), DB (10.0.22.0/24)
# us-east-1c: Public (10.0.3.0/24), Private (10.0.13.0/24), DB (10.0.23.0/24)

# Benefits:
# - High availability across multiple AZs
# - Fault tolerance for infrastructure failures
# - Load distribution across zones
```

### Create Subnets
```bash
# Public Subnet in AZ-1a
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-1a}]'

# Private Subnet in AZ-1a
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.11.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet-1a}]'

# Database Subnet in AZ-1a
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.21.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=DB-Subnet-1a}]'

# Enable auto-assign public IP for public subnets
aws ec2 modify-subnet-attribute \
    --subnet-id subnet-12345678 \
    --map-public-ip-on-launch
```

### Subnet Configuration Script
```bash
#!/bin/bash
# create-subnets.sh

VPC_ID="vpc-12345678"
REGION="us-east-1"

# Define availability zones
AZS=("us-east-1a" "us-east-1b" "us-east-1c")

# Create subnets for each AZ
for i in "${!AZS[@]}"; do
    AZ=${AZS[$i]}
    AZ_NUM=$((i + 1))
    
    # Public subnet
    PUBLIC_SUBNET=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block 10.0.$AZ_NUM.0/24 \
        --availability-zone $AZ \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=Public-Subnet-$AZ}]" \
        --query 'Subnet.SubnetId' --output text)
    
    # Enable auto-assign public IP
    aws ec2 modify-subnet-attribute \
        --subnet-id $PUBLIC_SUBNET \
        --map-public-ip-on-launch
    
    # Private subnet
    PRIVATE_SUBNET=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block 10.0.$((AZ_NUM + 10)).0/24 \
        --availability-zone $AZ \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=Private-Subnet-$AZ}]" \
        --query 'Subnet.SubnetId' --output text)
    
    # Database subnet
    DB_SUBNET=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block 10.0.$((AZ_NUM + 20)).0/24 \
        --availability-zone $AZ \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=DB-Subnet-$AZ}]" \
        --query 'Subnet.SubnetId' --output text)
    
    echo "Created subnets in $AZ:"
    echo "  Public: $PUBLIC_SUBNET"
    echo "  Private: $PRIVATE_SUBNET"
    echo "  Database: $DB_SUBNET"
done
```

## Internet Gateway and NAT

### Internet Gateway Setup
```bash
# Create Internet Gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=Docker-IGW}]'

# Attach to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Verify attachment
aws ec2 describe-internet-gateways \
    --internet-gateway-ids igw-12345678
```

### NAT Gateway Configuration
```bash
# Allocate Elastic IP for NAT Gateway
aws ec2 allocate-address \
    --domain vpc \
    --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=NAT-Gateway-EIP}]'

# Create NAT Gateway in public subnet
aws ec2 create-nat-gateway \
    --subnet-id subnet-12345678 \
    --allocation-id eipalloc-12345678 \
    --tag-specifications 'ResourceType=nat-gateway,Tags=[{Key=Name,Value=Docker-NAT-Gateway}]'

# Wait for NAT Gateway to be available
aws ec2 wait nat-gateway-available --nat-gateway-ids nat-12345678
```

### High Availability NAT Setup
```bash
#!/bin/bash
# create-nat-gateways.sh

# Create NAT Gateway in each public subnet for HA
PUBLIC_SUBNETS=("subnet-12345678" "subnet-23456789" "subnet-34567890")

for i in "${!PUBLIC_SUBNETS[@]}"; do
    SUBNET=${PUBLIC_SUBNETS[$i]}
    AZ_NUM=$((i + 1))
    
    # Allocate Elastic IP
    EIP_ALLOC=$(aws ec2 allocate-address \
        --domain vpc \
        --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=NAT-EIP-AZ$AZ_NUM}]" \
        --query 'AllocationId' --output text)
    
    # Create NAT Gateway
    NAT_GW=$(aws ec2 create-nat-gateway \
        --subnet-id $SUBNET \
        --allocation-id $EIP_ALLOC \
        --tag-specifications "ResourceType=nat-gateway,Tags=[{Key=Name,Value=NAT-Gateway-AZ$AZ_NUM}]" \
        --query 'NatGateway.NatGatewayId' --output text)
    
    echo "Created NAT Gateway $NAT_GW in AZ $AZ_NUM"
    
    # Wait for NAT Gateway to be available
    aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW
done
```

## Route Tables

### Route Table Concepts
```bash
# Route Table Components:
# - Destination: CIDR block or specific IP
# - Target: Where traffic should be routed
# - Local Route: Always present for VPC CIDR
# - Default Route: 0.0.0.0/0 for internet traffic

# Route Table Types:
# - Main Route Table: Default for VPC
# - Custom Route Tables: Specific routing rules
# - Public Route Table: Routes to Internet Gateway
# - Private Route Table: Routes to NAT Gateway
```

### Create and Configure Route Tables
```bash
# Create public route table
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Public-Route-Table}]'

# Add route to Internet Gateway
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# Associate with public subnets
aws ec2 associate-route-table \
    --route-table-id rtb-12345678 \
    --subnet-id subnet-12345678

# Create private route table
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-Table}]'

# Add route to NAT Gateway
aws ec2 create-route \
    --route-table-id rtb-23456789 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id nat-12345678
```

### Complete Route Table Setup
```bash
#!/bin/bash
# setup-route-tables.sh

VPC_ID="vpc-12345678"
IGW_ID="igw-12345678"

# Public subnets and NAT gateways
PUBLIC_SUBNETS=("subnet-pub1" "subnet-pub2" "subnet-pub3")
PRIVATE_SUBNETS=("subnet-priv1" "subnet-priv2" "subnet-priv3")
NAT_GATEWAYS=("nat-gw1" "nat-gw2" "nat-gw3")

# Create public route table
PUBLIC_RT=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Public-Route-Table}]' \
    --query 'RouteTable.RouteTableId' --output text)

# Add internet route to public route table
aws ec2 create-route \
    --route-table-id $PUBLIC_RT \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Associate public subnets with public route table
for subnet in "${PUBLIC_SUBNETS[@]}"; do
    aws ec2 associate-route-table \
        --route-table-id $PUBLIC_RT \
        --subnet-id $subnet
    echo "Associated $subnet with public route table"
done

# Create private route tables (one per AZ for HA)
for i in "${!PRIVATE_SUBNETS[@]}"; do
    PRIVATE_SUBNET=${PRIVATE_SUBNETS[$i]}
    NAT_GATEWAY=${NAT_GATEWAYS[$i]}
    AZ_NUM=$((i + 1))
    
    # Create private route table
    PRIVATE_RT=$(aws ec2 create-route-table \
        --vpc-id $VPC_ID \
        --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=Private-Route-Table-AZ$AZ_NUM}]" \
        --query 'RouteTable.RouteTableId' --output text)
    
    # Add NAT route
    aws ec2 create-route \
        --route-table-id $PRIVATE_RT \
        --destination-cidr-block 0.0.0.0/0 \
        --nat-gateway-id $NAT_GATEWAY
    
    # Associate private subnet
    aws ec2 associate-route-table \
        --route-table-id $PRIVATE_RT \
        --subnet-id $PRIVATE_SUBNET
    
    echo "Created private route table $PRIVATE_RT for AZ $AZ_NUM"
done
```

## Network Security

### Network ACLs (NACLs)
```bash
# Create custom Network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=network-acl,Tags=[{Key=Name,Value=Web-Tier-NACL}]'

# Add inbound rules
# Allow HTTP (port 80)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0

# Allow HTTPS (port 443)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0

# Allow ephemeral ports for return traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 120 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=1024,To=65535 \
    --cidr-block 0.0.0.0/0

# Add outbound rules
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0 \
    --egress

aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0 \
    --egress
```

### Security Groups
```bash
# Create web tier security group
aws ec2 create-security-group \
    --group-name web-tier-sg \
    --description "Security group for web tier" \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=Web-Tier-SG}]'

# Add inbound rules
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 10.0.0.0/16

# Create application tier security group
aws ec2 create-security-group \
    --group-name app-tier-sg \
    --description "Security group for application tier" \
    --vpc-id vpc-12345678

# Allow traffic from web tier
aws ec2 authorize-security-group-ingress \
    --group-id sg-23456789 \
    --protocol tcp \
    --port 8080 \
    --source-group sg-12345678
```

## VPC Endpoints

### S3 VPC Endpoint
```bash
# Create S3 VPC Endpoint (Gateway type)
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.s3 \
    --vpc-endpoint-type Gateway \
    --route-table-ids rtb-12345678 rtb-23456789

# Verify endpoint
aws ec2 describe-vpc-endpoints \
    --filters Name=service-name,Values=com.amazonaws.us-east-1.s3
```

### ECR VPC Endpoints
```bash
# Create ECR API VPC Endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.ecr.api \
    --vpc-endpoint-type Interface \
    --subnet-ids subnet-12345678 subnet-23456789 \
    --security-group-ids sg-12345678

# Create ECR DKR VPC Endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.ecr.dkr \
    --vpc-endpoint-type Interface \
    --subnet-ids subnet-12345678 subnet-23456789 \
    --security-group-ids sg-12345678
```

### VPC Flow Logs
```bash
# Enable VPC Flow Logs
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name VPCFlowLogs \
    --deliver-logs-permission-arn arn:aws:iam::123456789012:role/flowlogsRole

# Create CloudWatch Log Group
aws logs create-log-group --log-group-name VPCFlowLogs
```

### Network Monitoring Script
```bash
#!/bin/bash
# network-monitoring.sh

echo "=== VPC Network Monitoring ==="

# Check VPC status
echo "VPC Status:"
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,State,CidrBlock]' --output table

# Check subnet utilization
echo "Subnet IP Utilization:"
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,AvailableIpAddressCount]' --output table

# Check NAT Gateway status
echo "NAT Gateway Status:"
aws ec2 describe-nat-gateways --query 'NatGateways[*].[NatGatewayId,State,SubnetId]' --output table

# Check Internet Gateway
echo "Internet Gateway Status:"
aws ec2 describe-internet-gateways --query 'InternetGateways[*].[InternetGatewayId,State]' --output table

# Check VPC Endpoints
echo "VPC Endpoints:"
aws ec2 describe-vpc-endpoints --query 'VpcEndpoints[*].[VpcEndpointId,ServiceName,State]' --output table

echo "=== Monitoring Complete ==="
```

This comprehensive guide covers VPC and networking fundamentals, providing the foundation for secure and scalable container deployments on AWS.
