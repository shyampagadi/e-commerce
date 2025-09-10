# Module-00 Knowledge Check

## Overview
This knowledge check evaluates your understanding of system design fundamentals covered in Module-00. Complete all sections to assess your readiness for Module-01.

## Section A: Core Concepts (25 points)

### 1. System Design Process (5 points)
**Question**: Describe the typical system design process from requirements gathering to implementation. What are the key phases and deliverables?

**Answer Guidelines**:
- Requirements analysis and clarification
- High-level architecture design
- Detailed component design
- Technology selection and trade-offs
- Implementation planning
- Documentation and communication

### 2. Quality Attributes (5 points)
**Question**: Explain the trade-offs between scalability and maintainability. Provide a real-world example where you might prioritize one over the other.

**Answer Guidelines**:
- Scalability vs maintainability trade-offs
- When to prioritize each attribute
- Real-world examples (e.g., startup vs enterprise)
- Specific architectural decisions that reflect these trade-offs

### 3. CAP Theorem (5 points)
**Question**: A banking system needs to process transactions with strong consistency. Which CAP theorem choice would you make and why? How would you handle network partitions?

**Answer Guidelines**:
- Choose CP (Consistency + Partition Tolerance)
- Explain why availability can be sacrificed for financial data
- Discuss partition handling strategies
- Mention eventual consistency for non-critical features

### 4. ACID vs BASE (5 points)
**Question**: Compare ACID and BASE properties. When would you choose a BASE system over an ACID system? Provide specific use cases.

**Answer Guidelines**:
- ACID: Atomicity, Consistency, Isolation, Durability
- BASE: Basically Available, Soft state, Eventually consistent
- Use cases for each (e.g., financial transactions vs social media)
- Hybrid approaches and practical considerations

### 5. Architecture Patterns (5 points)
**Question**: Compare monolithic and microservices architectures. What factors would influence your choice between them?

**Answer Guidelines**:
- Monolith: simplicity, performance, deployment complexity
- Microservices: scalability, technology diversity, operational complexity
- Team size and structure considerations
- System complexity and growth projections

## Section B: AWS Well-Architected Framework (25 points)

### 1. Operational Excellence (5 points)
**Question**: How would you implement infrastructure as code for a multi-environment deployment pipeline?

**Answer Guidelines**:
- CloudFormation or CDK templates
- Environment-specific parameter files
- CI/CD pipeline integration
- Version control and review processes

### 2. Security (5 points)
**Question**: Design an IAM strategy for a multi-account AWS organization with development, staging, and production environments.

**Answer Guidelines**:
- Organizational structure and OUs
- Cross-account roles and policies
- Service control policies (SCPs)
- Least privilege principles

### 3. Reliability (5 points)
**Question**: How would you design a highly available web application using AWS services? What would your RTO and RPO targets be?

**Answer Guidelines**:
- Multi-AZ deployment
- Load balancing and auto-scaling
- Database replication and backups
- RTO/RPO targets (e.g., 4 hours/1 hour)

### 4. Performance Efficiency (5 points)
**Question**: Explain how you would optimize performance for a data-intensive application using AWS services.

**Answer Guidelines**:
- Right-sizing instances
- Caching strategies (ElastiCache, CloudFront)
- Database optimization
- Monitoring and metrics

### 5. Cost Optimization (5 points)
**Question**: Create a cost optimization strategy for a variable workload application.

**Answer Guidelines**:
- Spot instances for non-critical workloads
- Reserved instances for predictable capacity
- Auto-scaling policies
- Storage lifecycle policies

## Section C: Practical Application (25 points)

### 1. Requirements Analysis (10 points)
**Scenario**: Design a URL shortener service like bit.ly

**Requirements**:
- 100M URLs per day
- 1B reads per day
- 6-character short codes
- Analytics on click tracking
- 99.9% availability

**Deliverables**:
- Functional requirements matrix
- Non-functional requirements with specific targets
- Key constraints and assumptions
- Quality attribute priorities

### 2. Architecture Design (15 points)
**Using the URL shortener scenario above:**

**Deliverables**:
- High-level architecture diagram
- Technology stack selection with rationale
- Database schema design
- API design (endpoints and data formats)
- Scaling strategy for 10x growth

## Section D: Design Documentation (25 points)

### 1. Architecture Decision Record (10 points)
**Create an ADR for the URL shortener scenario:**

**Decision**: Choose between SQL and NoSQL database for URL storage

**ADR Requirements**:
- Context and problem statement
- Options considered
- Decision and rationale
- Consequences (positive and negative)
- Implementation details

### 2. System Context Diagram (10 points)
**Create a C4 Level 1 context diagram for the URL shortener showing:**
- System boundary
- External actors (users, administrators)
- External systems (analytics, monitoring)
- Key interactions and data flows

### 3. Capacity Estimation (5 points)
**For the URL shortener scenario, calculate:**
- Peak requests per second
- Storage requirements for 1 year
- Database read/write capacity
- Bandwidth requirements

## Scoring Rubric

### Excellent (90-100%)
- Demonstrates deep understanding of concepts
- Provides detailed, accurate explanations
- Shows clear reasoning and trade-off analysis
- Includes practical examples and real-world context
- Documentation is professional and comprehensive

### Good (80-89%)
- Shows solid understanding of most concepts
- Provides mostly accurate explanations
- Demonstrates good reasoning
- Includes some practical examples
- Documentation is clear and well-structured

### Satisfactory (70-79%)
- Shows basic understanding of concepts
- Provides generally accurate explanations
- Demonstrates some reasoning
- Limited practical examples
- Documentation is adequate

### Needs Improvement (Below 70%)
- Shows limited understanding of concepts
- Provides inaccurate or incomplete explanations
- Lacks clear reasoning
- No practical examples
- Documentation is poor or missing

## Preparation Tips

1. **Review All Concepts**: Go through each concept document thoroughly
2. **Practice Diagrams**: Draw architecture diagrams for different scenarios
3. **Study Real Examples**: Look at how companies like Netflix, Uber, and Amazon solve similar problems
4. **Understand Trade-offs**: Be prepared to discuss the pros and cons of different approaches
5. **Practice Calculations**: Work through capacity estimation examples

## Next Steps

After completing this knowledge check:
- **Score 90%+**: You're ready for Module-01
- **Score 80-89%**: Review weak areas and retake specific sections
- **Score Below 80%**: Review Module-00 content thoroughly before proceeding

