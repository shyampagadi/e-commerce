# Architecture Decision Records (ADR) Index

## Module 07: Messaging and Event-Driven Systems

This directory contains Architecture Decision Records (ADRs) for messaging and event-driven system design decisions.

## Decision Records

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](./messaging-protocol-selection.md) | Messaging Protocol Selection | Accepted | 2024-09-11 |
| [ADR-002](./event-driven-architecture-strategy.md) | Event-Driven Architecture Strategy | Accepted | 2024-09-11 |
| [ADR-003](./message-ordering-guarantees.md) | Message Ordering Guarantees | Accepted | 2024-09-11 |
| [ADR-004](./error-handling-strategy.md) | Error Handling and Recovery Strategy | Accepted | 2024-09-11 |
| [ADR-005](./event-schema-management.md) | Event Schema Management | Accepted | 2024-09-11 |
| [ADR-006](./messaging-security-framework.md) | Messaging Security Framework | Accepted | 2024-09-11 |

## Decision Categories

### Protocol and Technology Selection
- Message queue vs event stream selection criteria
- Synchronous vs asynchronous communication trade-offs
- Protocol selection (AMQP, MQTT, Kafka, HTTP)
- AWS service selection (SQS, SNS, EventBridge, MSK, MQ)

### Architecture Patterns
- Event-driven architecture vs traditional request-response
- Event sourcing vs state-based persistence
- CQRS implementation strategies
- Saga pattern for distributed transactions

### Quality Attributes
- Message delivery guarantees (at-most-once, at-least-once, exactly-once)
- Ordering requirements and implementation strategies
- Consistency models and trade-offs
- Performance and scalability requirements

### Operational Concerns
- Error handling and dead letter queue strategies
- Monitoring and observability approaches
- Security and compliance requirements
- Cost optimization and resource management

## Template Usage

Use the [ADR template](./templates/ADR-TEMPLATE.md) for creating new decision records.

## Review Process

1. Create ADR using template
2. Technical review by messaging architecture team
3. Security and compliance review
4. Business stakeholder approval
5. Implementation and monitoring
