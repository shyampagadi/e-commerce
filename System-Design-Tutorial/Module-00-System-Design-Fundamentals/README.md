# Module 00: System Design Fundamentals

## Module Overview
This foundational module introduces the core principles and methodologies of system design, establishing the critical knowledge base for all subsequent modules. You'll learn the systematic approach to designing scalable, reliable, and maintainable systems, while also gaining practical experience with the AWS Well-Architected Framework.

## Learning Objectives
- Understand the system design process and methodology
- Learn how to analyze requirements and identify constraints
- Master architectural quality attributes and their trade-offs
- Develop skills in architecture documentation and communication
- Apply the AWS Well-Architected Framework to evaluate designs

## Prerequisites
- Basic understanding of software development concepts
- Familiarity with client-server architecture
- Basic knowledge of computing resources (CPU, memory, storage, network)
- AWS account (free tier is sufficient for exercises)


## Quick Index
- **Concepts**: [introduction-to-system-design.md](concepts/introduction-to-system-design.md), [requirements-analysis.md](concepts/requirements-analysis.md), [architectural-quality-attributes.md](concepts/architectural-quality-attributes.md), [cap-theorem-explained.md](concepts/cap-theorem-explained.md), [acid-vs-base-properties.md](concepts/acid-vs-base-properties.md), [system-design-building-blocks.md](concepts/system-design-building-blocks.md), [architecture-patterns-overview.md](concepts/architecture-patterns-overview.md), [design-documentation.md](concepts/design-documentation.md), [system-design-interview-framework.md](concepts/system-design-interview-framework.md), [capacity-estimation-and-sizing.md](concepts/capacity-estimation-and-sizing.md)
- **AWS**: [well-architected-framework.md](aws/well-architected-framework.md), [account-setup-security.md](aws/account-setup-security.md)
- **Exercises**: [exercises/README.md](exercises/README.md)
- **Projects**: [project-00-A/README.md](projects/project-00-A/README.md), [project-00-B/README.md](projects/project-00-B/README.md)
- **Decisions**: [ADR-INDEX.md](decisions/ADR-INDEX.md), [architecture-pattern-selection.md](decisions/architecture-pattern-selection.md)
- **Case Studies**: [amazon-shopping-cart-evolution.md](case-studies/amazon-shopping-cart-evolution.md)

---

# SECTION 1: GENERAL PRINCIPLES

## 1. Introduction to System Design
- Definition and importance of system design
- The system design process
- Stakeholders and their perspectives
- Types of architectural views (4+1 view model)
- Design thinking approach to system architecture
- Technical debt and architecture evolution
- Software architecture vs. system design

## 2. Requirements Analysis
- Functional requirements gathering techniques
- Non-functional requirements (quality attributes)
- Scalability requirements (user load, data volume, transaction rate)
- Performance requirements (latency, throughput, response time)
- Reliability and availability targets (uptime percentages, SLAs)
- Security and compliance requirements
- Cost constraints and business context
- Operational requirements

## 3. Architectural Quality Attributes
- Scalability: vertical and horizontal scaling patterns
- Reliability: fault tolerance, redundancy, resilience
- Availability: uptime calculations, 9's reliability
- Maintainability: modularity, testability, deployability
- Performance: latency, throughput, response time, efficiency
- Security: confidentiality, integrity, availability, non-repudiation
- Cost efficiency: operational costs, infrastructure costs, licensing
- Operability: monitoring, debugging, troubleshooting
- Portability: vendor independence, cloud agnosticism
- Trade-off analysis between competing attributes

## 4. CAP Theorem and Distributed Systems
- CAP theorem explained in depth
  - Consistency: all nodes see the same data at the same time
  - Availability: every request receives a response
  - Partition tolerance: system continues to operate despite network failures
- CAP theorem implications for distributed systems
- CP vs. AP vs. CA systems with examples
- PACELC theorem: extension of CAP for normal operation
- Consistency models in detail
  - Strong consistency
  - Eventual consistency
  - Causal consistency
  - Session consistency
  - Monotonic read consistency
  - Read-your-writes consistency

## 5. ACID vs BASE Properties
- ACID properties in detail
  - Atomicity: all or nothing transactions
  - Consistency: transactions maintain data validity
  - Isolation: concurrent transaction effects
  - Durability: committed transactions remain
- BASE properties explained
  - Basically Available: system guarantees availability
  - Soft state: state may change over time
  - Eventually consistent: system becomes consistent over time
- When to use ACID vs BASE
- Real-world examples of ACID and BASE systems
- Hybrid approaches and practical considerations

## 6. System Design Building Blocks
- Servers and compute resources
  - Types of servers (application, web, database, cache)
  - Virtual machines vs containers vs bare metal
- Storage systems
  - Block storage, object storage, file storage
  - SQL vs NoSQL databases
- Network infrastructure
  - Load balancers (L4 vs L7)
  - CDNs and edge caching
  - API gateways
- Caching layers
  - Client-side, CDN, application, and database caching
- Message queues and event streams
  - Queue-based vs publish-subscribe patterns
- Service discovery and registration

## 7. Architecture Patterns Overview
- Layered architecture (presentation, business, data)
- Service-oriented architecture (SOA)
- Microservices architecture
- Event-driven architecture
- Serverless architecture
- Monolithic architecture
- Space-based architecture (in-memory data grids)
- Peer-to-peer architecture
- Command Query Responsibility Segregation (CQRS)
- Hexagonal/Ports and Adapters architecture
- When to apply each pattern (selection criteria)

## 8. Design Documentation
- Architecture diagrams (C4 model)
  - Context diagrams
  - Container diagrams
  - Component diagrams
  - Code diagrams
- System context diagrams
- Component specifications and interfaces
- Data models and schemas
- Architecture Decision Records (ADRs)
- Technical specifications templates
- API documentation standards
- View-based documentation (4+1 architectural view model)

---

# SECTION 2: AWS IMPLEMENTATION

## 1. AWS Well-Architected Framework
- Five pillars in detail:
  - Operational Excellence: running and monitoring systems
  - Security: protecting data and systems
  - Reliability: system recovery and availability
  - Performance Efficiency: using resources efficiently
  - Cost Optimization: avoiding unnecessary costs
- Design principles for each pillar
  - Operational Excellence: infrastructure as code, frequent deployments
  - Security: defense in depth, principle of least privilege
  - Reliability: automatic recovery, horizontal scaling
  - Performance Efficiency: serverless architectures, experiment often
  - Cost Optimization: consumption-based pricing, managed services
- Well-Architected Tool and review process
- Implementation best practices
- Architectural trade-offs within the framework

## 2. AWS Account Setup and Security Foundation
- AWS account structure and organization
  - Single account vs multi-account strategy
  - AWS Organizations structure
  - Organizational Units (OUs) design
- IAM users, groups, and roles
  - Identity management best practices
  - Authentication mechanisms
  - Federation with external identity providers
- Permission policies and least privilege
  - Policy structure and syntax
  - Policy evaluation logic
  - Permission boundaries
  - Service control policies
- Multi-factor authentication setup and management
- CloudTrail for auditing
  - Log collection and storage
  - Event filtering
  - Integration with security services

## 3. AWS Service Categories
- Compute services
  - EC2, Lambda, ECS, EKS, Fargate, Batch
  - Selection criteria and use cases
- Storage services
  - S3, EBS, EFS, FSx, Storage Gateway
  - Selection criteria and use cases
- Database services
  - RDS, DynamoDB, ElastiCache, Neptune, Redshift
  - Selection criteria and use cases
- Networking services
  - VPC, Route 53, CloudFront, API Gateway
  - Selection criteria and use cases
- Integration services
  - SQS, SNS, EventBridge, AppSync
  - Selection criteria and use cases
- Monitoring services
  - CloudWatch, X-Ray, CloudTrail
  - Selection criteria and use cases
- Security services
  - IAM, KMS, WAF, Shield, GuardDuty
  - Selection criteria and use cases

## 4. AWS Architecture Design Tools
- AWS Diagrams and architectural icons
- CloudFormation Designer
  - Visual template creation
  - Resource relationship visualization
- AWS App Composer
  - Serverless application design
  - Visual programming interface
- Architecture Center resources
  - Reference architectures
  - Best practices
  - Whitepapers
- Solution constructs
  - Pre-built component libraries
  - Deployment templates

## 5. AWS Pricing Models and Cost Estimation
- On-demand vs. reserved vs. spot instances
  - Price comparison and use cases
  - Reserved instance types (Standard, Convertible)
  - Savings Plans (Compute, EC2 Instance)
- Free tier resources and limitations
- Pricing calculators
  - AWS Pricing Calculator usage
  - Total Cost of Ownership (TCO) calculator
- Cost optimization strategies
  - Right-sizing resources
  - Auto Scaling for demand matching
  - Storage class optimization
  - Region selection for cost efficiency
- Billing alerts and budgets
  - CloudWatch billing alarms
  - AWS Budgets setup and thresholds
  - Cost anomaly detection

## 6. AWS Architecture Documentation Best Practices
- AWS Architecture Icons and diagrams
  - Standard notation and symbols
  - Diagram organization and layout
- Architecture decision records
  - AWS-specific decision templates
  - Common architectural decisions
- Multi-account strategy documentation
  - Account structure documentation
  - Cross-account permission management
- Compliance documentation
  - AWS Artifact for compliance reports
  - Compliance framework mapping
- Disaster recovery planning
  - AWS-specific DR strategies
  - Multi-region documentation

---

## Assessment
### Knowledge Check
1. What is the CAP theorem and how does it impact distributed system design?
2. Describe the key differences between ACID and BASE properties and when to use each.
3. How do the five pillars of the AWS Well-Architected Framework relate to architectural quality attributes?
4. What are the primary considerations when choosing between different AWS service categories?
5. Explain the differences between on-demand, reserved, and spot instances in AWS.

### Design Challenge
Design a simple web application architecture that addresses specific requirements for scalability, reliability, and cost-effectiveness:
1. Create a general architecture diagram showing components and their relationships
2. Develop an AWS-specific implementation using appropriate services
3. Document key architectural decisions and trade-offs
4. Create a simple cost estimate for the solution

## Additional Resources
- Book: "System Design Interview" by Alex Xu
- Book: "Designing Data-Intensive Applications" by Martin Kleppmann
- AWS Well-Architected Framework whitepaper
- AWS Architecture Center
- Stanford CS348 Data-Intensive Systems course materials
- MIT Distributed Systems lecture notes
- "Patterns of Enterprise Application Architecture" by Martin Fowler