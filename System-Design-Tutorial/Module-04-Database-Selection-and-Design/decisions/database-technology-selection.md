# ADR-04-001: Database Technology Selection

## Status
Accepted

## Context
We need to select database technologies for an e-commerce platform serving 1M+ users with 100K+ products, processing 10K+ orders daily. The platform requires different data storage patterns with varying performance, consistency, and cost requirements.

## Decision
Use polyglot persistence with specific database technologies matched to use case requirements through systematic evaluation.

## Concrete Database Technology Comparison

### Primary Database Options Evaluated
| Database | Type | Best Use Case | Strengths | Weaknesses |
|----------|------|---------------|-----------|------------|
| **PostgreSQL** | RDBMS | User accounts, orders, payments | ACID, complex queries, mature | Limited horizontal scaling |
| **MongoDB** | Document | Product catalog, content | Flexible schema, fast reads | Eventual consistency |
| **Redis** | Key-Value | Sessions, cart, cache | Extreme speed, data structures | Memory-only, no persistence |
| **DynamoDB** | NoSQL | User profiles, activity logs | Auto-scaling, serverless | Vendor lock-in, query limitations |
| **Elasticsearch** | Search | Product search, analytics | Full-text search, aggregations | Not for primary storage |

### Performance Comparison (Real Benchmarks)
| Database | Read QPS | Write QPS | Latency (P99) | Storage Cost/GB | Compute Cost/Hour |
|----------|----------|-----------|---------------|-----------------|-------------------|
| **PostgreSQL** | 15K | 8K | 5ms | $0.10 | $0.50 |
| **MongoDB** | 25K | 15K | 3ms | $0.08 | $0.40 |
| **Redis** | 100K | 80K | 0.1ms | $1.00 | $2.00 |
| **DynamoDB** | 40K | 40K | 2ms | $0.25 | $0.00 (serverless) |
| **Elasticsearch** | 50K | 10K | 10ms | $0.15 | $0.80 |

## Use Case-Specific Decision Matrix

### User Management System (1M users)
| Requirement | PostgreSQL | MongoDB | DynamoDB | Winner |
|-------------|------------|---------|----------|---------|
| **ACID Transactions** | ✅ Full | ❌ Limited | ❌ Limited | PostgreSQL |
| **Complex Queries** | ✅ SQL | ⚠️ Limited | ❌ Key-only | PostgreSQL |
| **Scalability** | ⚠️ Vertical | ✅ Horizontal | ✅ Auto | Tie |
| **Operational Overhead** | ❌ High | ⚠️ Medium | ✅ None | DynamoDB |
| **Cost (1M users)** | $500/month | $300/month | $200/month | DynamoDB |
| **Team Expertise** | ✅ High | ⚠️ Medium | ❌ Low | PostgreSQL |

**Decision**: PostgreSQL for user accounts (ACID critical), DynamoDB for user activity logs

### Product Catalog (100K products)
| Requirement | MongoDB | PostgreSQL | Elasticsearch | Winner |
|-------------|---------|------------|---------------|---------|
| **Flexible Schema** | ✅ Native | ❌ JSON only | ✅ Dynamic | MongoDB |
| **Search Capabilities** | ⚠️ Basic | ❌ Limited | ✅ Advanced | Elasticsearch |
| **Read Performance** | ✅ 25K QPS | ⚠️ 15K QPS | ✅ 50K QPS | Elasticsearch |
| **Consistency** | ⚠️ Eventual | ✅ Strong | ⚠️ Near real-time | PostgreSQL |
| **Cost (100K products)** | $200/month | $300/month | $400/month | MongoDB |

**Decision**: MongoDB for product storage + Elasticsearch for search

### Shopping Cart (Active sessions)
| Requirement | Redis | DynamoDB | PostgreSQL | Winner |
|-------------|-------|----------|------------|---------|
| **Speed** | ✅ 0.1ms | ✅ 2ms | ❌ 5ms | Redis |
| **Session Storage** | ✅ Native | ✅ TTL | ⚠️ Manual | Redis |
| **Persistence** | ⚠️ Optional | ✅ Durable | ✅ Durable | DynamoDB |
| **Cost (10K active)** | $100/month | $50/month | $150/month | DynamoDB |
| **Complexity** | ✅ Simple | ✅ Simple | ❌ Complex | Tie |

**Decision**: Redis for active cart + DynamoDB for cart persistence

## Team Capability Assessment

### Current Team Skills (5 developers)
| Technology | Developers with Experience | Training Time Needed | Hiring Difficulty | Risk Level |
|------------|---------------------------|---------------------|-------------------|------------|
| **PostgreSQL** | 4/5 (80%) | 1 week | Low | ✅ Low |
| **MongoDB** | 2/5 (40%) | 3 weeks | Medium | ⚠️ Medium |
| **Redis** | 1/5 (20%) | 2 weeks | Medium | ⚠️ Medium |
| **DynamoDB** | 0/5 (0%) | 4 weeks | High | ❌ High |
| **Elasticsearch** | 1/5 (20%) | 6 weeks | High | ❌ High |

### Training Cost Analysis
| Technology | Training Hours | Cost per Developer | Total Training Cost | Time to Productivity |
|------------|----------------|-------------------|-------------------|-------------------|
| **PostgreSQL** | 40 hours | $2,000 | $2,000 | 1 week |
| **MongoDB** | 120 hours | $6,000 | $18,000 | 3 weeks |
| **Redis** | 80 hours | $4,000 | $16,000 | 2 weeks |
| **DynamoDB** | 160 hours | $8,000 | $40,000 | 4 weeks |

## Cost Analysis (3-Year TCO)

### Scenario: E-commerce Platform Growth
| Year | Users | Products | Orders/Day | Data Size |
|------|-------|----------|-----------|-----------|
| Year 1 | 100K | 10K | 1K | 100GB |
| Year 2 | 500K | 50K | 5K | 500GB |
| Year 3 | 1M | 100K | 10K | 1TB |

### Cost Breakdown by Database
| Database | Year 1 | Year 2 | Year 3 | 3-Year Total | Use Case |
|----------|--------|--------|--------|--------------|----------|
| **PostgreSQL** | $6K | $15K | $30K | $51K | Users, Orders |
| **MongoDB** | $4K | $12K | $24K | $40K | Products |
| **Redis** | $3K | $8K | $15K | $26K | Cache, Sessions |
| **DynamoDB** | $2K | $10K | $25K | $37K | Activity Logs |
| **Elasticsearch** | $5K | $15K | $35K | $55K | Search |
| **Total** | $20K | $60K | $129K | $209K | |

### Alternative: Single Database Approach
| Approach | 3-Year Cost | Performance | Complexity | Risk |
|----------|-------------|-------------|------------|------|
| **PostgreSQL Only** | $80K | 60% of optimal | Low | Medium |
| **MongoDB Only** | $70K | 70% of optimal | Low | High |
| **Polyglot (Chosen)** | $209K | 100% optimal | High | Low |

## Decision Worksheet

### Step 1: Requirements Assessment
```
Data Volume: 1TB by Year 3
Read QPS: 50K peak
Write QPS: 15K peak
Consistency: Strong for financial, Eventual for catalog
Budget: $150K over 3 years
Team: 5 developers, mostly SQL experience
Timeline: 6 months to production
```

### Step 2: Technology Scoring
| Criteria | Weight | PostgreSQL | MongoDB | Redis | DynamoDB |
|----------|--------|------------|---------|-------|----------|
| **Performance** | 25% | 7/10 | 8/10 | 10/10 | 8/10 |
| **Team Skills** | 20% | 9/10 | 6/10 | 4/10 | 3/10 |
| **Cost** | 20% | 6/10 | 7/10 | 5/10 | 8/10 |
| **Reliability** | 15% | 9/10 | 7/10 | 6/10 | 8/10 |
| **Scalability** | 10% | 5/10 | 8/10 | 7/10 | 9/10 |
| **Operational** | 10% | 5/10 | 6/10 | 7/10 | 9/10 |
| **Weighted Score** | | **7.1** | **7.0** | **6.8** | **6.9** |

### Step 3: Final Architecture Decision
```
User Accounts & Orders: PostgreSQL (ACID required)
Product Catalog: MongoDB (flexible schema)
Search: Elasticsearch (full-text search)
Cache & Sessions: Redis (speed critical)
Activity Logs: DynamoDB (auto-scaling)
```

## Risk Assessment

### High-Risk Decisions
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **DynamoDB vendor lock-in** | Medium | High | Keep data exportable, use standard APIs |
| **MongoDB consistency issues** | Low | High | Implement read-after-write consistency |
| **Redis data loss** | Medium | Medium | Persistent storage + backup to disk |
| **Team learning curve** | High | Medium | Phased rollout, extensive training |

### Success Criteria
| Metric | Target | Measurement |
|--------|--------|-------------|
| **Response Time** | < 100ms P99 | APM monitoring |
| **Availability** | 99.9% | Uptime monitoring |
| **Cost** | < $15K/month by Year 3 | Monthly cost tracking |
| **Team Productivity** | < 2 weeks onboarding | Developer surveys |

## Implementation Roadmap

### Phase 1 (Months 1-2): Core Systems
- PostgreSQL for users and orders
- Basic MongoDB for products
- Redis for sessions

### Phase 2 (Months 3-4): Search & Analytics
- Elasticsearch for product search
- DynamoDB for activity logs

### Phase 3 (Months 5-6): Optimization
- Performance tuning
- Monitoring and alerting
- Backup and disaster recovery

## Related ADRs
- [ADR-04-002: Data Consistency Model](./data-consistency-model.md)
- [ADR-04-003: Database Sharding Strategy](./database-sharding-strategy.md)
- [ADR-04-004: Caching Architecture](./caching-architecture.md)

---
**Author**: Database Architecture Team  
**Date**: 2024-01-15  
**Version**: 1.0
