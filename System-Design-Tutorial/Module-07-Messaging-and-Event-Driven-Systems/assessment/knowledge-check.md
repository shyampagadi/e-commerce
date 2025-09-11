# Module 07: Knowledge Check - Messaging and Event-Driven Systems

## Instructions
This comprehensive assessment covers all aspects of messaging and event-driven systems. Answer all questions to demonstrate your understanding of the concepts, patterns, and AWS implementations covered in this module.

**Time Limit**: 90 minutes
**Total Questions**: 50
**Passing Score**: 80% (40/50 correct answers)

---

## Section A: Messaging Fundamentals (Questions 1-15)

### Question 1
What is the primary difference between message queues and event streams?

A) Message queues are faster than event streams
B) Event streams store messages permanently while queues delete them after consumption
C) Message queues are point-to-point while event streams support multiple consumers
D) Event streams are only for real-time processing while queues are for batch processing

**Answer**: C
**Explanation**: Message queues typically implement point-to-point communication where each message is consumed by one consumer, while event streams allow multiple consumers to read the same events.

### Question 2
Which delivery guarantee ensures messages are never lost but may be duplicated?

A) At-most-once
B) At-least-once
C) Exactly-once
D) Best-effort

**Answer**: B
**Explanation**: At-least-once delivery guarantees that messages will be delivered one or more times, ensuring no message loss but potentially allowing duplicates.

### Question 3
In the context of message ordering, what does FIFO guarantee?

A) Messages are processed as fast as possible
B) Messages are delivered in the exact order they were sent
C) Messages are never duplicated
D) Messages are automatically retried on failure

**Answer**: B
**Explanation**: FIFO (First-In-First-Out) guarantees that messages are processed in the exact order they were sent to the queue.

### Question 4
What is the main purpose of a dead letter queue (DLQ)?

A) To store messages permanently
B) To handle messages that cannot be processed successfully
C) To improve message processing speed
D) To implement message ordering

**Answer**: B
**Explanation**: Dead letter queues store messages that have failed processing multiple times, allowing for manual inspection and handling.

### Question 5
Which messaging pattern is best suited for notifying multiple services about a single event?

A) Request-Reply
B) Point-to-Point
C) Publish-Subscribe
D) Message Routing

**Answer**: C
**Explanation**: Publish-Subscribe (pub/sub) pattern allows one publisher to send messages to multiple subscribers, making it ideal for event notifications.

### Question 6
What is backpressure in messaging systems?

A) The pressure to process messages quickly
B) A mechanism to handle when consumers can't keep up with producers
C) The force applied to compress messages
D) A security feature to prevent unauthorized access

**Answer**: B
**Explanation**: Backpressure is a mechanism to handle situations where message producers are generating messages faster than consumers can process them.

### Question 7
In event sourcing, what is an aggregate?

A) A collection of related events
B) A business entity that generates events
C) A summary of all events in the system
D) A database table storing events

**Answer**: B
**Explanation**: In event sourcing, an aggregate is a business entity (like an Order or Customer) that generates and processes events representing state changes.

### Question 8
What is the primary benefit of using message schemas?

A) Faster message processing
B) Reduced storage requirements
C) Contract definition and evolution management
D) Automatic message routing

**Answer**: C
**Explanation**: Message schemas define the structure and contract of messages, enabling safe evolution and ensuring compatibility between producers and consumers.

### Question 9
Which pattern helps coordinate distributed transactions across multiple services?

A) Circuit Breaker
B) Saga Pattern
C) Observer Pattern
D) Factory Pattern

**Answer**: B
**Explanation**: The Saga pattern manages distributed transactions by coordinating a sequence of local transactions across multiple services.

### Question 10
What is the main advantage of asynchronous messaging over synchronous communication?

A) Faster response times
B) Simpler error handling
C) Better fault tolerance and decoupling
D) Easier debugging

**Answer**: C
**Explanation**: Asynchronous messaging provides better fault tolerance by allowing services to operate independently and reduces coupling between services.

### Question 11
In CQRS (Command Query Responsibility Segregation), what is the primary separation?

A) Read and write operations use different models
B) Commands and queries use different databases
C) Synchronous and asynchronous operations are separated
D) Internal and external APIs are separated

**Answer**: A
**Explanation**: CQRS separates read operations (queries) and write operations (commands) into different models, allowing each to be optimized for its specific use case.

### Question 12
What is idempotency in message processing?

A) Processing messages only once
B) Processing messages in order
C) Processing the same message multiple times with the same result
D) Processing messages as fast as possible

**Answer**: C
**Explanation**: Idempotency means that processing the same message multiple times produces the same result, making the system resilient to message duplicates.

### Question 13
Which messaging protocol is commonly used for IoT devices due to its lightweight nature?

A) AMQP
B) HTTP
C) MQTT
D) WebSocket

**Answer**: C
**Explanation**: MQTT (Message Queuing Telemetry Transport) is designed for lightweight, low-bandwidth communication, making it ideal for IoT devices.

### Question 14
What is the purpose of message correlation IDs?

A) To ensure message ordering
B) To track related messages across different services
C) To prevent message duplication
D) To compress message content

**Answer**: B
**Explanation**: Correlation IDs help track related messages as they flow through different services, enabling distributed tracing and debugging.

### Question 15
In event-driven architecture, what is event sourcing?

A) Finding the source of events
B) Storing all changes as a sequence of events
C) Routing events to appropriate handlers
D) Compressing event data

**Answer**: B
**Explanation**: Event sourcing is a pattern where all changes to application state are stored as a sequence of immutable events, rather than storing current state.

---

## Section B: AWS Messaging Services (Questions 16-30)

### Question 16
What is the maximum message size for Amazon SQS?

A) 64 KB
B) 256 KB
C) 1 MB
D) 10 MB

**Answer**: B
**Explanation**: Amazon SQS supports messages up to 256 KB in size. Larger messages can be handled using the SQS Extended Client Library with S3.

### Question 17
Which SQS queue type guarantees message ordering?

A) Standard Queue
B) FIFO Queue
C) Priority Queue
D) Delay Queue

**Answer**: B
**Explanation**: FIFO (First-In-First-Out) queues guarantee that messages are processed in the exact order they are sent.

### Question 18
What is the maximum retention period for messages in Amazon SQS?

A) 1 day
B) 7 days
C) 14 days
D) 30 days

**Answer**: C
**Explanation**: Amazon SQS can retain messages for up to 14 days (1,209,600 seconds).

### Question 19
In Amazon SNS, what is a filter policy used for?

A) To encrypt messages
B) To route messages to specific subscribers based on message attributes
C) To compress messages
D) To order messages

**Answer**: B
**Explanation**: Filter policies in SNS allow subscribers to receive only messages that match specific criteria based on message attributes.

### Question 20
What is the maximum number of subscribers per SNS topic?

A) 1,000
B) 10,000
C) 12,500,000
D) Unlimited

**Answer**: C
**Explanation**: Amazon SNS supports up to 12,500,000 subscriptions per topic.

### Question 21
Which AWS service provides serverless event routing with rules and patterns?

A) Amazon SQS
B) Amazon SNS
C) Amazon EventBridge
D) Amazon Kinesis

**Answer**: C
**Explanation**: Amazon EventBridge provides serverless event routing with sophisticated rule-based routing and event pattern matching.

### Question 22
What is the default visibility timeout for Amazon SQS messages?

A) 30 seconds
B) 60 seconds
C) 5 minutes
D) 12 hours

**Answer**: A
**Explanation**: The default visibility timeout for SQS messages is 30 seconds, though it can be configured from 0 seconds to 12 hours.

### Question 23
Which AWS service is best for high-throughput, real-time event streaming?

A) Amazon SQS
B) Amazon SNS
C) Amazon MSK (Managed Streaming for Apache Kafka)
D) Amazon EventBridge

**Answer**: C
**Explanation**: Amazon MSK (Managed Streaming for Apache Kafka) is designed for high-throughput, real-time event streaming applications.

### Question 24
In Amazon EventBridge, what is an event bus?

A) A physical server that processes events
B) A logical container for events from event sources
C) A queue for storing events
D) A database for event storage

**Answer**: B
**Explanation**: An event bus in EventBridge is a logical container that receives events from event sources and routes them to targets based on rules.

### Question 25
What is the maximum batch size for SQS ReceiveMessage API?

A) 1 message
B) 5 messages
C) 10 messages
D) 100 messages

**Answer**: C
**Explanation**: The SQS ReceiveMessage API can retrieve up to 10 messages in a single request.

### Question 26
Which AWS service provides managed message brokers for ActiveMQ and RabbitMQ?

A) Amazon SQS
B) Amazon SNS
C) Amazon MQ
D) Amazon EventBridge

**Answer**: C
**Explanation**: Amazon MQ provides managed message brokers for Apache ActiveMQ and RabbitMQ.

### Question 27
What is the purpose of long polling in Amazon SQS?

A) To increase message throughput
B) To reduce the number of empty responses and lower costs
C) To guarantee message ordering
D) To encrypt messages

**Answer**: B
**Explanation**: Long polling reduces the number of empty ReceiveMessage responses, which helps reduce costs and improves efficiency.

### Question 28
In Amazon EventBridge, what is the maximum number of targets per rule?

A) 5
B) 10
C) 50
D) 100

**Answer**: A
**Explanation**: Each EventBridge rule can have up to 5 targets.

### Question 29
Which SQS feature allows you to delay message delivery?

A) Visibility Timeout
B) Message Timer
C) Delay Queue
D) Scheduled Delivery

**Answer**: C
**Explanation**: Delay queues allow you to postpone the delivery of new messages for up to 15 minutes.

### Question 30
What is the maximum message retention period in Amazon Kinesis Data Streams?

A) 24 hours
B) 7 days
C) 365 days
D) Unlimited

**Answer**: C
**Explanation**: Amazon Kinesis Data Streams can retain data for up to 365 days (8760 hours).

---

## Section C: Event-Driven Architecture Patterns (Questions 31-40)

### Question 31
In the Saga pattern, what happens when a step in the transaction fails?

A) The entire transaction is rolled back automatically
B) Compensating actions are executed to undo previous steps
C) The transaction continues with the next step
D) The transaction is retried indefinitely

**Answer**: B
**Explanation**: In the Saga pattern, when a step fails, compensating actions (compensating transactions) are executed to undo the effects of previous successful steps.

### Question 32
What is the main difference between orchestration and choreography in microservices?

A) Orchestration is faster than choreography
B) Orchestration uses a central coordinator while choreography is decentralized
C) Choreography requires more resources than orchestration
D) Orchestration is only for synchronous communication

**Answer**: B
**Explanation**: Orchestration uses a central coordinator to manage the workflow, while choreography relies on services reacting to events in a decentralized manner.

### Question 33
In event sourcing, what is a snapshot?

A) A backup of all events
B) A point-in-time state reconstruction to optimize performance
C) A compressed version of events
D) A summary of recent events

**Answer**: B
**Explanation**: A snapshot in event sourcing is a point-in-time state of an aggregate that's stored to avoid replaying all events from the beginning, improving performance.

### Question 34
What is the Outbox pattern used for?

A) Storing failed messages
B) Ensuring reliable event publishing in distributed transactions
C) Routing messages to external systems
D) Compressing outgoing messages

**Answer**: B
**Explanation**: The Outbox pattern ensures reliable event publishing by storing events in the same database transaction as business data, then publishing them separately.

### Question 35
In CQRS, what is a projection?

A) A prediction of future events
B) A read model built from events
C) A compressed view of data
D) A backup of the command model

**Answer**: B
**Explanation**: A projection in CQRS is a read model that's built by processing events, optimized for specific query requirements.

### Question 36
What is eventual consistency in distributed systems?

A) Data is always consistent across all nodes
B) Data will become consistent over time, but may be temporarily inconsistent
C) Data consistency is not guaranteed
D) Data is consistent only during business hours

**Answer**: B
**Explanation**: Eventual consistency means that the system will become consistent over time, but there may be periods where different nodes have different views of the data.

### Question 37
Which pattern helps prevent cascading failures in distributed systems?

A) Observer Pattern
B) Circuit Breaker Pattern
C) Factory Pattern
D) Singleton Pattern

**Answer**: B
**Explanation**: The Circuit Breaker pattern prevents cascading failures by stopping calls to a failing service and providing fallback behavior.

### Question 38
What is the primary purpose of event versioning?

A) To track the number of events
B) To handle schema evolution and backward compatibility
C) To improve event processing speed
D) To reduce storage requirements

**Answer**: B
**Explanation**: Event versioning handles schema evolution, allowing systems to process both old and new event formats while maintaining backward compatibility.

### Question 39
In event-driven architecture, what is a bounded context?

A) A limit on the number of events
B) A logical boundary within which a domain model is defined
C) A time limit for event processing
D) A security boundary for events

**Answer**: B
**Explanation**: A bounded context is a logical boundary within which a particular domain model is defined and applicable, helping to organize complex domains.

### Question 40
What is the main benefit of using event streaming over traditional messaging?

A) Lower latency
B) Better security
C) Ability to replay events and build multiple views
D) Simpler implementation

**Answer**: C
**Explanation**: Event streaming allows events to be stored and replayed, enabling multiple consumers to build different views of the same data and supporting temporal queries.

---

## Section D: Implementation and Best Practices (Questions 41-50)

### Question 41
When implementing exactly-once processing, which approach is most commonly used?

A) Duplicate detection
B) Idempotent operations
C) Message ordering
D) Synchronous processing

**Answer**: B
**Explanation**: Idempotent operations ensure that processing the same message multiple times produces the same result, effectively achieving exactly-once semantics.

### Question 42
What is the recommended approach for handling poison messages?

A) Delete them immediately
B) Retry them indefinitely
C) Move them to a dead letter queue after maximum retries
D) Process them synchronously

**Answer**: C
**Explanation**: Poison messages should be moved to a dead letter queue after reaching the maximum retry limit, allowing for manual inspection and handling.

### Question 43
Which metric is most important for monitoring message processing performance?

A) Message size
B) Queue depth and processing latency
C) Number of consumers
D) Message format

**Answer**: B
**Explanation**: Queue depth and processing latency are critical metrics that indicate whether the system is keeping up with the message load and how quickly messages are being processed.

### Question 44
What is the best practice for message payload design?

A) Include all possible data to avoid additional lookups
B) Keep payloads small and include only essential data
C) Always use binary format for efficiency
D) Include sensitive data for completeness

**Answer**: B
**Explanation**: Message payloads should be kept small and contain only essential data to improve performance, reduce costs, and maintain security.

### Question 45
When should you use message batching?

A) Always, to improve performance
B) When individual message processing is expensive
C) Only for large messages
D) Never, as it complicates error handling

**Answer**: B
**Explanation**: Message batching is beneficial when the overhead of processing individual messages is high, but it should be balanced against the complexity it introduces.

### Question 46
What is the recommended approach for error handling in event-driven systems?

A) Ignore errors to maintain performance
B) Implement retry with exponential backoff and circuit breakers
C) Always retry immediately
D) Stop processing on any error

**Answer**: B
**Explanation**: A combination of retry with exponential backoff and circuit breakers provides resilient error handling while preventing system overload.

### Question 47
How should you handle schema evolution in event-driven systems?

A) Never change schemas once deployed
B) Use versioning and maintain backward compatibility
C) Always use the latest schema version
D) Create new topics for each schema change

**Answer**: B
**Explanation**: Schema versioning with backward compatibility allows systems to evolve while maintaining interoperability with existing consumers.

### Question 48
What is the best practice for testing event-driven systems?

A) Test only individual components
B) Use contract testing and end-to-end testing
C) Rely only on unit tests
D) Test in production only

**Answer**: B
**Explanation**: Contract testing ensures service compatibility, while end-to-end testing validates the complete event flow across the system.

### Question 49
When implementing event sourcing, how should you handle large event streams?

A) Store all events in memory
B) Use snapshots and event archiving
C) Delete old events regularly
D) Compress all events

**Answer**: B
**Explanation**: Snapshots reduce the need to replay all events, while archiving moves old events to cheaper storage, maintaining performance and controlling costs.

### Question 50
What is the most important consideration when designing event schemas?

A) Making them as detailed as possible
B) Ensuring they are forward and backward compatible
C) Using the smallest possible data types
D) Including version numbers in every field

**Answer**: B
**Explanation**: Forward and backward compatibility in event schemas is crucial for system evolution and maintaining interoperability between different versions of services.

---

## Answer Key Summary

**Section A (Messaging Fundamentals)**: 1-C, 2-B, 3-B, 4-B, 5-C, 6-B, 7-B, 8-C, 9-B, 10-C, 11-A, 12-C, 13-C, 14-B, 15-B

**Section B (AWS Messaging Services)**: 16-B, 17-B, 18-C, 19-B, 20-C, 21-C, 22-A, 23-C, 24-B, 25-C, 26-C, 27-B, 28-A, 29-C, 30-C

**Section C (Event-Driven Architecture Patterns)**: 31-B, 32-B, 33-B, 34-B, 35-B, 36-B, 37-B, 38-B, 39-B, 40-C

**Section D (Implementation and Best Practices)**: 41-B, 42-C, 43-B, 44-B, 45-B, 46-B, 47-B, 48-B, 49-B, 50-B

---

## Scoring Guide

- **45-50 correct (90-100%)**: Excellent - You have mastered messaging and event-driven systems
- **40-44 correct (80-88%)**: Good - You have a solid understanding with minor gaps
- **35-39 correct (70-78%)**: Satisfactory - Review key concepts and patterns
- **30-34 correct (60-68%)**: Needs Improvement - Significant review required
- **Below 30 correct (<60%)**: Unsatisfactory - Complete module review recommended

## Next Steps

Based on your score:
- **90%+**: Ready for advanced topics and real-world implementation
- **80-89%**: Review specific areas where you missed questions
- **70-79%**: Revisit core concepts and complete additional exercises
- **<70%**: Retake the module content and exercises before proceeding

## Additional Resources

For areas needing improvement, refer to:
- Module 07 concept files for theoretical understanding
- AWS documentation for service-specific details
- Hands-on exercises for practical experience
- Case studies for real-world application examples
