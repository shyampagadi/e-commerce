# Module 6: AWS Domain Configuration Assessment

## Assessment Overview

**Total Points**: 300 points  
**Passing Score**: 210 points (70%)  
**Time Limit**: 3 hours  
**Format**: Practical implementation + theoretical questions

## Assessment Structure

| Section | Points | Time | Description |
|---------|--------|------|-------------|
| **Practical Implementation** | 200 | 2 hours | Complete AWS domain setup |
| **Theoretical Knowledge** | 75 | 45 minutes | Concepts and best practices |
| **Documentation** | 25 | 15 minutes | Setup guide and architecture |

## Section 1: Practical Implementation (200 points)

### Project: Production-Ready Domain Setup

Deploy a complete production-ready domain configuration with SSL, CDN, and monitoring for a containerized web application.

#### Core Infrastructure (100 points)

**1. VPC and Networking Setup (25 points)**
```bash
# Required Infrastructure:
- Custom VPC with proper CIDR planning
- Multi-AZ public and private subnets
- Internet Gateway and NAT Gateway
- Route tables with proper routing
- Security groups with least privilege access
```

**Deliverables**:
- VPC with 10.0.0.0/16 CIDR block
- 2 public subnets in different AZs
- 2 private subnets in different AZs
- Functional internet and NAT gateways
- Properly configured route tables

**Validation Commands**:
```bash
# Test VPC connectivity
aws ec2 describe-vpcs --filters Name=tag:Name,Values=Assessment-VPC
aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-xxxxxxxxx
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-xxxxxxxxx
```

---

**2. EC2 and Application Deployment (25 points)**
```bash
# Required Setup:
- EC2 instances in private subnets
- Application Load Balancer in public subnets
- Auto Scaling Group with min 2, max 4 instances
- Containerized web application deployment
- Health checks configured
```

**Deliverables**:
- Auto Scaling Group with proper configuration
- Application Load Balancer with health checks
- Containerized application running on instances
- Security groups allowing only necessary traffic

---

**3. Domain and DNS Configuration (25 points)**
```bash
# Required Configuration:
- Domain registered or configured in Route 53
- Hosted zone with proper NS records
- A/AAAA records pointing to load balancer
- CNAME records for www subdomain
- Health checks for failover (bonus)
```

**Deliverables**:
- Working domain resolution
- Proper DNS records configuration
- Subdomain routing (www.domain.com)
- DNS propagation verified globally

---

**4. SSL/TLS Implementation (25 points)**
```bash
# Required Security:
- SSL certificate from AWS Certificate Manager
- HTTPS listener on load balancer
- HTTP to HTTPS redirect
- Security headers configured
- SSL Labs rating A or higher
```

**Deliverables**:
- Valid SSL certificate installed
- HTTPS working without warnings
- HTTP automatically redirects to HTTPS
- Security headers implemented
- SSL Labs test passing

#### Advanced Features (100 points)

**5. CloudFront CDN Setup (30 points)**
```bash
# Required CDN Configuration:
- CloudFront distribution with custom domain
- SSL certificate for CloudFront
- Caching policies for static/dynamic content
- Compression enabled
- Custom error pages
```

**Deliverables**:
- CloudFront distribution working
- Custom domain pointing to CloudFront
- Proper caching behaviors configured
- Improved global performance
- Custom error pages implemented

---

**6. Security Implementation (25 points)**
```bash
# Required Security Measures:
- AWS WAF with basic protection rules
- Security groups with minimal access
- NACLs for additional layer security
- CloudTrail for audit logging
- VPC Flow Logs enabled
```

**Deliverables**:
- WAF protecting against common attacks
- Layered security implementation
- Comprehensive audit logging
- Network traffic monitoring
- Security best practices followed

---

**7. Monitoring and Alerting (25 points)**
```bash
# Required Monitoring:
- CloudWatch dashboards for infrastructure
- Custom metrics for application performance
- Alarms for critical thresholds
- SNS notifications configured
- Log aggregation setup
```

**Deliverables**:
- Comprehensive monitoring dashboard
- Proactive alerting configured
- Application performance metrics
- Notification system working
- Centralized log management

---

**8. High Availability and Disaster Recovery (20 points)**
```bash
# Required HA/DR:
- Multi-AZ deployment
- Auto Scaling policies
- Health checks and automatic recovery
- Backup strategies documented
- Failover procedures tested
```

**Deliverables**:
- Multi-AZ infrastructure deployment
- Automatic scaling and recovery
- Documented backup procedures
- Tested failover scenarios
- RTO/RPO objectives defined

## Section 2: Theoretical Knowledge (75 points)

### Part A: AWS Fundamentals (30 points)

**Question 1 (10 points)**: Explain the difference between Security Groups and NACLs. When would you use each, and how do they work together in a layered security approach?

**Question 2 (10 points)**: Describe the components of a VPC and how they enable secure, scalable application deployment. Include subnets, route tables, gateways, and endpoints.

**Question 3 (10 points)**: Compare different AWS load balancer types (ALB, NLB, CLB) and explain when to use each for containerized applications.

### Part B: Domain and DNS Management (25 points)

**Question 4 (10 points)**: Explain DNS record types (A, AAAA, CNAME, MX, TXT) and their use cases in a production web application setup.

**Question 5 (8 points)**: Describe Route 53 routing policies and provide scenarios where each would be appropriate for high availability.

**Question 6 (7 points)**: Explain SSL/TLS certificate validation methods in AWS Certificate Manager and their security implications.

### Part C: Performance and Security (20 points)

**Question 7 (10 points)**: Design a CloudFront caching strategy for an e-commerce application with both static and dynamic content. Include cache behaviors, TTLs, and invalidation strategies.

**Question 8 (10 points)**: Describe AWS WAF rule types and create a security policy for protecting a web application against common attacks (OWASP Top 10).

## Section 3: Documentation (25 points)

### Architecture Documentation (15 points)
Create comprehensive documentation including:
- Network architecture diagram
- Security group rules and justification
- DNS configuration and routing
- SSL/TLS implementation details
- Monitoring and alerting setup

### Deployment Guide (10 points)
Provide step-by-step deployment instructions:
- Infrastructure setup procedures
- Application deployment steps
- Configuration verification
- Troubleshooting common issues
- Rollback procedures

## Assessment Rubric

### Practical Implementation Scoring

| Criteria | Excellent (90-100%) | Good (80-89%) | Satisfactory (70-79%) | Needs Improvement (<70%) |
|----------|-------------------|---------------|---------------------|------------------------|
| **Infrastructure Setup** | All components working perfectly | Minor configuration issues | Basic functionality present | Major components missing |
| **Security Implementation** | Comprehensive security measures | Good security practices | Basic security implemented | Security vulnerabilities present |
| **Performance Optimization** | Optimized for speed and efficiency | Good performance characteristics | Acceptable performance | Performance issues present |
| **High Availability** | Full HA/DR implementation | Good availability measures | Basic redundancy | Single points of failure |

### Theoretical Knowledge Scoring

| Criteria | Excellent (90-100%) | Good (80-89%) | Satisfactory (70-79%) | Needs Improvement (<70%) |
|----------|-------------------|---------------|---------------------|------------------------|
| **AWS Concepts** | Deep understanding demonstrated | Good grasp of concepts | Basic understanding | Limited knowledge |
| **Best Practices** | Comprehensive best practices | Good practices mentioned | Some practices covered | Poor practices |
| **Security Knowledge** | Expert security understanding | Good security awareness | Basic security knowledge | Security gaps |
| **Troubleshooting** | Advanced problem-solving skills | Good diagnostic abilities | Basic troubleshooting | Limited problem-solving |

## Submission Requirements

### File Structure
```
aws-domain-assessment/
├── infrastructure/
│   ├── vpc-setup.sh
│   ├── security-groups.json
│   ├── load-balancer-config.json
│   └── auto-scaling-config.json
├── dns-ssl/
│   ├── route53-records.json
│   ├── certificate-config.json
│   └── cloudfront-config.json
├── monitoring/
│   ├── cloudwatch-dashboard.json
│   ├── alarms-config.json
│   └── sns-notifications.json
├── security/
│   ├── waf-rules.json
│   ├── security-policies.json
│   └── audit-config.json
├── documentation/
│   ├── architecture-diagram.png
│   ├── deployment-guide.md
│   └── troubleshooting-guide.md
└── scripts/
    ├── deploy.sh
    ├── validate.sh
    └── cleanup.sh
```

### Submission Checklist
- [ ] All infrastructure components deployed and working
- [ ] Domain resolving with HTTPS
- [ ] CloudFront CDN operational
- [ ] Security measures implemented
- [ ] Monitoring and alerting configured
- [ ] Documentation complete
- [ ] Theoretical questions answered
- [ ] Deployment scripts provided

## Assessment Commands

### Validation Scripts
```bash
# Infrastructure validation
./scripts/validate.sh

# DNS and SSL testing
dig yourdomain.com
curl -I https://yourdomain.com
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com

# Performance testing
curl -w "@curl-format.txt" -o /dev/null -s https://yourdomain.com

# Security testing
nmap -sS -O yourdomain.com
```

### Expected Outputs
```bash
# Domain should resolve correctly
$ dig yourdomain.com
;; ANSWER SECTION:
yourdomain.com. 300 IN A 1.2.3.4

# HTTPS should work with valid certificate
$ curl -I https://yourdomain.com
HTTP/2 200
server: nginx
strict-transport-security: max-age=31536000

# CloudFront should be serving content
$ curl -I https://yourdomain.com
x-cache: Hit from cloudfront
x-amz-cf-pop: IAD89-C1
```

## Certification Levels

### AWS Domain Associate (210-239 points)
- Basic AWS infrastructure setup
- Standard domain configuration with SSL
- Fundamental monitoring and security
- Basic documentation

### AWS Domain Professional (240-269 points)
- Advanced AWS networking and security
- Optimized CDN and performance configuration
- Comprehensive monitoring and alerting
- Detailed documentation and procedures

### AWS Domain Expert (270-300 points)
- Enterprise-grade AWS architecture
- Advanced security and compliance implementation
- Complete automation and Infrastructure as Code
- Expert-level troubleshooting and optimization

## Time Management Recommendations

| Phase | Time | Focus |
|-------|------|-------|
| **Planning** | 15 min | Architecture design and resource planning |
| **Infrastructure** | 45 min | VPC, subnets, gateways, load balancer |
| **Application** | 30 min | EC2, Auto Scaling, application deployment |
| **Domain/SSL** | 30 min | Route 53, Certificate Manager, HTTPS |
| **CDN/Security** | 45 min | CloudFront, WAF, security implementation |
| **Monitoring** | 30 min | CloudWatch, alarms, notifications |
| **Testing** | 15 min | Validation and troubleshooting |
| **Documentation** | 30 min | Architecture docs and deployment guide |

## Success Tips

1. **Start with Infrastructure**: Build solid VPC foundation first
2. **Test Incrementally**: Validate each component before proceeding
3. **Security First**: Implement security at each layer
4. **Document as You Go**: Don't leave documentation until the end
5. **Use Automation**: Script repetitive tasks for efficiency
6. **Monitor Everything**: Set up monitoring early in the process

This comprehensive assessment evaluates practical AWS skills, theoretical knowledge, and professional documentation practices essential for production domain deployments.
