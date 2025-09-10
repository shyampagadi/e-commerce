# Module-00 Design Challenge

## Overview
This design challenge tests your ability to apply system design fundamentals to a real-world scenario. You'll design a complete system architecture and document your decisions.

## Challenge: Social Media Analytics Platform

### Business Context
You're designing a social media analytics platform that processes posts, comments, and engagement data from multiple social networks to provide insights to businesses.

### Requirements

#### Functional Requirements
- **Data Ingestion**: Collect posts, comments, likes, shares from Twitter, Facebook, Instagram
- **Real-time Processing**: Process engagement data as it happens
- **Analytics Dashboard**: Display trends, sentiment analysis, engagement metrics
- **User Management**: Support multiple business accounts with different access levels
- **Reporting**: Generate scheduled and on-demand reports
- **API Access**: Provide REST API for third-party integrations

#### Non-Functional Requirements
- **Scale**: 10M posts per day, 100M events per day
- **Performance**: <200ms response time for dashboard queries
- **Availability**: 99.9% uptime
- **Data Retention**: 2 years of historical data
- **Security**: Encrypt data at rest and in transit
- **Cost**: Budget of $50K/month for infrastructure

#### Constraints
- Must use AWS services
- Data from social networks is rate-limited
- Some data sources may be unreliable
- Compliance with GDPR and data privacy regulations
- Team of 5 developers with mixed experience levels

## Deliverables

### 1. Requirements Analysis (20 points)
Create a comprehensive requirements document including:
- Functional requirements matrix with priorities
- Non-functional requirements with specific targets
- Quality attribute priorities and trade-offs
- Key assumptions and constraints
- Risk assessment and mitigation strategies

### 2. High-Level Architecture (25 points)
Design and document:
- System context diagram (C4 Level 1)
- Container diagram (C4 Level 2) showing major components
- Technology stack selection with rationale
- Data flow diagram showing how data moves through the system
- Integration points with external systems

### 3. Detailed Design (25 points)
Provide detailed specifications for:
- Database schema design for core entities
- API design (endpoints, request/response formats)
- Caching strategy and implementation
- Security architecture and access control
- Monitoring and logging strategy

### 4. AWS Implementation (20 points)
Create AWS-specific implementation including:
- Service selection with justification
- Multi-AZ deployment strategy
- Auto-scaling configuration
- Cost estimation breakdown
- Security and compliance implementation

### 5. Architecture Decision Records (10 points)
Document 3-5 key architectural decisions using the ADR template:
- Database technology choice (SQL vs NoSQL)
- Caching strategy selection
- Real-time processing approach
- Security and authentication method
- Data retention and archival strategy

## Evaluation Criteria

### Technical Accuracy (25%)
- Correct application of system design principles
- Appropriate technology selections
- Accurate understanding of AWS services
- Proper consideration of scalability and performance

### Architecture Quality (25%)
- Clear separation of concerns
- Appropriate abstraction levels
- Good component interactions
- Scalable and maintainable design

### Documentation Quality (25%)
- Clear and comprehensive documentation
- Effective use of diagrams
- Well-structured ADRs
- Professional presentation

### Practical Feasibility (25%)
- Realistic and implementable solution
- Appropriate consideration of constraints
- Cost-effective design
- Team and timeline considerations

## Sample Solution Structure

### Requirements Analysis Example
```
Functional Requirements:
1. Data Ingestion (Priority: High)
   - Collect posts from Twitter API
   - Collect posts from Facebook Graph API
   - Collect posts from Instagram Basic Display API
   - Handle rate limiting and retries
   - Validate and clean incoming data

2. Real-time Processing (Priority: High)
   - Process engagement events in real-time
   - Calculate engagement metrics
   - Update dashboard data
   - Trigger alerts for significant changes

Non-Functional Requirements:
1. Performance
   - Dashboard queries: <200ms response time
   - Data ingestion: 10M posts/day capacity
   - Real-time processing: <5 second latency

2. Scalability
   - Horizontal scaling for all components
   - Auto-scaling based on load
   - Database sharding strategy
```

### Architecture Diagram Example
```
┌─────────────────────────────────────────────────────────────┐
│                SOCIAL MEDIA ANALYTICS PLATFORM              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Business    │    │ Data        │    │ Third-party     │  │
│  │ Users       │    │ Sources     │    │ Integrations    │  │
│  │             │    │ (Twitter,   │    │                 │  │
│  └─────────────┘    │ Facebook,   │    └─────────────────┘  │
│        │            │ Instagram)  │            │             │
│        │            └─────────────┘            │             │
│        │                   │                   │             │
│        ▼                   ▼                   ▼             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               API Gateway                          │    │
│  └─────────────────────────────────────────────────────┘    │
│        │                                                   │
│        ▼                                                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Analytics   │    │ Data        │    │ Real-time       │  │
│  │ Dashboard   │    │ Ingestion   │    │ Processing      │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│        │                   │                   │             │
│        ▼                   ▼                   ▼             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Cache       │    │ Message     │    │ Analytics       │  │
│  │ (Redis)     │    │ Queue       │    │ Database        │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Submission Guidelines

1. **Format**: Submit as a single PDF document
2. **Length**: 10-15 pages maximum
3. **Diagrams**: Use clear, professional diagrams
4. **References**: Cite any external resources used
5. **Code**: Include relevant code snippets or configurations

## Time Limit
- **Recommended**: 4-6 hours
- **Maximum**: 8 hours
- **Breakdown**: 
  - Requirements: 1 hour
  - High-level design: 1.5 hours
  - Detailed design: 2 hours
  - AWS implementation: 1 hour
  - Documentation: 0.5 hours

## Tips for Success

1. **Start with Requirements**: Spend time understanding the problem thoroughly
2. **Think Big Picture First**: Don't get lost in details initially
3. **Consider Trade-offs**: Every decision has pros and cons
4. **Use Diagrams**: Visual communication is powerful
5. **Be Realistic**: Consider actual constraints and limitations
6. **Document Decisions**: Explain your reasoning clearly

## Next Steps

After completing this challenge:
- **Self-Assess**: Compare your solution with the evaluation criteria
- **Peer Review**: Share with colleagues for feedback
- **Iterate**: Refine your design based on feedback
- **Learn**: Identify areas for improvement and study

