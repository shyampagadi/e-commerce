# ADR-003: Message Routing Strategy

## Status
Accepted

## Context
Our e-commerce platform needs a comprehensive message routing strategy to handle complex event flows between microservices. The system must support various routing patterns including content-based routing, topic-based routing, and dynamic routing based on business rules.

### Problem Statement
We need to route messages efficiently between 20+ microservices with different routing requirements:
- Order events need to reach multiple services (inventory, payment, notification)
- Customer events require filtering based on customer segments
- System events need priority-based routing
- Integration events require transformation and routing to external systems

### Requirements
- **Scalability**: Handle 100K+ messages per hour
- **Flexibility**: Support multiple routing patterns
- **Reliability**: Guaranteed message delivery with error handling
- **Observability**: Complete visibility into message flows
- **Performance**: <50ms routing latency
- **Cost Efficiency**: Optimize for variable workloads

### Constraints
- Must use AWS messaging services
- Integration with existing EventBridge setup
- Team familiar with JSON-based configurations
- Compliance with data residency requirements
- Budget constraints for high-volume messaging

## Decision
We will implement a hybrid message routing strategy using Amazon EventBridge as the primary routing engine, supplemented by SNS for fan-out patterns and SQS for point-to-point delivery.

### Options Considered

#### Option 1: EventBridge-Only Routing
- **Pros**: Unified routing platform, rich pattern matching, AWS-native integrations
- **Cons**: Higher costs at scale, limited throughput per rule, complex rule management
- **Cost**: $1.00 per million events + target costs
- **Risk**: Vendor lock-in, rule complexity management

#### Option 2: SNS Topic-Based Routing
- **Pros**: High throughput, simple pub/sub model, cost-effective
- **Cons**: Limited routing logic, no content-based filtering, topic proliferation
- **Cost**: $0.50 per million publishes + delivery costs
- **Risk**: Topic management complexity, limited filtering capabilities

#### Option 3: Custom Routing Service
- **Pros**: Complete control, optimized for specific needs, no service limits
- **Cons**: High development cost, operational overhead, maintenance burden
- **Cost**: Development + infrastructure costs
- **Risk**: Development complexity, operational burden, scalability challenges

#### Option 4: Hybrid Approach (EventBridge + SNS + SQS)
- **Pros**: Best of all worlds, optimized for different patterns, cost-effective
- **Cons**: Increased complexity, multiple services to manage
- **Cost**: Optimized based on usage patterns
- **Risk**: Integration complexity, multiple failure points

### Selected Option: Hybrid Approach
The hybrid approach provides optimal balance of functionality, performance, and cost while leveraging AWS-native services for reliability and scalability.

## Implementation

### Architecture Design
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Publishers    │    │   EventBridge   │    │   Subscribers   │
│                 │    │   Custom Bus    │    │                 │
│ • Order Service │───▶│                 │───▶│ • Inventory Svc │
│ • User Service  │    │ Content-Based   │    │ • Payment Svc   │
│ • System Events │    │ Routing Rules   │    │ • Notification  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │   SNS Topics    │
                    │                 │
                    │ • High Volume   │
                    │ • Fan-out       │
                    │ • Simple Routing│
                    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │   SQS Queues    │
                    │                 │
                    │ • Point-to-Point│
                    │ • Guaranteed    │
                    │ • Ordered (FIFO)│
                    └─────────────────┘
```

### Routing Strategy Matrix

| Message Type | Volume | Routing Complexity | Primary Service | Secondary Service |
|--------------|--------|-------------------|-----------------|-------------------|
| Order Events | High | Complex | EventBridge | SNS |
| User Events | Medium | Medium | EventBridge | SQS |
| System Events | Low | Simple | SNS | SQS |
| Integration Events | Low | Complex | EventBridge | SQS |
| Notification Events | High | Simple | SNS | SQS |

### EventBridge Rules Configuration

**High-Value Order Routing**
- **Event Pattern**: Orders with total amount >= $1000
- **Targets**: High-value order queue and fraud alert system
- **Purpose**: Prioritize high-value orders and fraud detection
- **Configuration**: FIFO queue with message grouping

**Customer Segment Routing**
- **Event Pattern**: Premium and enterprise customer updates
- **Targets**: Premium customer processing queue
- **Purpose**: Special handling for high-value customers
- **Configuration**: Dedicated queue for premium customers

### SNS Topic Strategy

**Order Notifications Topic**
- **Purpose**: Fan-out order status updates to multiple subscribers
- **Subscribers**: Customer notifications, seller notifications, analytics
- **Filter Policy**: Filter by order status and customer segment
- **Use Case**: Real-time order status updates

**System Alerts Topic**
- **Purpose**: System-wide notifications and alerts
- **Subscribers**: Operations team, monitoring system, audit logs
- **Filter Policy**: Filter by severity level
- **Use Case**: Operational alerts and system notifications

**Integration Events Topic**
- **Purpose**: External system integration events
- **Subscribers**: ERP, CRM, warehouse systems
- **Filter Policy**: Filter by event type and destination
- **Use Case**: External system integration and data synchronization

### Message Transformation Rules

**Transformation Strategy**
- **Order to Inventory**: Transform order events for inventory service
- **Customer to CRM**: Transform customer events for CRM system
- **Payment to Accounting**: Transform payment events for accounting system
- **Dynamic Transformation**: Apply transformations based on routing destination

**Transformation Patterns**
- **Data Mapping**: Map source fields to target fields
- **Format Conversion**: Convert between different data formats
- **Field Addition**: Add required fields for target systems
- **Field Removal**: Remove unnecessary fields for target systems

**Transformation Examples**
- **Inventory Reservation**: Transform order data to inventory reservation format
- **CRM Update**: Transform customer data to CRM update format
- **Accounting Entry**: Transform payment data to accounting entry format
- **External Integration**: Transform internal events to external system format

### Technology Stack
- **Primary Routing**: Amazon EventBridge with custom event bus
- **Fan-out Routing**: Amazon SNS with message filtering
- **Point-to-Point**: Amazon SQS (Standard and FIFO)
- **Dead Letter Queues**: SQS for failed message handling
- **Monitoring**: CloudWatch metrics and X-Ray tracing
- **Configuration**: Infrastructure as Code with CloudFormation

### Migration Strategy

#### Phase 1: Foundation (Weeks 1-2)
- Set up EventBridge custom bus
- Create core SNS topics and SQS queues
- Implement basic routing rules
- Set up monitoring and alerting

#### Phase 2: Core Services (Weeks 3-4)
- Migrate order processing routing
- Implement customer event routing
- Add message transformation logic
- Test end-to-end flows

#### Phase 3: Advanced Features (Weeks 5-6)
- Implement complex routing rules
- Add external system integrations
- Optimize performance and costs
- Complete monitoring setup

#### Phase 4: Production Rollout (Weeks 7-8)
- Gradual traffic migration
- Performance validation
- Cost optimization
- Documentation and training

## Consequences

### Positive Outcomes
- **Flexibility**: Support for multiple routing patterns in single architecture
- **Scalability**: Each service optimized for its specific use case
- **Cost Optimization**: Pay only for what you use with appropriate service selection
- **Reliability**: Built-in redundancy and error handling across services
- **Observability**: Complete visibility into message flows and performance
- **Maintainability**: Clear separation of concerns and standardized patterns

### Negative Outcomes
- **Complexity**: Multiple services to configure and manage
- **Learning Curve**: Team needs to understand multiple AWS services
- **Debugging**: More complex troubleshooting across multiple services
- **Operational Overhead**: More services to monitor and maintain
- **Integration Testing**: More complex testing scenarios

### Risks and Mitigation

#### Risk: Service Integration Complexity
**Mitigation**:
- Comprehensive integration testing
- Clear documentation and runbooks
- Automated deployment and configuration
- Team training and knowledge sharing

#### Risk: Message Routing Failures
**Mitigation**:
- Dead letter queues for all routing paths
- Comprehensive monitoring and alerting
- Automated retry mechanisms
- Circuit breaker patterns for downstream failures

#### Risk: Cost Overruns
**Mitigation**:
- Regular cost monitoring and optimization
- Usage-based alerting and budgets
- Periodic architecture reviews
- Cost allocation and chargeback models

## Monitoring and Success Criteria

### Key Metrics
- **Routing Latency**: <50ms average routing time
- **Message Throughput**: 100K+ messages/hour capacity
- **Delivery Success Rate**: >99.9% successful delivery
- **Error Rate**: <0.1% routing failures
- **Cost per Message**: Optimized cost per message routed

### Success Criteria
- All message types routed correctly according to business rules
- Performance targets met under peak load conditions
- Cost targets achieved with optimized service usage
- Zero data loss during routing operations
- Complete observability into message flows

### Review Schedule
- **Weekly**: Performance and cost metrics review
- **Monthly**: Architecture optimization review
- **Quarterly**: Strategic alignment and technology updates
- **Annually**: Complete architecture review and planning

## Related Decisions
- ADR-001: Messaging Architecture Strategy
- ADR-002: Event Sourcing Implementation Strategy
- ADR-004: Event Schema Design Standards (Planned)
- ADR-005: Performance Optimization Strategy (Planned)

## References
- [Amazon EventBridge User Guide](https://docs.aws.amazon.com/eventbridge/)
- [Amazon SNS Developer Guide](https://docs.aws.amazon.com/sns/)
- [Enterprise Integration Patterns](https://www.enterpriseintegrationpatterns.com/)
- [AWS Messaging Best Practices](https://aws.amazon.com/messaging/)
- [Event-Driven Architecture Patterns](https://aws.amazon.com/event-driven-architecture/)

---

**Decision Date**: 2024-01-15
**Review Date**: 2024-04-15
**Participants**: Platform Architecture Team, Engineering Leads, DevOps Team
**Stakeholders**: Engineering, Operations, Product Management, Finance
