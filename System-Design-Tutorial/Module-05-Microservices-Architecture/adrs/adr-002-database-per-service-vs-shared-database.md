# ADR-002: Database per Service vs Shared Database

## Status
Accepted

## Context

In designing our microservices architecture for the e-commerce platform, we need to decide on the data management strategy. The choice between database per service and shared database will significantly impact data consistency, service independence, and system complexity.

### Current Situation
- We have 8 core microservices (User, Product, Order, Payment, Inventory, Notification, Analytics, Search)
- Each service needs to store and manage its own data
- Services need to communicate and share data for business operations
- We need to maintain data consistency across service boundaries
- The system needs to scale independently for each service

### Problem
We need to choose the appropriate data management strategy that balances:
- Service independence and autonomy
- Data consistency and integrity
- System complexity and operational overhead
- Performance and scalability
- Development and maintenance effort

## Decision

We will implement **Database per Service** pattern with the following guidelines:

### Database per Service Implementation
- **Each service owns its database**: Each microservice has its own dedicated database
- **Data isolation**: Services cannot directly access other services' databases
- **Technology diversity**: Each service can choose the most appropriate database technology
- **Independent scaling**: Each database can be scaled independently
- **Service autonomy**: Services can evolve their data models independently

### Data Synchronization Strategy
- **Event-driven synchronization**: Use domain events for data synchronization
- **Eventual consistency**: Accept eventual consistency for non-critical data
- **Saga pattern**: Use sagas for distributed transactions
- **CQRS**: Implement Command Query Responsibility Segregation where appropriate

### Database Technology Selection
- **User Service**: PostgreSQL (relational data, ACID transactions)
- **Product Service**: PostgreSQL (relational data, complex queries)
- **Order Service**: PostgreSQL (ACID transactions, consistency)
- **Payment Service**: PostgreSQL (financial data, ACID compliance)
- **Inventory Service**: DynamoDB (high throughput, simple queries)
- **Notification Service**: DynamoDB (simple data, high scale)
- **Analytics Service**: ClickHouse (analytical queries, time-series data)
- **Search Service**: Elasticsearch (full-text search, complex queries)

## Consequences

### Positive
- **Service Independence**: Services can evolve independently
- **Technology Flexibility**: Choose the best database for each service
- **Independent Scaling**: Scale databases based on service needs
- **Fault Isolation**: Database failures don't affect other services
- **Team Autonomy**: Teams can manage their own databases
- **Performance Optimization**: Optimize each database for its use case

### Negative
- **Data Consistency**: Complex to maintain consistency across services
- **Distributed Transactions**: Need to implement saga patterns
- **Data Synchronization**: Complex event-driven synchronization
- **Operational Complexity**: More databases to manage and monitor
- **Development Overhead**: More complex data access patterns
- **Testing Complexity**: Need to test distributed data scenarios

## Alternatives Considered

### Option 1: Shared Database
**Pros:**
- Simple data consistency with ACID transactions
- Easy to implement cross-service queries
- Familiar development patterns
- Simple data management

**Cons:**
- Tight coupling between services
- Difficult to scale services independently
- Single point of failure
- Technology lock-in
- Team coordination overhead

### Option 2: Hybrid Approach
**Pros:**
- Balance between consistency and independence
- Gradual migration path
- Flexibility in data management

**Cons:**
- Complex architecture
- Inconsistent patterns
- Difficult to maintain
- Unclear boundaries

### Option 3: Event Sourcing
**Pros:**
- Complete audit trail
- Temporal queries
- Event replay capabilities
- Decoupled read/write models

**Cons:**
- High complexity
- Learning curve
- Storage overhead
- Eventual consistency challenges

## Rationale

The Database per Service pattern was chosen because:

1. **Service Independence**: Our microservices need to evolve independently and have different scaling requirements

2. **Technology Diversity**: Different services have different data access patterns and requirements:
   - User and Product services need relational data with complex queries
   - Inventory service needs high-throughput simple operations
   - Analytics service needs time-series and analytical capabilities
   - Search service needs full-text search capabilities

3. **Scalability**: Each service can scale its database independently based on its specific needs

4. **Team Autonomy**: Each team can choose and manage their own database technology

5. **Fault Isolation**: Database failures in one service don't affect other services

6. **AWS Services**: AWS provides excellent support for different database technologies (RDS, DynamoDB, ElastiCache, etc.)

## Implementation Details

### Database per Service Setup
```yaml
# Database Configuration
User Service:
  Database: PostgreSQL (RDS)
  Connection Pool: 20 connections
  Backup: Automated daily backups
  Monitoring: CloudWatch metrics

Product Service:
  Database: PostgreSQL (RDS)
  Connection Pool: 30 connections
  Read Replicas: 2 for read-heavy workloads
  Backup: Automated daily backups

Inventory Service:
  Database: DynamoDB
  Provisioned Capacity: 1000 RCU, 1000 WCU
  Auto Scaling: Enabled
  Global Tables: Multi-region replication

Analytics Service:
  Database: ClickHouse
  Cluster: 3 nodes
  Replication: 2 replicas per shard
  Backup: S3-based backups
```

### Data Synchronization
```yaml
# Event-Driven Synchronization
Events:
  - UserCreated → Update Analytics Service
  - ProductUpdated → Update Search Service
  - OrderCreated → Update Inventory Service
  - PaymentProcessed → Update Order Service

Event Store:
  - Technology: Amazon EventBridge
  - Retention: 30 days
  - Dead Letter Queue: SQS DLQ for failed events
  - Monitoring: CloudWatch alarms
```

### Saga Pattern Implementation
```yaml
# Distributed Transactions
Order Processing Saga:
  1. Create Order (Order Service)
  2. Reserve Inventory (Inventory Service)
  3. Process Payment (Payment Service)
  4. Update Order Status (Order Service)
  5. Send Notification (Notification Service)

Compensating Actions:
  - Release Inventory
  - Refund Payment
  - Cancel Order
  - Send Cancellation Notification
```

### Data Consistency Strategy
```yaml
# Consistency Levels
Strong Consistency:
  - User authentication data
  - Payment transactions
  - Order status updates
  - Financial calculations

Eventual Consistency:
  - Product recommendations
  - Analytics data
  - Search indexes
  - Notification preferences

Consistency Patterns:
  - Saga Pattern: For distributed transactions
  - Event Sourcing: For audit trails
  - CQRS: For read/write separation
  - Eventual Consistency: For non-critical data
```

## Monitoring and Observability

### Database Monitoring
- **CloudWatch Metrics**: CPU, memory, disk, connections
- **Custom Metrics**: Query performance, transaction rates
- **Alerts**: High CPU, low disk space, connection limits
- **Dashboards**: Service-specific database dashboards

### Data Consistency Monitoring
- **Event Processing**: Monitor event processing rates
- **Saga Completion**: Track saga success/failure rates
- **Data Drift**: Detect data inconsistencies
- **Sync Delays**: Monitor data synchronization delays

## Migration Strategy

### Phase 1: Service Isolation
1. Identify data ownership for each service
2. Create separate databases for each service
3. Implement data access layers
4. Migrate data to service-specific databases

### Phase 2: Event Implementation
1. Implement domain events
2. Set up event-driven synchronization
3. Implement saga patterns
4. Test data consistency

### Phase 3: Optimization
1. Optimize database performance
2. Implement caching strategies
3. Fine-tune consistency patterns
4. Monitor and adjust

## References

- [Database per Service Pattern](https://microservices.io/patterns/data/database-per-service.html)
- [Saga Pattern](https://microservices.io/patterns/data/saga.html)
- [Event Sourcing](https://microservices.io/patterns/data/event-sourcing.html)
- [CQRS Pattern](https://microservices.io/patterns/data/cqrs.html)
- [AWS Database Services](https://aws.amazon.com/products/databases/)

## Related ADRs

- ADR-001: Synchronous vs Asynchronous Communication
- ADR-003: Event-Driven Architecture
- ADR-004: CQRS Implementation
- ADR-005: Saga Pattern Implementation
