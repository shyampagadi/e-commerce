# Project 02-A: Network Architecture Design

## Overview

This project focuses on designing a comprehensive network architecture for a multi-tier web application. You'll learn how to create secure, scalable network designs that support high availability, performance, and security requirements.

## Project Objectives

By the end of this project, you will be able to:
- Design subnet architecture for different application tiers
- Implement load balancing for web and application layers
- Create network security zones and policies
- Design global traffic management solutions
- Plan for high availability and disaster recovery

## Project Requirements

### Business Context
You're designing the network architecture for a global e-commerce platform that needs to:
- Handle 100,000 concurrent users
- Support 99.9% availability
- Process 1 million transactions per day
- Serve customers in North America, Europe, and Asia
- Comply with PCI DSS requirements

### Technical Requirements

#### Performance Requirements
- **Latency**: <100ms for API responses
- **Throughput**: 10,000 requests per second
- **Availability**: 99.9% uptime
- **Scalability**: Handle 10x traffic spikes

#### Security Requirements
- **Network Segmentation**: Separate tiers with proper isolation
- **Encryption**: All traffic encrypted in transit
- **Access Control**: Least privilege access
- **Compliance**: PCI DSS compliance
- **Monitoring**: Comprehensive network monitoring

#### Geographic Requirements
- **Primary Region**: US East (N. Virginia)
- **Secondary Region**: EU West (Ireland)
- **Tertiary Region**: Asia Pacific (Singapore)
- **CDN**: Global content delivery

## Project Deliverables

### 1. Network Architecture Diagram
Create a comprehensive network architecture diagram showing:
- VPC design with CIDR blocks
- Subnet layout across multiple AZs
- Load balancer placement
- Security group configurations
- Internet and NAT gateways
- VPN connections

### 2. Subnet Design Document
Document the subnet design including:
- CIDR block allocation
- Subnet purposes and tiers
- IP address planning
- Route table configurations
- Network ACL rules

### 3. Load Balancing Strategy
Design load balancing implementation:
- Load balancer types and placement
- Health check configurations
- Session affinity requirements
- Failover mechanisms
- Performance optimization

### 4. Security Architecture
Create security design including:
- Network segmentation strategy
- Security group rules
- Network ACL configurations
- VPN and Direct Connect options
- DDoS protection strategy

### 5. Global Traffic Management
Design global traffic distribution:
- Route 53 configuration
- CDN implementation
- Multi-region failover
- Latency-based routing
- Health check monitoring

## Step-by-Step Implementation

### Phase 1: VPC and Subnet Design (Week 1)

#### Step 1.1: VPC Planning
```
┌─────────────────────────────────────────────────────────────┐
│                VPC PLANNING EXERCISE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Design VPC CIDR blocks for three regions:              │
│     - US East: 10.0.0.0/16                                 │
│     - EU West: 10.1.0.0/16                                 │
│     - Asia Pacific: 10.2.0.0/16                            │
│                                                             │
│  2. Plan subnet allocation:                                │
│     - Public subnets (web tier)                            │
│     - Private subnets (app tier)                           │
│     - Database subnets (data tier)                         │
│     - Management subnets (admin)                           │
│                                                             │
│  3. Consider future growth:                                │
│     - Reserve IP space for expansion                       │
│     - Plan for microservices segmentation                  │
│     - Account for container networking                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 1.2: Subnet Design
Create detailed subnet design for each region:

**US East Region (10.0.0.0/16)**
```
┌─────────────────────────────────────────────────────────────┐
│                US EAST SUBNET DESIGN                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Public Subnets:                                           │
│  - us-east-1a: 10.0.1.0/24 (Web servers)                  │
│  - us-east-1b: 10.0.2.0/24 (Web servers)                  │
│  - us-east-1c: 10.0.3.0/24 (Web servers)                  │
│                                                             │
│  Private Subnets:                                          │
│  - us-east-1a: 10.0.11.0/24 (App servers)                 │
│  - us-east-1b: 10.0.12.0/24 (App servers)                 │
│  - us-east-1c: 10.0.13.0/24 (App servers)                 │
│                                                             │
│  Database Subnets:                                         │
│  - us-east-1a: 10.0.21.0/24 (Primary DB)                  │
│  - us-east-1b: 10.0.22.0/24 (Read replicas)               │
│  - us-east-1c: 10.0.23.0/24 (Read replicas)               │
│                                                             │
│  Management Subnets:                                       │
│  - us-east-1a: 10.0.31.0/24 (Bastion hosts)               │
│  - us-east-1b: 10.0.32.0/24 (Monitoring)                  │
│  - us-east-1c: 10.0.33.0/24 (Logging)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 1.3: Route Table Configuration
Design route tables for each subnet type:

**Public Subnet Route Table**
```
┌─────────────────────────────────────────────────────────────┐
│            PUBLIC SUBNET ROUTE TABLE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Destination        │ Gateway          │ Target            │
│  ──────────────     │ ─────────        │ ──────            │
│  10.0.0.0/16        │ Local            │ Local             │
│  0.0.0.0/0          │ Internet Gateway │ igw-12345678      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Private Subnet Route Table**
```
┌─────────────────────────────────────────────────────────────┐
│            PRIVATE SUBNET ROUTE TABLE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Destination        │ Gateway          │ Target            │
│  ──────────────     │ ─────────        │ ──────            │
│  10.0.0.0/16        │ Local            │ Local             │
│  0.0.0.0/0          │ NAT Gateway      │ nat-12345678      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Phase 2: Load Balancing Implementation (Week 2)

#### Step 2.1: Load Balancer Design
Design load balancer architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                LOAD BALANCER ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   CloudFront│    │   Route 53  │    │   WAF           │  │
│  │   (CDN)     │    │   (DNS)     │    │   (Security)    │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         └───────────────────┼───────────────────┘           │
│                             │                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Application Load Balancer                │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Target    │    │   Target    │    │ Target  │  │    │
│  │  │   Group 1   │    │   Group 2   │    │ Group 3 │  │    │
│  │  │             │    │             │    │         │  │    │
│  │  │ - Web       │    │ - API       │    │ - Admin │  │    │
│  │  │   Servers   │    │   Servers   │    │   Portal│  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 2.2: Health Check Configuration
Configure health checks for different services:

**Web Server Health Check**
```
┌─────────────────────────────────────────────────────────────┐
│            WEB SERVER HEALTH CHECK                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Health Check Path: /health                                 │
│  Protocol: HTTP                                             │
│  Port: 80                                                   │
│  Timeout: 5 seconds                                         │
│  Interval: 30 seconds                                       │
│  Healthy Threshold: 2                                       │
│  Unhealthy Threshold: 3                                     │
│  Expected Response: 200 OK                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**API Server Health Check**
```
┌─────────────────────────────────────────────────────────────┐
│            API SERVER HEALTH CHECK                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Health Check Path: /api/health                             │
│  Protocol: HTTPS                                            │
│  Port: 443                                                  │
│  Timeout: 10 seconds                                        │
│  Interval: 30 seconds                                       │
│  Healthy Threshold: 2                                       │
│  Unhealthy Threshold: 3                                     │
│  Expected Response: 200 OK                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 2.3: Load Balancing Algorithms
Choose appropriate algorithms for different tiers:

```
┌─────────────────────────────────────────────────────────────┐
│            LOAD BALANCING ALGORITHMS                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Web Tier:                                                  │
│  - Algorithm: Round Robin                                   │
│  - Reason: Equal capacity servers                           │
│  - Session Affinity: None                                   │
│                                                             │
│  API Tier:                                                  │
│  - Algorithm: Least Outstanding Requests                    │
│  - Reason: Variable load patterns                           │
│  - Session Affinity: None                                   │
│                                                             │
│  Admin Portal:                                              │
│  - Algorithm: Round Robin                                   │
│  - Reason: Low traffic, simple distribution                 │
│  - Session Affinity: None                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Phase 3: Security Architecture (Week 3)

#### Step 3.1: Network Segmentation
Design network segmentation strategy:

```
┌─────────────────────────────────────────────────────────────┐
│                NETWORK SEGMENTATION                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Tier 1: DMZ (Public)                                      │
│  - Web servers                                              │
│  - Load balancers                                           │
│  - Bastion hosts                                            │
│  - Security: High (WAF, DDoS protection)                   │
│                                                             │
│  Tier 2: Application (Private)                             │
│  - API servers                                              │
│  - Application servers                                      │
│  - Workers                                                  │
│  - Security: Medium (Security groups)                      │
│                                                             │
│  Tier 3: Database (Private)                                │
│  - Database servers                                         │
│  - Cache servers                                            │
│  - Message queues                                           │
│  - Security: High (NACLs, encryption)                      │
│                                                             │
│  Tier 4: Management (Private)                              │
│  - Monitoring servers                                       │
│  - Logging servers                                          │
│  - Admin tools                                              │
│  - Security: High (VPN access only)                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 3.2: Security Group Design
Create security group rules:

**Web Server Security Group**
```
┌─────────────────────────────────────────────────────────────┐
│            WEB SERVER SECURITY GROUP                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Inbound Rules:                                             │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────┐    │
│  │ Type    │ Protocol│ Port    │ Source  │ Description │    │
│  │ ─────── │ ─────── │ ─────── │ ─────── │ ─────────── │    │
│  │ HTTP    │ TCP     │ 80      │ 0.0.0.0/0│ Web traffic│    │
│  │ HTTPS   │ TCP     │ 443     │ 0.0.0.0/0│ Secure web │    │
│  │ SSH     │ TCP     │ 22      │ 10.0.31.0/24│ Admin    │    │
│  └─────────┴─────────┴─────────┴─────────┴─────────────┘    │
│                                                             │
│  Outbound Rules:                                            │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────┐    │
│  │ Type    │ Protocol│ Port    │ Source  │ Description │    │
│  │ ─────── │ ─────── │ ─────── │ ─────── │ ─────────── │    │
│  │ All     │ All     │ All     │ 0.0.0.0/0│ All traffic│    │
│  └─────────┴─────────┴─────────┴─────────┴─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**API Server Security Group**
```
┌─────────────────────────────────────────────────────────────┐
│            API SERVER SECURITY GROUP                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Inbound Rules:                                             │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────┐    │
│  │ Type    │ Protocol│ Port    │ Source  │ Description │    │
│  │ ─────── │ ─────── │ ─────── │ ─────── │ ─────────── │    │
│  │ HTTPS   │ TCP     │ 443     │ 10.0.1.0/24│ Web tier │    │
│  │ HTTP    │ TCP     │ 80      │ 10.0.1.0/24│ Web tier │    │
│  │ SSH     │ TCP     │ 22      │ 10.0.31.0/24│ Admin    │    │
│  └─────────┴─────────┴─────────┴─────────┴─────────────┘    │
│                                                             │
│  Outbound Rules:                                            │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────┐    │
│  │ Type    │ Protocol│ Port    │ Source  │ Description │    │
│  │ ─────── │ ─────── │ ─────── │ ─────── │ ─────────── │    │
│  │ HTTPS   │ TCP     │ 443     │ 10.0.21.0/24│ DB tier │    │
│  │ HTTP    │ TCP     │ 80      │ 10.0.21.0/24│ DB tier │    │
│  │ All     │ All     │ All     │ 0.0.0.0/0│ Internet  │    │
│  └─────────┴─────────┴─────────┴─────────┴─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 3.3: Network ACL Design
Create Network ACL rules for additional security:

**Public Subnet NACL**
```
┌─────────────────────────────────────────────────────────────┐
│            PUBLIC SUBNET NACL                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Inbound Rules:                                             │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────┐    │
│  │ Rule #  │ Type    │ Protocol│ Port    │ Source      │    │
│  │ ─────── │ ─────── │ ─────── │ ─────── │ ─────────── │    │
│  │ 100     │ HTTP    │ TCP     │ 80      │ 0.0.0.0/0   │    │
│  │ 110     │ HTTPS   │ TCP     │ 443     │ 0.0.0.0/0   │    │
│  │ 120     │ SSH     │ TCP     │ 22      │ 10.0.31.0/24│    │
│  │ 130     │ Ephemeral│ TCP     │ 32768-65535│ 0.0.0.0/0│    │
│  │ 32767   │ Deny    │ All     │ All     │ 0.0.0.0/0   │    │
│  └─────────┴─────────┴─────────┴─────────┴─────────────┘    │
│                                                             │
│  Outbound Rules:                                            │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────────┐    │
│  │ Rule #  │ Type    │ Protocol│ Port    │ Destination │    │
│  │ ─────── │ ─────── │ ─────── │ ─────── │ ─────────── │    │
│  │ 100     │ All     │ All     │ All     │ 0.0.0.0/0   │    │
│  │ 32767   │ Deny    │ All     │ All     │ 0.0.0.0/0   │    │
│  └─────────┴─────────┴─────────┴─────────┴─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Phase 4: Global Traffic Management (Week 4)

#### Step 4.1: Route 53 Configuration
Design DNS strategy for global traffic:

```
┌─────────────────────────────────────────────────────────────┐
│                ROUTE 53 CONFIGURATION                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Primary Domain: example.com                               │
│                                                             │
│  A Records (Alias):                                        │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐  │
│  │ Name        │ Type        │ Value       │ TTL         │  │
│  │ ─────────── │ ─────────── │ ─────────── │ ─────────── │  │
│  │ example.com │ A           │ ALB-US      │ 300         │  │
│  │ www         │ A           │ ALB-US      │ 300         │  │
│  │ api         │ A           │ ALB-US      │ 300         │  │
│  └─────────────┴─────────────┴─────────────┴─────────────┘  │
│                                                             │
│  Health Checks:                                             │
│  ┌─────────────┬─────────────┬─────────────┬─────────────┐  │
│  │ Name        │ Type        │ Path        │ Interval    │  │
│  │ ─────────── │ ─────────── │ ─────────── │ ─────────── │  │
│  │ US-Health   │ HTTP        │ /health     │ 30s         │  │
│  │ EU-Health   │ HTTP        │ /health     │ 30s         │  │
│  │ AP-Health   │ HTTP        │ /health     │ 30s         │  │
│  └─────────────┴─────────────┴─────────────┴─────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 4.2: CloudFront Configuration
Design CDN strategy:

```
┌─────────────────────────────────────────────────────────────┐
│                CLOUDFRONT CONFIGURATION                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Distribution Settings:                                     │
│  - Origin: ALB (us-east-1)                                 │
│  - Price Class: Use All Edge Locations                     │
│  - SSL Certificate: Custom (example.com)                   │
│  - HTTP to HTTPS Redirect: Yes                             │
│                                                             │
│  Caching Behavior:                                          │
│  - Static Content: 1 year TTL                              │
│  - Dynamic Content: 0 TTL                                  │
│  - API Responses: 0 TTL                                    │
│  - Images: 30 days TTL                                     │
│                                                             │
│  Security:                                                  │
│  - WAF Integration: Yes                                     │
│  - DDoS Protection: AWS Shield Standard                    │
│  - Geographic Restrictions: None                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Step 4.3: Multi-Region Failover
Design failover strategy:

```
┌─────────────────────────────────────────────────────────────┐
│                MULTI-REGION FAILOVER                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Primary Region (US East):                                 │
│  - Active traffic handling                                  │
│  - Primary database                                         │
│  - Real-time replication to secondary                      │
│                                                             │
│  Secondary Region (EU West):                               │
│  - Standby traffic handling                                │
│  - Read replica database                                    │
│  - Failover when primary fails                             │
│                                                             │
│  Tertiary Region (Asia Pacific):                           │
│  - Read-only traffic handling                              │
│  - Read replica database                                    │
│  - Disaster recovery site                                   │
│                                                             │
│  Failover Triggers:                                        │
│  - Health check failures                                   │
│  - Manual failover                                          │
│  - Automated failover (RTO: 5 minutes)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Checklist

### Phase 1: VPC and Subnet Design
- [ ] Design VPC CIDR blocks for all regions
- [ ] Create subnet layout for each tier
- [ ] Plan IP address allocation
- [ ] Design route table configurations
- [ ] Document subnet purposes and rules

### Phase 2: Load Balancing Implementation
- [ ] Design load balancer architecture
- [ ] Configure health checks for all services
- [ ] Choose appropriate load balancing algorithms
- [ ] Implement session affinity if needed
- [ ] Test load balancer failover

### Phase 3: Security Architecture
- [ ] Design network segmentation strategy
- [ ] Create security group rules
- [ ] Configure Network ACLs
- [ ] Implement VPN connections
- [ ] Set up DDoS protection

### Phase 4: Global Traffic Management
- [ ] Configure Route 53 DNS
- [ ] Set up CloudFront CDN
- [ ] Implement multi-region failover
- [ ] Configure health checks
- [ ] Test global traffic routing

## Success Criteria

### Performance
- [ ] API response time <100ms
- [ ] Load balancer handles 10,000 RPS
- [ ] 99.9% availability achieved
- [ ] Global latency <200ms

### Security
- [ ] Network segmentation implemented
- [ ] All traffic encrypted in transit
- [ ] Security groups properly configured
- [ ] NACLs provide additional protection

### Scalability
- [ ] Architecture handles 10x traffic spikes
- [ ] Auto-scaling groups configured
- [ ] Load balancers scale automatically
- [ ] Global traffic distribution working

### Compliance
- [ ] PCI DSS requirements met
- [ ] Network monitoring implemented
- [ ] Access logging enabled
- [ ] Security controls documented

## Next Steps

After completing this project, you'll be ready for:
- **Project 02-B**: API Gateway Implementation
- **Module-03**: Storage Systems Design
- **Mid-Capstone Project 1**: Scalable Web Application Platform

## Resources

### AWS Services
- [VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [Elastic Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/)
- [Route 53 Developer Guide](https://docs.aws.amazon.com/route53/)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/)

### Tools
- [AWS Architecture Icons](https://aws.amazon.com/architecture/icons/)
- [Draw.io](https://app.diagrams.net/) for architecture diagrams
- [AWS CLI](https://aws.amazon.com/cli/) for automation
- [Terraform](https://terraform.io/) for Infrastructure as Code

---

**Ready to design your network architecture?** Start with Phase 1 and create your VPC and subnet design!
