# System Design Interview Framework

## Overview

A structured approach to system design interviews that helps candidates demonstrate their architectural thinking, problem-solving skills, and technical knowledge in a systematic manner.

## Table of Contents
- [Interview Structure](#interview-structure)
- [Step-by-Step Process](#step-by-step-process)
- [Key Diagrams to Draw](#key-diagrams-to-draw)
- [Common Pitfalls](#common-pitfalls)
- [Practice Checklist](#practice-checklist)

## Interview Structure

### Time Allocation (45-60 minutes)
- **Requirements Clarification**: 5-10 minutes
- **High-Level Design**: 10-15 minutes
- **Detailed Design**: 15-20 minutes
- **Scale the Design**: 10-15 minutes
- **Deep Dive & Trade-offs**: 5-10 minutes

### Interview Phases

```
┌─────────────────────────────────────────────────────────────┐
│                SYSTEM DESIGN INTERVIEW FLOW                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Requirements│    │ High-Level  │    │ Detailed        │  │
│  │ Clarification│   │ Design      │    │ Design          │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│        │                  │                  │              │
│        ▼                  ▼                  ▼              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Scale the   │    │ Deep Dive   │    │ Wrap-up &       │  │
│  │ Design      │    │ & Trade-offs│    │ Questions       │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Step-by-Step Process

### 1. Requirements Clarification (5-10 minutes)

**Goal**: Understand the problem scope and constraints

**Questions to Ask**:
- What is the main purpose of the system?
- Who are the users and how many?
- What are the key features?
- What are the non-functional requirements?
- What are the constraints?

**Key Questions Checklist**:
- [ ] Scale: How many users? Requests per second?
- [ ] Features: Core vs. nice-to-have features
- [ ] Data: What data needs to be stored?
- [ ] Performance: Latency, throughput requirements
- [ ] Availability: Uptime requirements
- [ ] Consistency: Data consistency needs
- [ ] Security: Authentication, authorization needs
- [ ] Budget: Cost constraints
- [ ] Timeline: Development timeline

**Example Clarification**:
```
Interviewer: "Design a URL shortener like bit.ly"
Candidate: "Let me clarify the requirements:
- Scale: 100M URLs per day, 1B reads per day
- Features: Shorten URL, redirect, analytics
- Latency: <100ms for redirects
- Availability: 99.9%
- URL length: 6-8 characters
- Custom URLs: Optional
- Analytics: Click tracking
- Expiration: Optional"
```

### 2. High-Level Design (10-15 minutes)

**Goal**: Create a system overview with major components

**Components to Include**:
- Client applications
- Load balancers
- Web servers
- Application servers
- Databases
- Caching layers
- CDN

**High-Level Architecture Diagram**:

```
┌─────────────────────────────────────────────────────────────┐
│                    HIGH-LEVEL DESIGN                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐                       ┌─────────────────┐  │
│  │ Client      │                       │ CDN             │  │
│  │ (Web/Mobile)│                       │ (CloudFront)    │  │
│  └─────────────┘                       └─────────────────┘  │
│        │                                      │             │
│        ▼                                      │             │
│  ┌─────────────┐                             │             │
│  │ Load        │                             │             │
│  │ Balancer    │                             │             │
│  └─────────────┘                             │             │
│        │                                      │             │
│        ▼                                      │             │
│  ┌─────────────┐    ┌─────────────┐          │             │
│  │ Web         │    │ App         │          │             │
│  │ Servers     │    │ Servers     │          │             │
│  └─────────────┘    └─────────────┘          │             │
│        │                  │                  │             │
│        ▼                  ▼                  │             │
│  ┌─────────────┐    ┌─────────────┐          │             │
│  │ Cache       │    │ Database    │          │             │
│  │ (Redis)     │    │ (MySQL)     │          │             │
│  └─────────────┘    └─────────────┘          │             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key Points**:
- Start simple, add complexity gradually
- Show data flow
- Identify single points of failure
- Consider scalability bottlenecks

### 3. Detailed Design (15-20 minutes)

**Goal**: Dive deep into specific components and their interactions

**Areas to Cover**:
- API design
- Database schema
- Data flow
- Caching strategy
- Security considerations

**API Design Example**:
```
POST /api/v1/shorten
{
  "url": "https://example.com/very-long-url",
  "custom_alias": "optional",
  "expiration": "2024-12-31"
}

GET /{short_code}
→ 301 Redirect to original URL

GET /api/v1/analytics/{short_code}
→ Returns click statistics
```

**Database Schema Example**:
```
urls table:
- id (bigint, primary key)
- short_code (varchar(8), unique)
- original_url (text)
- user_id (bigint, foreign key)
- created_at (timestamp)
- expires_at (timestamp, nullable)
- click_count (bigint, default 0)

clicks table:
- id (bigint, primary key)
- url_id (bigint, foreign key)
- ip_address (varchar(45))
- user_agent (text)
- referer (text, nullable)
- clicked_at (timestamp)
```

### 4. Scale the Design (10-15 minutes)

**Goal**: Address scalability challenges and bottlenecks

**Scaling Strategies**:
- Horizontal vs. vertical scaling
- Database sharding
- Caching layers
- CDN implementation
- Load balancing

**Scaling Considerations**:
```
┌─────────────────────────────────────────────────────────────┐
│                    SCALING STRATEGIES                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Read        │    │ Write       │    │ Storage         │  │
│  │ Scaling     │    │ Scaling     │    │ Scaling         │  │
│  │             │    │             │    │                 │  │
│  │ • Read      │    │ • Database  │    │ • Sharding      │  │
│  │   replicas  │    │   sharding  │    │ • Partitioning  │  │
│  │ • Caching   │    │ • Write     │    │ • Archival      │  │
│  │ • CDN       │    │   queues    │    │ • Compression   │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Numbers to Consider**:
- 100M URLs/day = ~1,200 writes/second
- 1B reads/day = ~11,600 reads/second
- Storage: 100M URLs × 500 bytes = 50GB/year
- Cache hit ratio: 80-90%

### 5. Deep Dive & Trade-offs (5-10 minutes)

**Goal**: Discuss specific technical decisions and alternatives

**Common Trade-off Topics**:
- Consistency vs. Availability (CAP theorem)
- Performance vs. Cost
- Simplicity vs. Scalability
- Latency vs. Throughput

**Example Discussion**:
```
Interviewer: "How would you handle the case where two users try to create the same custom short code?"

Candidate: "There are several approaches:
1. Database constraint + retry with random suffix
2. Pre-allocate short codes in batches
3. Use UUIDs instead of custom codes
4. Check availability before assignment

Trade-offs:
- Database approach: Simple but higher latency
- Pre-allocation: Lower latency but more complex
- UUIDs: No conflicts but longer URLs
- Pre-check: Race conditions possible"
```

## Key Diagrams to Draw

### 1. System Architecture Diagram
- High-level components
- Data flow arrows
- External dependencies

### 2. Database Schema
- Tables and relationships
- Indexes
- Partitioning strategy

### 3. API Flow Diagram
- Request/response flow
- Error handling
- Authentication flow

### 4. Scaling Architecture
- Load balancers
- Replication
- Sharding strategy

## Common Pitfalls

### 1. Jumping to Solutions Too Quickly
- **Problem**: Start coding or designing before understanding requirements
- **Solution**: Always clarify requirements first

### 2. Over-Engineering
- **Problem**: Designing for Google-scale from the start
- **Solution**: Start simple, scale gradually

### 3. Ignoring Non-Functional Requirements
- **Problem**: Focus only on features, ignore performance, security
- **Solution**: Always discuss scalability, availability, security

### 4. Poor Communication
- **Problem**: Not explaining your thinking process
- **Solution**: Think out loud, explain trade-offs

### 5. Not Considering Edge Cases
- **Problem**: Only happy path scenarios
- **Solution**: Discuss error handling, failure scenarios

## Practice Checklist

### Before the Interview
- [ ] Practice drawing diagrams quickly
- [ ] Review common system design patterns
- [ ] Prepare examples of trade-offs
- [ ] Practice explaining complex concepts simply

### During the Interview
- [ ] Ask clarifying questions
- [ ] Think out loud
- [ ] Start with simple design
- [ ] Discuss trade-offs
- [ ] Consider edge cases
- [ ] Draw diagrams
- [ ] Be open to feedback

### Common System Design Questions
- [ ] Design a URL shortener
- [ ] Design a chat system
- [ ] Design a social media feed
- [ ] Design a video streaming service
- [ ] Design a search engine
- [ ] Design a distributed cache
- [ ] Design a notification system
- [ ] Design a file storage system

## Evaluation Criteria

### Technical Knowledge (40%)
- Understanding of distributed systems
- Knowledge of databases, caching, load balancing
- Awareness of scalability challenges

### Problem-Solving (30%)
- Ability to break down complex problems
- Logical thinking process
- Consideration of alternatives

### Communication (20%)
- Clear explanation of ideas
- Good use of diagrams
- Active listening and clarification

### System Thinking (10%)
- Understanding of trade-offs
- Consideration of non-functional requirements
- Awareness of real-world constraints

## Conclusion

The system design interview is about demonstrating your ability to think through complex problems systematically. Focus on understanding requirements, designing incrementally, and discussing trade-offs clearly. Practice with real examples and always be prepared to explain your reasoning.

