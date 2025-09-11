# Module 07: Design Challenge - Event-Driven E-Commerce Platform

## Challenge Overview
Design a comprehensive event-driven messaging architecture for a global e-commerce platform that handles 1 million orders per day across multiple regions with strict reliability and compliance requirements.

**Time Limit**: 90 minutes
**Format**: Individual design exercise with presentation
**Evaluation**: Technical design, scalability, and business alignment

## Business Context

### Company Profile: GlobalMart
- **Scale**: 50M+ active users, 10M+ products, 100+ countries
- **Peak Traffic**: 1M orders/day, 50K concurrent users
- **Business Model**: B2C marketplace with third-party sellers
- **Compliance**: PCI DSS, GDPR, SOX requirements
- **SLA**: 99.99% uptime, <100ms API response time

### Current Pain Points
1. **Monolithic Architecture**: Single database bottleneck
2. **Manual Processes**: Order fulfillment requires human intervention
3. **Data Inconsistency**: Inventory and pricing sync issues
4. **Limited Scalability**: Cannot handle seasonal traffic spikes
5. **Poor Observability**: Difficult to trace order processing issues

## Design Requirements

### Functional Requirements
1. **Order Processing**: Complete order lifecycle management
2. **Inventory Management**: Real-time inventory updates across channels
3. **Payment Processing**: Multi-currency, multiple payment methods
4. **Notification System**: Real-time customer and seller notifications
5. **Analytics**: Real-time business metrics and reporting
6. **Integration**: Third-party logistics and payment providers

### Non-Functional Requirements
1. **Scalability**: Handle 10x traffic during peak events
2. **Reliability**: 99.99% uptime with graceful degradation
3. **Performance**: <100ms API response, <5s order processing
4. **Security**: End-to-end encryption, audit trails
5. **Compliance**: GDPR, PCI DSS, financial regulations
6. **Cost**: Optimize for variable workloads

### Technical Constraints
1. **AWS Services**: Must use AWS messaging services
2. **Event Sourcing**: Critical business events must be event-sourced
3. **Multi-Region**: Active-active deployment across 3 regions
4. **Legacy Integration**: Must integrate with existing systems
5. **Team Skills**: Team familiar with Python/Java, limited Kafka experience

## Design Tasks

### Task 1: High-Level Architecture (20 minutes)
Design the overall system architecture including:
- **Service Decomposition**: Identify microservices and boundaries
- **Message Flow**: Event flow between services
- **Data Storage**: Event stores and read models
- **Integration Points**: External system connections

**Deliverables:**
- Architecture diagram
- Service responsibility matrix
- Technology stack selection

### Task 2: Event Design (25 minutes)
Design the event-driven workflows for:
- **Order Processing**: From cart to delivery
- **Inventory Management**: Stock updates and reservations
- **Payment Processing**: Authorization to settlement
- **Notification Delivery**: Customer and seller alerts

**Deliverables:**
- Event flow diagrams
- Event schema definitions
- State transition models
- Error handling strategies

### Task 3: AWS Implementation (25 minutes)
Design AWS messaging implementation:
- **Service Selection**: Choose appropriate AWS services
- **Configuration**: Queue/topic configurations
- **Scaling Strategy**: Auto-scaling and performance optimization
- **Monitoring**: Observability and alerting setup

**Deliverables:**
- AWS service architecture
- Configuration specifications
- Scaling policies
- Monitoring dashboard design

### Task 4: Reliability & Compliance (20 minutes)
Address reliability and compliance requirements:
- **Error Handling**: Failure scenarios and recovery
- **Data Consistency**: Eventual consistency management
- **Security**: Encryption and access control
- **Compliance**: Audit trails and data protection

**Deliverables:**
- Failure mode analysis
- Security architecture
- Compliance framework
- Disaster recovery plan

## Evaluation Criteria

### Technical Excellence (40%)
- **Architecture Quality**: Service design and boundaries
- **Technology Selection**: Appropriate AWS service choices
- **Scalability Design**: Ability to handle growth
- **Performance Optimization**: Latency and throughput considerations

### Business Alignment (25%)
- **Requirements Coverage**: Addresses all business needs
- **Cost Optimization**: Efficient resource utilization
- **Compliance**: Meets regulatory requirements
- **User Experience**: Customer and seller experience

### Implementation Feasibility (20%)
- **Technical Feasibility**: Realistic implementation approach
- **Migration Strategy**: Path from current to target state
- **Team Capabilities**: Aligns with team skills
- **Risk Management**: Identifies and mitigates risks

### Communication (15%)
- **Clarity**: Clear explanation of design decisions
- **Trade-offs**: Articulates architectural trade-offs
- **Justification**: Provides rationale for choices
- **Presentation**: Professional delivery

## Sample Solution Framework

### High-Level Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web/Mobile    │    │   API Gateway   │    │  Load Balancer  │
│   Applications  │───▶│   (Rate Limit)  │───▶│   (Multi-AZ)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EventBridge Custom Bus                        │
│                   (ecommerce-events)                            │
└─────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Order Service   │    │Inventory Service│    │Payment Service  │
│ (Event Sourced) │    │ (Event Sourced) │    │ (Event Sourced) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   SQS FIFO      │    │   SNS Topics    │    │   SQS Standard  │
│ (Order Events)  │    │(Inventory Sync) │    │(Payment Events) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Event Flow Example
```
Order Placed → Inventory Reserved → Payment Authorized → 
Order Confirmed → Fulfillment Started → Shipping Label Created → 
Order Shipped → Delivery Confirmed → Order Completed
```

### AWS Service Selection
- **EventBridge**: Central event routing and integration
- **SQS FIFO**: Order processing with guaranteed ordering
- **SNS**: Fan-out notifications to multiple subscribers
- **DynamoDB**: Event store and read models
- **Lambda**: Event processing functions
- **MSK**: High-throughput analytics streaming

## Common Pitfalls to Avoid

### Architecture Pitfalls
- **Over-Engineering**: Too many services for the problem size
- **Under-Engineering**: Not enough service decomposition
- **Wrong Boundaries**: Services that are too coupled
- **Missing Error Handling**: No strategy for failure scenarios

### AWS Service Pitfalls
- **Wrong Service Choice**: Using SQS when SNS is better
- **No Scaling Strategy**: Not planning for growth
- **Security Gaps**: Missing encryption or access controls
- **Cost Blindness**: Not considering cost implications

### Event Design Pitfalls
- **Large Events**: Events with too much data
- **Missing Events**: Not capturing important business events
- **Wrong Granularity**: Events too fine or too coarse
- **No Versioning**: Not planning for schema evolution

## Success Tips

### Preparation
- Review AWS messaging services documentation
- Practice drawing architecture diagrams quickly
- Understand event sourcing and CQRS patterns
- Know common messaging anti-patterns

### During the Challenge
- Start with business requirements, not technology
- Draw diagrams to communicate ideas clearly
- Explain trade-offs and decision rationale
- Address scalability and reliability explicitly
- Consider operational aspects (monitoring, debugging)

### Presentation
- Tell a story from user perspective
- Highlight key architectural decisions
- Explain how the design meets requirements
- Discuss implementation phases and risks
- Be prepared for follow-up questions

## Follow-up Questions

Be prepared to answer:
1. How would you handle a 10x increase in traffic?
2. What happens if EventBridge goes down?
3. How do you ensure data consistency across services?
4. How would you implement exactly-once processing?
5. What's your disaster recovery strategy?
6. How do you handle schema evolution?
7. What are the cost implications of your design?
8. How would you migrate from the current system?

## Submission Requirements

### Required Deliverables
1. **Architecture Diagram**: High-level system design
2. **Event Flow Diagram**: Key business process flows
3. **AWS Service Architecture**: Detailed AWS implementation
4. **Implementation Plan**: Migration and deployment strategy

### Optional Deliverables
1. **Cost Analysis**: Estimated monthly AWS costs
2. **Performance Analysis**: Expected throughput and latency
3. **Security Review**: Security controls and compliance
4. **Monitoring Strategy**: Observability and alerting plan

## Evaluation Rubric

### Excellent (90-100%)
- Comprehensive architecture addressing all requirements
- Optimal AWS service selection with clear justification
- Detailed error handling and reliability strategies
- Clear communication with professional presentation

### Good (80-89%)
- Solid architecture meeting most requirements
- Appropriate AWS service choices with some gaps
- Basic error handling and reliability considerations
- Good communication with minor presentation issues

### Satisfactory (70-79%)
- Basic architecture covering core requirements
- Reasonable AWS service selection with limitations
- Limited error handling and reliability planning
- Adequate communication with presentation gaps

### Needs Improvement (<70%)
- Incomplete architecture missing key requirements
- Poor AWS service choices or lack of justification
- No error handling or reliability considerations
- Poor communication or unprofessional presentation

This design challenge tests your ability to apply messaging and event-driven architecture concepts to solve real-world business problems while demonstrating technical depth and practical implementation skills.
