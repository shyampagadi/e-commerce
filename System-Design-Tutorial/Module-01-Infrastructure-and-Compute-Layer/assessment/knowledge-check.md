# Module-01 Knowledge Check

## Overview

This knowledge check evaluates your understanding of infrastructure and compute layer concepts covered in Module-01.

## Section A: Core Concepts (25 points)

### 1. Infrastructure Architecture Patterns (5 points)
**Question**: Compare layered architecture with microservices architecture. What are the trade-offs?

**Answer Guidelines**:
- Layered: Simpler, monolithic, easier to manage
- Microservices: More complex, distributed, better scalability
- Trade-offs: Complexity vs. scalability, team size, technology diversity

### 2. Compute Scaling Strategies (5 points)
**Question**: Explain the difference between vertical and horizontal scaling. When would you use each?

**Answer Guidelines**:
- Vertical: Scale up individual resources, simpler but limited
- Horizontal: Scale out by adding instances, more complex but unlimited
- Use cases: Vertical for simple apps, horizontal for scalable systems

### 3. Virtual Machines (5 points)
**Question**: What are the key differences between Type 1 and Type 2 hypervisors?

**Answer Guidelines**:
- Type 1: Bare metal, better performance, more secure
- Type 2: Hosted, easier to manage, lower performance
- Use cases: Type 1 for production, Type 2 for development

### 4. Container Orchestration (5 points)
**Question**: Compare Docker Swarm with Kubernetes. What are the key differences?

**Answer Guidelines**:
- Docker Swarm: Simpler, AWS native, limited features
- Kubernetes: Complex, industry standard, rich ecosystem
- Trade-offs: Simplicity vs. functionality, vendor lock-in vs. portability

### 5. Serverless Computing (5 points)
**Question**: What are the benefits and challenges of serverless computing?

**Answer Guidelines**:
- Benefits: No server management, auto-scaling, pay-per-use
- Challenges: Cold starts, vendor lock-in, debugging complexity
- Use cases: Event-driven apps, variable workloads

## Section B: AWS Implementation (25 points)

### 1. EC2 Configuration (5 points)
**Question**: How would you choose the right EC2 instance type for a web application?

**Answer Guidelines**:
- Analyze workload characteristics
- Consider CPU, memory, storage, network requirements
- Choose appropriate instance family
- Consider cost optimization

### 2. Auto Scaling (5 points)
**Question**: Design an auto-scaling strategy for a web application with variable load.

**Answer Guidelines**:
- Set appropriate min/max capacity
- Configure scaling policies
- Use multiple metrics
- Implement cooldown periods

### 3. Lambda Functions (5 points)
**Question**: How would you optimize Lambda function performance and cost?

**Answer Guidelines**:
- Right-size memory allocation
- Minimize dependencies
- Use connection pooling
- Implement proper error handling

### 4. Container Services (5 points)
**Question**: When would you choose ECS over EKS for container orchestration?

**Answer Guidelines**:
- ECS: Simpler, AWS native, lower complexity
- EKS: Kubernetes, portable, rich ecosystem
- Consider team expertise, requirements, portability

### 5. Infrastructure as Code (5 points)
**Question**: What are the benefits of using Infrastructure as Code?

**Answer Guidelines**:
- Version control
- Repeatability
- Automation
- Documentation
- Testing

## Section C: Practical Application (25 points)

### 1. Capacity Planning (10 points)
**Scenario**: Plan infrastructure for a web application with 10,000 daily users.

**Requirements**:
- 1000 requests per minute average
- 5000 requests per minute peak
- 99.9% availability
- <200ms response time

**Deliverables**:
- Resource requirements
- Instance type selection
- Auto-scaling configuration
- Cost estimation

### 2. Architecture Design (15 points)
**Scenario**: Design infrastructure for a microservices application.

**Requirements**:
- 5 microservices
- 1000 concurrent users
- Global deployment
- High availability

**Deliverables**:
- Architecture diagram
- Technology selection
- Scaling strategy
- Security considerations

## Section D: Problem Solving (25 points)

### 1. Performance Optimization (10 points)
**Problem**: Web application experiencing high latency during peak hours.

**Tasks**:
- Identify potential bottlenecks
- Propose optimization strategies
- Implement monitoring
- Test improvements

### 2. Cost Optimization (10 points)
**Problem**: Infrastructure costs are too high for current usage.

**Tasks**:
- Analyze current usage
- Identify optimization opportunities
- Implement cost-saving measures
- Monitor cost impact

### 3. Disaster Recovery (5 points)
**Problem**: Design disaster recovery for critical application.

**Tasks**:
- Assess recovery requirements
- Design backup strategy
- Implement failover procedures
- Test recovery process

## Scoring Rubric

### Excellent (90-100%)
- Demonstrates deep understanding of concepts
- Provides detailed, accurate explanations
- Shows clear reasoning and analysis
- Includes practical examples
- Documentation is comprehensive

### Good (80-89%)
- Shows solid understanding of most concepts
- Provides mostly accurate explanations
- Demonstrates good reasoning
- Includes some practical examples
- Documentation is clear

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
- Documentation is poor

## Preparation Tips

1. **Review All Concepts**: Go through each concept document thoroughly
2. **Practice Exercises**: Complete all hands-on exercises
3. **Study AWS Services**: Understand AWS compute services
4. **Practice Problems**: Work through similar scenarios
5. **Understand Trade-offs**: Be prepared to discuss pros and cons

## Next Steps

After completing this knowledge check:
- **Score 90%+**: You're ready for Module-02
- **Score 80-89%**: Review weak areas and retake specific sections
- **Score Below 80%**: Review Module-01 content thoroughly before proceeding

