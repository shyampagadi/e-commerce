# EC2 Deep Dive

## Overview

Amazon Elastic Compute Cloud (EC2) provides scalable virtual machines in the cloud. This document covers EC2 instance types, pricing models, networking, security, and best practices for optimal performance and cost.

## Table of Contents

- [Instance Types and Families](#instance-types-and-families)
- [Pricing Models](#pricing-models)
- [Networking and Security](#networking-and-security)
- [Storage Options](#storage-options)
- [Monitoring and Management](#monitoring-and-management)
- [Best Practices](#best-practices)

## Instance Types and Families

### General Purpose Instances

#### T3/T4g Instances
- **Use Case**: Variable workloads with burstable performance
- **CPU**: Up to 2 vCPUs
- **Memory**: Up to 8 GB
- **Network**: Up to 5 Gbps
- **Storage**: EBS only

#### M5/M5a/M5n Instances
- **Use Case**: General-purpose applications
- **CPU**: Up to 96 vCPUs
- **Memory**: Up to 384 GB
- **Network**: Up to 25 Gbps
- **Storage**: EBS only

### Compute Optimized Instances

#### C5/C5n Instances
- **Use Case**: CPU-intensive applications
- **CPU**: Up to 96 vCPUs
- **Memory**: Up to 192 GB
- **Network**: Up to 25 Gbps
- **Storage**: EBS only

### Memory Optimized Instances

#### R5/R5a/R5n Instances
- **Use Case**: Memory-intensive applications
- **CPU**: Up to 96 vCPUs
- **Memory**: Up to 768 GB
- **Network**: Up to 25 Gbps
- **Storage**: EBS only

### Storage Optimized Instances

#### I3/I3en Instances
- **Use Case**: High I/O applications
- **CPU**: Up to 64 vCPUs
- **Memory**: Up to 512 GB
- **Network**: Up to 25 Gbps
- **Storage**: NVMe SSD

## Pricing Models

### On-Demand Instances
- **Pricing**: Pay per hour/second
- **Use Case**: Variable workloads
- **Benefits**: No upfront commitment
- **Drawbacks**: Highest cost

### Reserved Instances
- **Pricing**: 1-3 year commitment
- **Use Case**: Predictable workloads
- **Benefits**: Up to 75% savings
- **Drawbacks**: Long-term commitment

### Spot Instances
- **Pricing**: Up to 90% savings
- **Use Case**: Fault-tolerant workloads
- **Benefits**: Lowest cost
- **Drawbacks**: Can be terminated

### Dedicated Hosts
- **Pricing**: Pay for entire host
- **Use Case**: Compliance requirements
- **Benefits**: Full control
- **Drawbacks**: Higher cost

## Networking and Security

### VPC Configuration
- **Subnets**: Public and private subnets
- **Security Groups**: Firewall rules
- **NACLs**: Network access control lists
- **Route Tables**: Traffic routing

### Security Best Practices
- **IAM Roles**: Use roles instead of access keys
- **Security Groups**: Restrict access
- **Encryption**: Encrypt data at rest and in transit
- **Monitoring**: Use CloudTrail and CloudWatch

## Storage Options

### EBS Volume Types
- **gp3**: General purpose SSD
- **io2**: High IOPS SSD
- **st1**: Throughput optimized HDD
- **sc1**: Cold HDD

### Instance Store
- **Type**: NVMe SSD
- **Use Case**: Temporary storage
- **Benefits**: High performance
- **Drawbacks**: Not persistent

## Monitoring and Management

### CloudWatch Metrics
- **CPU Utilization**: Monitor CPU usage
- **Memory Usage**: Track memory consumption
- **Disk I/O**: Monitor storage performance
- **Network I/O**: Track network traffic

### Auto Scaling
- **Target Tracking**: Maintain target metrics
- **Step Scaling**: Scale in steps
- **Scheduled Scaling**: Time-based scaling
- **Predictive Scaling**: ML-based scaling

## Best Practices

### 1. Instance Selection
- **Right-sizing**: Choose appropriate instance types
- **Performance Testing**: Test before production
- **Cost Optimization**: Balance performance and cost
- **Regular Review**: Review instance usage regularly

### 2. Security
- **Least Privilege**: Minimal permissions
- **Regular Updates**: Keep instances updated
- **Monitoring**: Continuous security monitoring
- **Backup**: Regular backup of data

### 3. Cost Optimization
- **Reserved Instances**: Use for predictable workloads
- **Spot Instances**: Use for fault-tolerant workloads
- **Auto Scaling**: Scale based on demand
- **Monitoring**: Track and optimize costs

