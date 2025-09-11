# Hands-On System Design Workshop

## Workshop 1: Architecture Decision for E-commerce Platform

### Scenario Brief
**Company**: TechMart (Series B startup)
**Current State**: 100K monthly active users, monolithic PHP application
**Challenge**: Black Friday traffic expected to be 50x normal load
**Timeline**: 3 months to prepare
**Budget**: $50K infrastructure budget
**Team**: 12 developers (3 senior, 6 mid, 3 junior)

### Step 1: Requirements Gathering (30 minutes)

#### Functional Requirements Checklist
- [ ] Product catalog (100K products)
- [ ] User authentication and profiles
- [ ] Shopping cart and checkout
- [ ] Payment processing
- [ ] Order management
- [ ] Inventory tracking
- [ ] Search and recommendations

#### Non-Functional Requirements Analysis
| Requirement | Current | Target | Priority |
|-------------|---------|--------|----------|
| **Concurrent Users** | 1,000 | 50,000 | Critical |
| **Response Time** | 2-5s | <500ms | High |
| **Availability** | 99% | 99.9% | High |
| **Data Consistency** | Eventual | Strong for payments | Critical |

### Step 2: Constraint Analysis (20 minutes)

#### Technical Constraints
- Legacy PHP codebase (200K lines)
- MySQL database (500GB)
- Single data center
- Limited DevOps expertise

#### Business Constraints
- Cannot afford downtime during migration
- Must maintain current feature velocity
- Compliance with PCI DSS required
- International expansion planned (6 months)

### Step 3: Architecture Options Evaluation (45 minutes)

#### Option 1: Optimized Monolith
**Approach**: Scale existing system with performance optimizations

**Pros**:
- Minimal code changes required
- Team familiar with architecture
- Faster implementation
- Lower operational complexity

**Cons**:
- Limited scalability ceiling
- Single point of failure
- Difficult to optimize individual components
- Technology lock-in

**Implementation Plan**:
1. Database optimization (indexing, query tuning)
2. Add Redis caching layer
3. Implement CDN for static assets
4. Horizontal scaling with load balancers
5. Database read replicas

**Estimated Cost**: $15K/month
**Timeline**: 6 weeks
**Risk Level**: Low

#### Option 2: Microservices Migration
**Approach**: Decompose into domain-driven microservices

**Pros**:
- Independent scaling of components
- Technology diversity possible
- Team autonomy
- Better fault isolation

**Cons**:
- High complexity increase
- Network latency between services
- Distributed system challenges
- Longer implementation time

**Implementation Plan**:
1. Extract user service
2. Extract product catalog service
3. Extract payment service
4. Extract order management service
5. Implement API gateway

**Estimated Cost**: $35K/month
**Timeline**: 16 weeks
**Risk Level**: High

#### Option 3: Hybrid Approach
**Approach**: Extract critical services while keeping core monolith

**Pros**:
- Balanced complexity
- Focused optimization
- Gradual migration path
- Risk mitigation

**Cons**:
- Temporary complexity increase
- Data consistency challenges
- Multiple deployment pipelines

**Implementation Plan**:
1. Extract payment service (PCI compliance)
2. Extract search service (performance)
3. Add caching and CDN
4. Optimize remaining monolith
5. Plan future extractions

**Estimated Cost**: $25K/month
**Timeline**: 10 weeks
**Risk Level**: Medium

### Step 4: Decision Matrix Application (30 minutes)

#### Weighted Scoring
| Criteria | Weight | Monolith | Microservices | Hybrid |
|----------|--------|----------|---------------|--------|
| **Time to Market** | 30% | 9 | 3 | 7 |
| **Scalability** | 25% | 4 | 9 | 7 |
| **Team Capability** | 20% | 8 | 4 | 6 |
| **Cost Efficiency** | 15% | 9 | 5 | 7 |
| **Risk Management** | 10% | 7 | 3 | 8 |
| **Weighted Score** | | **7.1** | **5.2** | **6.8** |

#### Risk Assessment
| Architecture | Technical Risk | Business Risk | Mitigation Strategy |
|--------------|----------------|---------------|-------------------|
| **Monolith** | Medium | Low | Performance testing, monitoring |
| **Microservices** | High | High | Proof of concept, phased rollout |
| **Hybrid** | Medium | Medium | Critical service extraction first |

### Step 5: Implementation Deep Dive (60 minutes)

#### Chosen Architecture: Optimized Monolith with Service Extraction

**Phase 1: Immediate Optimizations (Weeks 1-2)**
```yaml
Database Optimization:
  - Add indexes for frequent queries
  - Implement query result caching
  - Set up read replicas for reporting
  - Optimize slow queries (>100ms)

Caching Strategy:
  - Redis for session storage
  - Application-level caching for product data
  - CDN for static assets and images
  - Database query result caching

Infrastructure Scaling:
  - Auto Scaling Groups for web servers
  - Application Load Balancer
  - CloudFront CDN setup
  - RDS Multi-AZ for high availability
```

**Phase 2: Service Extraction (Weeks 3-6)**
```yaml
Payment Service Extraction:
  Technology: Node.js + Express
  Database: Separate RDS instance
  Communication: REST API + SQS for async
  Security: VPC isolation, encryption at rest/transit
  
Search Service Extraction:
  Technology: Elasticsearch + Python
  Data Sync: Change Data Capture from main DB
  Caching: Redis for frequent searches
  Fallback: Main database if service unavailable
```

**Phase 3: Monitoring and Optimization (Weeks 7-8)**
```yaml
Monitoring Setup:
  - CloudWatch for infrastructure metrics
  - Application Performance Monitoring (APM)
  - Custom business metrics dashboard
  - Alerting for critical thresholds

Load Testing:
  - Gradual load increase testing
  - Peak traffic simulation (50x load)
  - Failure scenario testing
  - Performance bottleneck identification
```

### Step 6: Success Metrics and Validation (20 minutes)

#### Key Performance Indicators
| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| **Response Time (P95)** | 3000ms | 500ms | APM tools |
| **Concurrent Users** | 1,000 | 50,000 | Load testing |
| **Error Rate** | 2% | <0.5% | Application logs |
| **Availability** | 99% | 99.9% | Uptime monitoring |
| **Cost per User** | $0.50 | $0.30 | Cost analysis |

#### Validation Plan
1. **Week 4**: Load test with 10x traffic
2. **Week 6**: Load test with 25x traffic  
3. **Week 8**: Full 50x load test
4. **Week 10**: Black Friday simulation
5. **Week 12**: Go-live readiness review

## Workshop 2: Database Architecture Decision

### Scenario: Multi-Tenant SaaS Platform

**Context**: B2B analytics platform serving 1000+ customers
**Data Volume**: 10TB total, 100GB per large customer
**Query Patterns**: Real-time dashboards, batch reports, ad-hoc analytics
**Compliance**: SOC 2, GDPR data residency requirements

### Database Architecture Options

#### Option 1: Single Multi-Tenant Database
```sql
-- Schema Design
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    tier VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE events (
    id UUID PRIMARY KEY,
    customer_id UUID REFERENCES customers(id),
    event_type VARCHAR(100),
    payload JSONB,
    created_at TIMESTAMP
);

-- Partitioning Strategy
CREATE TABLE events_2024_01 PARTITION OF events
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

**Pros**: Simple operations, cost-effective, easy backups
**Cons**: Noisy neighbor issues, limited customization, compliance challenges

#### Option 2: Database per Tenant
```yaml
Architecture:
  - Separate RDS instance per large customer (>1GB data)
  - Shared database for small customers (<100MB data)
  - Connection pooling and routing layer
  - Automated provisioning for new tenants

Cost Model:
  - Large customers: $200-500/month per database
  - Small customers: $5-10/month shared cost
  - Break-even point: 50MB data per customer
```

**Pros**: Perfect isolation, customizable, compliance-friendly
**Cons**: High operational overhead, complex deployments, cost scaling

#### Option 3: Hybrid Sharding Strategy
```yaml
Sharding Rules:
  - Enterprise customers (>10GB): Dedicated shard
  - Business customers (1-10GB): Shared shard (max 10 customers)
  - Starter customers (<1GB): Shared shard (max 100 customers)

Implementation:
  - Shard key: customer_tier + customer_id hash
  - Routing service with connection pooling
  - Cross-shard query aggregation service
  - Automated shard rebalancing
```

**Decision Matrix**:
| Factor | Weight | Single DB | DB per Tenant | Hybrid Sharding |
|--------|--------|-----------|---------------|-----------------|
| **Operational Complexity** | 25% | 9 | 3 | 6 |
| **Performance Isolation** | 25% | 3 | 9 | 7 |
| **Cost Efficiency** | 20% | 9 | 4 | 7 |
| **Compliance** | 15% | 4 | 9 | 7 |
| **Scalability** | 15% | 5 | 8 | 8 |
| **Weighted Score** | | **6.2** | **6.4** | **6.8** |

**Recommendation**: Hybrid sharding with tier-based isolation

## Workshop 3: Performance Optimization Challenge

### Scenario: API Response Time Optimization

**Current State**: E-commerce API with 2-second average response time
**Target**: Reduce to <200ms for 95th percentile
**Constraints**: Cannot change database schema significantly

### Performance Analysis Workshop

#### Step 1: Bottleneck Identification
```bash
# Database Query Analysis
SELECT query, calls, total_time, mean_time, rows
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;

# Application Profiling Results
GET /api/products/search: 1800ms average
├── Database queries: 1200ms (67%)
├── External API calls: 400ms (22%)
├── Business logic: 150ms (8%)
└── Serialization: 50ms (3%)
```

#### Step 2: Optimization Strategy
1. **Database Optimization** (Target: 1200ms → 200ms)
   - Add composite indexes for search queries
   - Implement query result caching (Redis)
   - Optimize N+1 query patterns
   - Use database connection pooling

2. **External API Optimization** (Target: 400ms → 50ms)
   - Implement response caching
   - Add circuit breakers for resilience
   - Use async processing where possible
   - Batch API calls

3. **Application Optimization** (Target: 150ms → 50ms)
   - Optimize serialization (use faster JSON library)
   - Implement object pooling
   - Reduce memory allocations
   - Use more efficient algorithms

#### Step 3: Implementation Plan
```yaml
Week 1: Database Optimization
  - Analyze slow queries with EXPLAIN ANALYZE
  - Add missing indexes
  - Implement Redis caching layer
  - Set up connection pooling

Week 2: Caching Strategy
  - Cache product data (TTL: 1 hour)
  - Cache search results (TTL: 15 minutes)
  - Cache user sessions (TTL: 24 hours)
  - Implement cache warming for popular products

Week 3: External API Optimization
  - Add circuit breakers (Hystrix pattern)
  - Implement response caching
  - Add retry logic with exponential backoff
  - Set up monitoring for external dependencies

Week 4: Load Testing and Validation
  - Baseline performance testing
  - Gradual load increase testing
  - Stress testing to find new bottlenecks
  - Performance regression testing
```

### Expected Results
| Optimization | Before | After | Improvement |
|--------------|--------|-------|-------------|
| **Database Queries** | 1200ms | 200ms | 83% |
| **External APIs** | 400ms | 50ms | 87% |
| **Business Logic** | 150ms | 100ms | 33% |
| **Serialization** | 50ms | 30ms | 40% |
| **Total Response Time** | 1800ms | 380ms | 79% |

## Workshop Deliverables

### Architecture Decision Record (ADR) Template
```markdown
# ADR-001: E-commerce Platform Architecture

## Status
Accepted

## Context
TechMart needs to scale from 1K to 50K concurrent users for Black Friday.
Current monolithic PHP application cannot handle expected load.

## Decision
Implement optimized monolith with selective service extraction.

## Consequences
### Positive
- Faster time to market (8 weeks vs 16 weeks)
- Lower operational complexity
- Team can maintain current velocity
- Cost-effective solution ($25K/month vs $35K/month)

### Negative
- Limited long-term scalability
- Technology diversity constraints
- Future migration complexity

## Implementation Plan
[Detailed implementation steps from workshop]

## Success Metrics
[KPIs and validation criteria from workshop]
```

### Risk Mitigation Plan
| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| **Performance targets not met** | Medium | High | Incremental testing, fallback plan | Tech Lead |
| **Database bottlenecks** | High | Medium | Read replicas, query optimization | DBA |
| **Team capacity constraints** | Medium | Medium | External consultants, training | Engineering Manager |

### Go-Live Checklist
- [ ] Load testing completed (50x traffic)
- [ ] Monitoring and alerting configured
- [ ] Rollback procedures documented and tested
- [ ] Team trained on new architecture
- [ ] Performance baselines established
- [ ] Security review completed
- [ ] Disaster recovery plan updated
