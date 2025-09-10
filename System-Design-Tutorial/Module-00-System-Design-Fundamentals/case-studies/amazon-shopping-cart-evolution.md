# Case Study: Amazon Shopping Cart - Architectural Evolution

## Business Context
Amazon.com started as an online bookstore but evolved into the world's largest e-commerce platform. Throughout this evolution, the shopping cart system has been a critical component that needed to scale from handling thousands to hundreds of millions of concurrent users while maintaining high availability during peak shopping events like Prime Day and Black Friday.

## Technical Challenges

### Challenge 1: Session Management at Scale
- Maintaining user shopping carts across page views and sessions
- Handling millions of concurrent users during peak events
- Ensuring carts persist even when users are not logged in
- Merging guest carts with user accounts upon login

### Challenge 2: High Availability Requirements
- Shopping cart availability directly impacts revenue
- Any downtime during peak events can cost millions per minute
- Geographic distribution of users across global regions
- Need for low latency response times regardless of user location

### Challenge 3: Data Consistency vs. Availability
- Shopping cart data must be available even during network partitions
- Items added to cart must not disappear (customer trust)
- Inventory accuracy needs to be maintained
- System must handle network delays between distributed components

## Solution Architecture Evolution

### Phase 1: Monolithic Database (Early Days)
- Centralized relational database storing cart items
- Session data stored in application servers
- Vertical scaling approach for handling load

### Phase 2: Caching Layer Introduction
- Added in-memory caching for active shopping carts
- Reduced database load for frequent cart retrievals
- Introduced write-through cache updating

### Phase 3: Distributed NoSQL Solution
- Migration to DynamoDB for cart storage
- Key-value structure with user ID as partition key
- Eventually consistent reads with strongly consistent writes
- Optimistic concurrency control for updates

### Phase 4: Multi-Region Active-Active Architecture
- Global table replication across AWS regions
- Local reads for low latency
- Conflict resolution for concurrent modifications
- Cross-region replication for resilience

## Key Technical Decisions

### Decision 1: Choosing Availability over Consistency
- **Decision**: Prioritize availability over strong consistency for shopping cart data
- **Rationale**: Better user experience to always show the cart, even if occasionally stale
- **Implementation**: Eventually consistent reads with conflict resolution
- **Trade-off**: Occasional reconciliation needed for inventory accuracy

### Decision 2: Denormalized Data Model
- **Decision**: Store complete cart item details rather than references
- **Rationale**: Eliminates joins and dependencies on product catalog service
- **Implementation**: Item snapshots with periodic refreshes for price/availability
- **Trade-off**: Increased storage requirements but improved availability

### Decision 3: Write-Around Caching Strategy
- **Decision**: Write directly to persistent store then invalidate cache
- **Rationale**: Ensures data durability while maintaining performance
- **Implementation**: Two-phase commit for critical operations
- **Trade-off**: Slightly higher write latency for improved data safety

## Scaling Journey

### Early Challenges (1995-2000)
- Initial system designed for thousands of concurrent users
- Seasonal traffic spikes caused outages
- Single-region deployment with basic redundancy

### Growth Phase (2001-2010)
- Introduction of service-oriented architecture
- Separation of cart service from monolith
- Implementation of read replicas and sharding

### Hyperscale Era (2011-Present)
- Global distribution across multiple AWS regions
- Multi-master replication with conflict resolution
- Real-time analytics for cart abandonment and recommendations
- Chaos engineering practices for resilience testing

## Lessons Learned

### Lesson 1: CAP Theorem Trade-offs
- In e-commerce, availability typically trumps consistency for shopping cart
- Inventory management requires stronger consistency guarantees
- Hybrid approaches can balance these competing needs

### Lesson 2: Data Model Impact
- Schema design dramatically impacts scalability
- Denormalization improves read performance at scale
- Consider future query patterns when designing data models

### Lesson 3: Incremental Evolution
- Amazon didn't build the final architecture from day one
- Incremental improvements based on actual pain points
- Continuous measurement drove architectural decisions

### Lesson 4: Testing at Scale
- Game Day exercises to simulate peak traffic
- Chaos engineering to verify resilience
- Continuous load testing to identify bottlenecks before they impact customers

## System Design Interview Perspective

### Requirements Clarification
- Is this a multi-region system?
- What is the expected number of concurrent users?
- What are the latency requirements?
- What happens when an item in a cart becomes unavailable?

### Back-of-the-envelope Calculations
- Average cart size: 3-5 items
- Data per cart: ~2KB
- Peak users: 100M concurrent users
- Storage needed: ~200GB (without replication)
- QPS: 500,000 reads, 100,000 writes during peak

### High-level Design Considerations
- Global deployment vs. regional isolation
- Real-time inventory verification vs. eventual consistency
- Session handling for anonymous users
- Cart merging strategies

This case study demonstrates how fundamental system design principles like the CAP theorem directly impact real-world architectural decisions in large-scale systems.
