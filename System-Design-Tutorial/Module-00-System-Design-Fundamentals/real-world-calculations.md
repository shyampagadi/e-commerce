# Real-World System Design Calculations

## Capacity Planning Calculator Framework

### Use Case 1: Social Media Platform (Instagram-like)
```yaml
Business Requirements:
  Users: 1 billion registered, 500M daily active
  Posts: 100M photos/day, 10M videos/day
  Engagement: 50 likes/post, 5 comments/post
  Storage: 7-year retention policy

Traffic Calculations:
  Peak Hour Traffic: 20% of daily activity in 4-hour window
  Photo Uploads: 100M ÷ 24 × 5 = 20.8M photos/hour peak
  QPS Breakdown:
    - Photo uploads: 20.8M ÷ 3600 = 5,778 QPS
    - Metadata writes: 5,778 × 3 (tags, location, etc.) = 17,334 QPS
    - Feed reads: 500M users × 50 refreshes/day ÷ 86,400 = 289,352 QPS
    - Like/comment writes: 100M posts × 55 interactions ÷ 86,400 = 63,657 QPS

Storage Calculations:
  Photo Storage:
    - Original: 100M × 2MB × 365 days = 73PB/year
    - Thumbnails: 100M × 50KB × 4 sizes × 365 = 7.3PB/year
    - Total photos: 80.3PB/year
  
  Video Storage:
    - Original: 10M × 50MB × 365 = 182.5PB/year
    - Transcoded: 10M × 20MB × 5 formats × 365 = 365PB/year
    - Total videos: 547.5PB/year
  
  Metadata Storage:
    - Posts: 110M × 2KB × 365 = 80GB/year
    - Users: 1B × 5KB = 5TB
    - Relationships: 1B × 150 friends × 100B = 15TB
    - Total metadata: 20TB/year

Infrastructure Sizing:
  CDN Requirements:
    - Global bandwidth: 500M users × 100MB/day = 50PB/day
    - Peak bandwidth: 50PB ÷ 86,400 × 5 = 2.9TB/second
    - Edge locations: 300+ for <100ms global latency
  
  Database Sharding:
    - User data: Shard by user_id % 1000 = 1000 shards
    - Posts: Shard by (user_id + timestamp) % 5000 = 5000 shards
    - Each shard: ~1M users, 100K posts/day
  
  Compute Requirements:
    - API servers: 289K QPS ÷ 1K QPS/server = 289 servers
    - Image processing: 5,778 uploads/sec × 5 formats = 28,890 CPU cores
    - ML recommendation: 500M users × 1ms CPU = 500 CPU cores continuous

Cost Analysis (Monthly):
  Storage Costs:
    - S3 Standard (hot data): 10PB × $23/TB = $230,000
    - S3 IA (warm data): 50PB × $12.5/TB = $625,000
    - S3 Glacier (cold data): 500PB × $4/TB = $2,000,000
    - Total storage: $2,855,000/month
  
  Compute Costs:
    - EC2 instances: 289 × c5.2xlarge × $0.34/hour × 730 = $243,000
    - Lambda (image processing): 100M × $0.0000002 = $20,000
    - Total compute: $263,000/month
  
  Network Costs:
    - CloudFront: 50PB × $0.085/GB = $4,250,000
    - Data transfer: 10PB × $0.09/GB = $900,000
    - Total network: $5,150,000/month
  
  Total Monthly Cost: $8,268,000 (~$100M annually)
```

### Use Case 2: Financial Trading Platform (Robinhood-like)
```yaml
Business Requirements:
  Users: 20M registered, 2M daily active traders
  Trades: 1M trades/day, 100M market data updates/second
  Latency: <10ms order execution, <1ms market data
  Compliance: 7-year audit trail, real-time risk monitoring

Traffic Calculations:
  Market Hours: 6.5 hours × 250 trading days = 1,625 hours/year
  Peak Trading: First/last 30 minutes = 2x normal volume
  
  Order Flow:
    - Market orders: 1M trades ÷ 6.5 hours = 154K trades/hour
    - Peak: 154K × 2 = 308K trades/hour = 85 trades/second
    - Limit orders: 85 × 10 (order-to-trade ratio) = 850 orders/second
    - Cancellations: 850 × 0.7 = 595 cancellations/second
    - Total order QPS: 85 + 850 + 595 = 1,530 QPS
  
  Market Data:
    - Price updates: 8,000 symbols × 10 updates/second = 80K QPS
    - Level 2 data: 8,000 × 20 levels × 5 updates/second = 800K QPS
    - Options chain: 50K contracts × 2 updates/second = 100K QPS
    - Total market data: 980K QPS

Latency Budget Analysis:
  Order Execution (10ms total):
    - Network ingress: 1ms (10%)
    - Load balancer: 0.5ms (5%)
    - Authentication: 0.5ms (5%)
    - Risk checks: 2ms (20%)
    - Order matching: 3ms (30%)
    - Trade confirmation: 2ms (20%)
    - Network egress: 1ms (10%)
  
  Market Data (1ms total):
    - Exchange feed: 0.2ms (20%)
    - Processing: 0.3ms (30%)
    - Distribution: 0.3ms (30%)
    - Client delivery: 0.2ms (20%)

Infrastructure Requirements:
  Ultra-Low Latency Setup:
    - Colocation: Exchange data centers (NYSE, NASDAQ)
    - Network: 10Gbps dedicated lines, <0.5ms latency
    - Hardware: FPGA for order matching, NVMe SSDs
    - Memory: 1TB RAM per matching engine
  
  Database Architecture:
    - Order book: In-memory (Redis Cluster) - 100GB
    - Trade history: TimescaleDB - 10TB/year
    - User data: PostgreSQL (Multi-AZ) - 1TB
    - Market data: ClickHouse - 100TB/year
  
  Compute Sizing:
    - Matching engines: 10 × r5.metal (bare metal for latency)
    - API servers: 50 × c5n.2xlarge (enhanced networking)
    - Risk engines: 20 × m5.xlarge
    - Market data: 30 × c5n.xlarge

Cost Analysis (Monthly):
  Infrastructure Costs:
    - Colocation fees: $50,000 (exchange proximity)
    - Bare metal servers: 10 × $500 = $5,000
    - EC2 instances: 100 × $200 = $20,000
    - Dedicated network: $25,000
    - Total infrastructure: $100,000/month
  
  Data Costs:
    - Market data feeds: $500,000 (exchange fees)
    - Storage: 10TB × $100/TB = $1,000
    - Backup/compliance: $5,000
    - Total data: $506,000/month
  
  Compliance Costs:
    - Audit logging: $10,000
    - Regulatory reporting: $15,000
    - Security monitoring: $20,000
    - Total compliance: $45,000/month
  
  Total Monthly Cost: $651,000 (~$7.8M annually)
```

### Use Case 3: Video Streaming Platform (Netflix-like)
```yaml
Business Requirements:
  Subscribers: 200M global, 100M concurrent peak
  Content: 15,000 titles, 4 hours average viewing/day
  Quality: 4K/HDR support, adaptive bitrate streaming
  Global: 190+ countries, <100ms startup latency

Traffic Calculations:
  Peak Viewing Hours: 8-11 PM local time globally
  Concurrent Streams: 100M peak concurrent viewers
  
  Bandwidth Requirements:
    - 4K streams: 25 Mbps × 10M users = 250 Tbps
    - 1080p streams: 5 Mbps × 60M users = 300 Tbps  
    - 720p streams: 3 Mbps × 30M users = 90 Tbps
    - Total peak bandwidth: 640 Tbps globally
  
  Content Delivery:
    - Cache hit ratio: 95% (popular content)
    - Origin bandwidth: 640 Tbps × 5% = 32 Tbps
    - Edge bandwidth: 640 Tbps × 95% = 608 Tbps

Storage Calculations:
  Content Library:
    - Original masters: 15K titles × 100GB = 1.5PB
    - Encoded versions: 1.5PB × 10 formats = 15PB
    - Thumbnails/metadata: 15K × 50MB = 750GB
    - Total content: 16.5PB
  
  Global Distribution:
    - Tier 1 regions (US, EU): Full catalog = 16.5PB × 3 = 49.5PB
    - Tier 2 regions (Asia, LATAM): 80% catalog = 13.2PB × 5 = 66PB
    - Tier 3 regions (Others): 50% catalog = 8.25PB × 10 = 82.5PB
    - Total global storage: 198PB

CDN Architecture:
  Edge Locations:
    - Tier 1: 50 locations × 2PB each = 100PB
    - Tier 2: 150 locations × 500TB each = 75PB
    - Tier 3: 300 locations × 100TB each = 30PB
    - ISP caches: 1,000 locations × 50TB each = 50PB
    - Total edge storage: 255PB
  
  Performance Optimization:
    - Predictive caching: ML models predict popular content
    - Pre-positioning: Move content before demand spikes
    - Adaptive bitrate: Real-time quality adjustment
    - P2P assistance: Reduce CDN load by 20%

Infrastructure Sizing:
  Encoding Pipeline:
    - New content: 100 hours/day × 10 formats = 1,000 encoding hours/day
    - Re-encoding: 500 hours/day (quality improvements)
    - Total: 1,500 encoding hours/day = 62.5 concurrent jobs
    - Compute: 62.5 × c5.9xlarge = 2,250 vCPUs continuous
  
  Recommendation Engine:
    - User profiles: 200M × 10KB = 2TB
    - Viewing history: 200M × 1MB = 200TB
    - ML training: 1,000 × p3.8xlarge hours/day
    - Inference: 200M users × 100ms = 20,000 CPU cores

Cost Analysis (Monthly):
  Content Costs:
    - Content licensing: $1,000,000,000 (largest cost)
    - Original production: $500,000,000
    - Total content: $1,500,000,000/month
  
  Infrastructure Costs:
    - CDN bandwidth: 640 Tbps × $0.02/GB = $16,000,000
    - Storage: 255PB × $20/TB = $5,100,000
    - Compute: 10,000 instances × $200 = $2,000,000
    - Total infrastructure: $23,100,000/month
  
  Technology Costs:
    - Encoding: $500,000
    - ML/recommendations: $300,000
    - Monitoring/analytics: $200,000
    - Total technology: $1,000,000/month
  
  Total Monthly Cost: $1,524,100,000 (~$18.3B annually)
```

## REST API Design Calculator

### API Architecture Decision Matrix
```yaml
Traffic-Based API Architecture:

Startup Scale (1K-10K users):
  Concurrent Users: 100-1,000
  API Calls/User/Day: 50-200
  Peak QPS: 5-50
  
  Architecture Pattern:
    - API Gateway + Lambda (serverless)
    - DynamoDB (managed NoSQL)
    - CloudFront (global CDN)
  
  Cost Calculation:
    - API Gateway: 50 QPS × 86,400 × 30 × $3.50/1M = $453
    - Lambda: 50 × 200ms × 1GB × $0.0000166667 = $166
    - DynamoDB: 1M requests × $1.25/1M = $1.25
    - Total: ~$620/month

Growth Scale (10K-100K users):
  Concurrent Users: 1,000-10,000
  API Calls/User/Day: 100-500  
  Peak QPS: 50-500
  
  Architecture Pattern:
    - ALB + ECS Fargate (containers)
    - Aurora Serverless (auto-scaling DB)
    - ElastiCache (Redis caching)
  
  Cost Calculation:
    - ALB: $16 + (500 QPS × 0.008 × 730) = $2,936
    - ECS Fargate: 10 tasks × 2 vCPU × $0.04048 × 730 = $5,915
    - Aurora: 2 ACU × $0.06 × 730 = $87.6
    - ElastiCache: cache.r6g.large × $0.126 × 730 = $92
    - Total: ~$9,030/month

Enterprise Scale (100K+ users):
  Concurrent Users: 10,000+
  API Calls/User/Day: 200-1,000
  Peak QPS: 500-5,000+
  
  Architecture Pattern:
    - Multi-region deployment
    - Microservices (EKS)
    - Database sharding
    - Advanced caching (multi-tier)
  
  Cost Calculation:
    - EKS clusters: 3 regions × $72 = $216
    - EC2 nodes: 50 × m5.2xlarge × $0.384 × 730 = $140,160
    - RDS clusters: 6 × db.r5.2xlarge × $0.48 × 730 = $210,240
    - ElastiCache: 10 × cache.r6g.2xlarge × $0.504 × 730 = $36,792
    - Total: ~$387,408/month
```

### Performance Budget Calculator
```yaml
Latency Budget Breakdown (200ms target):

Mobile App API:
  Network (mobile): 50ms (25%)
  CDN/Edge: 20ms (10%)
  Load balancer: 10ms (5%)
  Authentication: 15ms (7.5%)
  Business logic: 60ms (30%)
  Database query: 35ms (17.5%)
  Response serialization: 10ms (5%)
  Total: 200ms (100%)

Web Application API:
  Network (broadband): 20ms (10%)
  CDN/Edge: 15ms (7.5%)
  Load balancer: 5ms (2.5%)
  Authentication: 10ms (5%)
  Business logic: 80ms (40%)
  Database query: 50ms (25%)
  Response serialization: 20ms (10%)
  Total: 200ms (100%)

Optimization Priority Matrix:
  High Impact (>20ms savings):
    1. Database optimization (indexes, query tuning)
    2. Caching implementation (Redis, application-level)
    3. Business logic optimization (algorithm improvements)
  
  Medium Impact (10-20ms savings):
    4. CDN configuration (edge caching, compression)
    5. Serialization optimization (protobuf vs JSON)
    6. Connection pooling (database, HTTP)
  
  Low Impact (<10ms savings):
    7. Load balancer tuning
    8. Network optimization
    9. Authentication caching
```

## Database Sizing Calculator

### Multi-Tenant SaaS Platform
```yaml
Business Model:
  Customers: 10,000 businesses
  Users per customer: 50 average (500K total users)
  Data per user: 100MB average
  Growth rate: 50% annually

Tenant Distribution:
  Enterprise (100 customers): 500 users each = 50,000 users
  Business (900 customers): 100 users each = 90,000 users  
  Startup (9,000 customers): 40 users each = 360,000 users

Database Sharding Strategy:
  Shard 1 (Enterprise): Dedicated databases
    - 100 × PostgreSQL db.r5.xlarge = $36,500/month
    - Storage: 100 × 50GB × $0.115 = $575/month
  
  Shard 2-4 (Business): Shared databases  
    - 3 × PostgreSQL db.r5.2xlarge = $10,512/month
    - Storage: 900 × 10GB × $0.115 = $1,035/month
  
  Shard 5-10 (Startup): Highly shared
    - 6 × PostgreSQL db.r5.large = $6,307/month  
    - Storage: 9,000 × 4GB × $0.115 = $4,140/month
  
  Total Database Cost: $58,069/month

Query Load Analysis:
  Enterprise customers: 1,000 QPS each × 100 = 100,000 QPS
  Business customers: 100 QPS each × 900 = 90,000 QPS
  Startup customers: 10 QPS each × 9,000 = 90,000 QPS
  Total: 280,000 QPS

Read Replica Strategy:
  Enterprise: 3 read replicas each = 300 replicas
  Business: 2 read replicas per shard = 6 replicas
  Startup: 1 read replica per shard = 6 replicas
  Total replicas: 312 × $182/month = $56,784/month

Caching Strategy:
  Application cache: ElastiCache Redis
    - Enterprise: 100 × cache.r6g.large = $9,198/month
    - Business: 3 × cache.r6g.xlarge = $2,764/month
    - Startup: 6 × cache.r6g.medium = $1,382/month
  Total caching: $13,344/month

Total Database Infrastructure: $128,197/month
```

## Performance Optimization Framework

### Real-World Optimization Case Studies
```yaml
Case Study 1: E-commerce Search Optimization
  Problem: Product search taking 2-5 seconds
  Traffic: 10,000 searches/minute peak
  
  Before Optimization:
    - Database: Full-text search on PostgreSQL
    - Query time: 2,000-5,000ms
    - CPU usage: 90% during peak
    - User abandonment: 40% after 3 seconds
  
  Optimization Steps:
    1. Implement Elasticsearch cluster
       - 3 × r5.xlarge nodes = $1,051/month
       - Index size: 50GB (product catalog)
       - Query time: 50-100ms
    
    2. Add Redis caching layer
       - cache.r6g.large = $92/month  
       - Cache popular searches (80% hit rate)
       - Cached query time: 5-10ms
    
    3. Implement search suggestions
       - Pre-computed suggestions in DynamoDB
       - Autocomplete response: <50ms
       - Reduced search abandonment by 60%
  
  Results:
    - Average search time: 75ms (96% improvement)
    - Peak CPU usage: 45% (50% reduction)
    - Search conversion: +35%
    - Additional cost: $1,143/month
    - Revenue impact: +$50,000/month

Case Study 2: Social Media Feed Generation
  Problem: Timeline generation taking 3-8 seconds
  Scale: 50M users, 500M posts/day
  
  Before Optimization:
    - Pull model: Generate feed on request
    - Database queries: 50-200 per feed
    - Response time: 3,000-8,000ms
    - Database load: 95% CPU utilization
  
  Optimization Strategy:
    1. Hybrid push-pull model
       - Pre-compute feeds for active users (10M)
       - Pull model for inactive users (40M)
       - Redis storage: 10M × 1MB = 10TB
       - Cost: 40 × cache.r6g.2xlarge = $20,160/month
    
    2. Feed materialization pipeline
       - Kafka for real-time updates: $5,000/month
       - Lambda for feed updates: $2,000/month
       - DynamoDB for feed storage: $8,000/month
    
    3. Intelligent caching
       - Popular content cache (95% hit rate)
       - User preference cache (90% hit rate)
       - Geographic content cache (85% hit rate)
  
  Results:
    - Feed generation time: 200ms (95% improvement)
    - Database CPU: 30% (70% reduction)
    - User engagement: +25%
    - Infrastructure cost: +$35,160/month
    - Ad revenue impact: +$500,000/month
```
