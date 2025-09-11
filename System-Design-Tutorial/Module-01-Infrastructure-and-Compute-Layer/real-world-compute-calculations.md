# Real-World Compute Architecture Calculations

## Compute Sizing Calculator Framework

### Use Case 1: Gaming Platform (Fortnite-like)
```yaml
Business Requirements:
  Concurrent Players: 350M registered, 10M peak concurrent
  Game Sessions: 30 minutes average, 100M sessions/day
  Match Making: <5 seconds globally
  Game State: 60 FPS, 100 players/match, real-time sync

Traffic Analysis:
  Peak Gaming Hours: 6-10 PM across time zones (16 hours global peak)
  Match Creation Rate: 10M players ÷ 100 players = 100K matches/hour
  Game State Updates: 100K matches × 100 players × 60 FPS = 600M updates/second
  
  Compute Requirements per Match:
    - Game server: 1 vCPU, 2GB RAM
    - Physics simulation: 0.5 vCPU continuous
    - Anti-cheat processing: 0.2 vCPU
    - Total per match: 1.7 vCPU, 2GB RAM

Infrastructure Sizing:
  Game Servers:
    - Active matches: 100K concurrent
    - Compute needed: 100K × 1.7 vCPU = 170K vCPUs
    - Instance type: c5.2xlarge (8 vCPU) = 21,250 instances
    - Geographic distribution:
      * North America: 8,500 instances (40%)
      * Europe: 6,375 instances (30%)  
      * Asia Pacific: 4,250 instances (20%)
      * Other regions: 2,125 instances (10%)
  
  Matchmaking Service:
    - Player queue processing: 10M players ÷ 5 seconds = 2M QPS
    - Skill rating calculations: Complex algorithms
    - Compute: 500 × c5.xlarge instances = 2,000 vCPUs
    - Database: DynamoDB (player profiles, match history)
  
  Content Delivery:
    - Game client: 15GB download × 1M downloads/day = 15PB/day
    - Updates: 500MB × 350M players × 4 updates/month = 700PB/month
    - CDN bandwidth: 15PB ÷ 86,400 seconds = 174GB/second sustained

Cost Analysis (Monthly):
  Game Server Compute:
    - Spot instances (90% savings): 21,250 × $0.034 × 730 = $527,075
    - On-demand (peak hours): 2,125 × $0.34 × 200 = $144,500
    - Total compute: $671,575/month
  
  Matchmaking Infrastructure:
    - EC2 instances: 500 × c5.xlarge × $0.17 × 730 = $62,050
    - DynamoDB: 2M QPS × $1.25/1M = $2.50
    - Total matchmaking: $62,052/month
  
  Content Delivery:
    - CloudFront: 700PB × $0.085/GB = $59,500,000
    - Origin storage: 15GB × $0.023/GB = $0.35
    - Total CDN: $59,500,000/month
  
  Total Monthly Cost: $60,233,627 (~$723M annually)

Performance Optimization:
  Latency Requirements:
    - Player input to server: <50ms
    - Server processing: <16ms (60 FPS)
    - Server to all players: <50ms
    - Total round-trip: <116ms
  
  Geographic Optimization:
    - Edge game servers in 50+ locations
    - Player routing to nearest server (<30ms)
    - Predictive server scaling based on player patterns
    - Cross-region failover in <10 seconds
```

### Use Case 2: Ride-Sharing Platform (Uber-like)
```yaml
Business Requirements:
  Active Users: 100M riders, 5M drivers globally
  Peak Rides: 15M rides/day, 2M concurrent rides
  Real-time Tracking: GPS updates every 5 seconds
  ETA Calculations: <3 seconds response time

Traffic Calculations:
  Location Updates:
    - Active drivers: 2M × GPS update/5 seconds = 400K QPS
    - Active riders: 2M × GPS update/10 seconds = 200K QPS
    - Total location QPS: 600K QPS
  
  Ride Requests:
    - Ride requests: 15M ÷ 86,400 = 174 requests/second
    - Driver matching: 174 × 10 candidates = 1,740 matches/second
    - Route calculations: 174 × 3 routes = 522 calculations/second
    - Price estimates: 174 × 5 options = 870 calculations/second
  
  Map and Routing:
    - ETA calculations: 600K active users × 1 ETA/minute = 10K QPS
    - Route optimization: 2M active rides × 1 route/5 minutes = 6.7K QPS
    - Traffic data processing: Real-time traffic from 50M road segments

Compute Architecture:
  Microservices Breakdown:
    1. Location Service:
       - Handle 600K GPS QPS
       - Geospatial indexing and queries
       - Compute: 200 × c5.2xlarge = 1,600 vCPUs
       - Database: DynamoDB with geospatial indexing
    
    2. Matching Service:
       - Driver-rider matching algorithm
       - Supply-demand optimization
       - Compute: 50 × c5.4xlarge = 800 vCPUs
       - Cache: Redis cluster for active drivers/riders
    
    3. Routing Service:
       - Real-time route calculation
       - Traffic-aware ETA prediction
       - Compute: 100 × c5.xlarge = 400 vCPUs
       - External APIs: Google Maps, traffic data
    
    4. Pricing Service:
       - Dynamic pricing algorithms
       - Surge pricing calculations
       - Compute: 30 × c5.large = 60 vCPUs
       - ML models for demand prediction

Geographic Distribution:
  Regional Deployment:
    - North America: 150 cities, 40% of traffic
    - Europe: 100 cities, 25% of traffic
    - Asia Pacific: 200 cities, 30% of traffic
    - Latin America: 50 cities, 5% of traffic
  
  Edge Computing:
    - Location processing at edge (reduce latency)
    - 500 edge locations globally
    - Each edge: 4 × c5.large instances
    - Total edge compute: 2,000 instances

Cost Analysis (Monthly):
  Core Services:
    - Location service: 200 × c5.2xlarge × $0.34 × 730 = $49,640
    - Matching service: 50 × c5.4xlarge × $0.68 × 730 = $24,820
    - Routing service: 100 × c5.xlarge × $0.17 × 730 = $12,410
    - Pricing service: 30 × c5.large × $0.085 × 730 = $1,863
    - Total core: $88,733/month
  
  Edge Computing:
    - Edge instances: 2,000 × c5.large × $0.085 × 730 = $124,100
    - Data transfer: 600K QPS × 1KB × 86,400 × 30 × $0.09/GB = $140,400
    - Total edge: $264,500/month
  
  Database and Storage:
    - DynamoDB: 600K QPS × $1.25/1M = $750
    - ElastiCache: 50 × cache.r6g.xlarge × $0.252 × 730 = $9,198
    - S3 storage: 100TB × $0.023 = $2,300
    - Total data: $12,248/month
  
  External Services:
    - Maps API: 10K QPS × $0.005 × 86,400 × 30 = $129,600
    - Traffic data: $50,000
    - Total external: $179,600/month
  
  Total Monthly Cost: $545,081 (~$6.5M annually)

Machine Learning Pipeline:
  Demand Prediction:
    - Historical data: 2 years × 15M rides/day = 11B data points
    - Features: Time, weather, events, holidays (100 features)
    - Training: Daily model updates
    - Compute: 10 × p3.2xlarge × 2 hours/day = $32/day
  
  ETA Prediction:
    - Real-time traffic ML model
    - 50M road segments × traffic patterns
    - Training: Hourly updates
    - Compute: 20 × p3.xlarge × 24 hours = $115/day
  
  Driver Matching Optimization:
    - Multi-objective optimization (time, cost, driver utilization)
    - Reinforcement learning model
    - Training: Continuous online learning
    - Compute: 5 × p3.8xlarge × 24 hours = $97/day
  
  Total ML Cost: $244/day = $7,320/month
```

### Use Case 3: Video Conferencing Platform (Zoom-like)
```yaml
Business Requirements:
  Users: 300M registered, 30M daily active
  Concurrent Meetings: 500K peak, 2M participants
  Video Quality: 1080p HD, 30 FPS
  Global Latency: <150ms for 99% of users

Real-time Media Processing:
  Video Streams:
    - Concurrent participants: 2M
    - Video bitrate: 2 Mbps per stream (1080p)
    - Total ingress: 2M × 2 Mbps = 4 Tbps
    - Transcoding: Multiple qualities (360p, 720p, 1080p)
    - Total egress: 4 Tbps × 3 qualities = 12 Tbps
  
  Audio Processing:
    - Audio bitrate: 64 Kbps per stream
    - Noise cancellation: AI-powered, real-time
    - Echo cancellation: DSP algorithms
    - Audio mixing: Up to 1,000 participants per meeting

Media Server Architecture:
  Regional Media Servers:
    - 17 regions globally for <150ms latency
    - Each region: 50-500 media servers based on demand
    - Total servers: 2,000 × c5n.2xlarge instances
    - CPU allocation: 80% for transcoding, 20% for routing
  
  Compute Requirements per Server:
    - Video transcoding: 6 vCPUs (hardware acceleration)
    - Audio processing: 1 vCPU
    - Network I/O: 1 vCPU
    - Total: 8 vCPUs per server = c5n.2xlarge
  
  Capacity Planning:
    - Peak capacity: 2M participants ÷ 100 participants/server = 20K servers
    - Normal capacity: 500K participants ÷ 100 = 5K servers
    - Auto-scaling: Scale from 5K to 20K in 5 minutes
    - Spot instances: 70% of capacity (cost optimization)

Network Infrastructure:
  Bandwidth Requirements:
    - Ingress: 4 Tbps (participant uploads)
    - Egress: 12 Tbps (multi-quality distribution)
    - Inter-region: 2 Tbps (global routing)
    - Total: 18 Tbps peak bandwidth
  
  CDN Strategy:
    - Media relay servers in 500+ locations
    - Adaptive bitrate based on network conditions
    - P2P assistance for large meetings (>100 participants)
    - WebRTC optimization for browser clients

Cost Analysis (Monthly):
  Media Server Compute:
    - Base capacity: 5K × c5n.2xlarge × $0.432 × 730 = $1,576,800
    - Peak scaling: 15K × c5n.2xlarge × $0.043 × 200 hours = $2,795,400
    - Total compute: $4,372,200/month
  
  Network Costs:
    - Data transfer: 18 Tbps × 86,400 × 30 × $0.09/GB = $4,199,040
    - CDN (CloudFront): 12 Tbps × 86,400 × 30 × $0.085/GB = $2,654,208
    - Total network: $6,853,248/month
  
  Storage and Database:
    - Meeting recordings: 100K hours/day × 1GB/hour × $0.023 = $69
    - User data: PostgreSQL cluster = $5,000
    - Session state: Redis cluster = $10,000
    - Total storage: $15,069/month
  
  AI/ML Services:
    - Noise cancellation: Custom models on GPU
    - Background blur: Real-time image processing
    - Auto-transcription: Speech-to-text API
    - Compute: 200 × p3.xlarge × $2.362 × 730 = $344,852
  
  Total Monthly Cost: $11,585,369 (~$139M annually)

Quality Optimization:
  Adaptive Streaming:
    - Network condition monitoring (RTT, packet loss, jitter)
    - Dynamic bitrate adjustment (500 Kbps to 3 Mbps)
    - Resolution scaling (180p to 1080p)
    - Frame rate adaptation (15 FPS to 30 FPS)
  
  Latency Optimization:
    - Media server selection: <50ms from user
    - UDP with custom reliability protocol
    - Jitter buffer: 20-200ms adaptive
    - Forward Error Correction (FEC) for packet loss
  
  CPU Optimization:
    - Hardware acceleration: Intel Quick Sync, NVIDIA NVENC
    - SIMD instructions: AVX2, AVX-512 for audio processing
    - Multi-threading: Parallel transcoding pipelines
    - Memory optimization: Zero-copy networking
```

## Serverless vs Container vs VM Decision Matrix

### Workload Classification Framework
```yaml
Decision Tree Based on Workload Characteristics:

Execution Duration:
  < 15 minutes:
    - Lambda: $0.0000166667 per GB-second
    - Use case: API backends, data processing, webhooks
    - Max memory: 10GB, Max duration: 15 minutes
    - Cold start: 100ms-5 seconds
  
  15 minutes - 24 hours:
    - Fargate: $0.04048 per vCPU-hour + $0.004445 per GB-hour
    - Use case: Batch jobs, ETL, CI/CD pipelines
    - No server management, pay per use
    - Scaling: 0 to thousands of tasks
  
  > 24 hours:
    - EC2: Starting at $0.0116 per hour (t3.nano)
    - Use case: Long-running services, databases, caches
    - Full control, persistent storage
    - Reserved instances: Up to 72% savings

Traffic Patterns:
  Unpredictable/Spiky:
    - Serverless (Lambda + API Gateway)
    - Auto-scaling from 0 to thousands
    - Pay only for actual usage
    - Example: Startup with viral potential
  
  Predictable/Steady:
    - Containers (ECS/EKS) with auto-scaling
    - Reserved capacity for baseline
    - Spot instances for additional capacity
    - Example: Established SaaS platform
  
  Always-on/High utilization:
    - EC2 with Reserved Instances
    - Dedicated hosts for licensing
    - Savings Plans for flexibility
    - Example: Core business applications

Cost Comparison Example (1M requests/month):
  Scenario 1: Lightweight API (128MB, 100ms execution)
    - Lambda: 1M × 0.1s × 0.125GB × $0.0000166667 = $208
    - Fargate: 1 task × 0.25 vCPU × 730h × $0.04048 = $74
    - EC2: t3.micro × $0.0116 × 730 = $8.47
    - Winner: EC2 (if >95% utilization)
  
  Scenario 2: Heavy processing (3GB, 5 minutes)
    - Lambda: 1M × 300s × 3GB × $0.0000166667 = $15,000
    - Fargate: 100 tasks × 1 vCPU × 50h × $0.04048 = $202
    - EC2: c5.xlarge × $0.17 × 730 = $124
    - Winner: EC2 with auto-scaling
  
  Scenario 3: Sporadic usage (1GB, 30 seconds, 1K requests/month)
    - Lambda: 1K × 30s × 1GB × $0.0000166667 = $0.50
    - Fargate: Minimum 1 task-hour = $0.04048
    - EC2: Minimum 1 hour = $0.17
    - Winner: Lambda (low usage)
```

## Auto-Scaling Strategies and Calculations

### Predictive Scaling Implementation
```yaml
E-commerce Platform Auto-Scaling:
  Business Pattern Analysis:
    - Normal traffic: 1,000 QPS
    - Flash sale traffic: 50,000 QPS (50x spike)
    - Black Friday: 100,000 QPS (100x spike)
    - Seasonal variation: 3x during holidays
  
  Scaling Metrics:
    - CPU utilization target: 70%
    - Response time target: <200ms
    - Error rate threshold: <1%
    - Queue depth: <100 messages
  
  Scaling Configuration:
    - Scale-out trigger: CPU >70% for 2 minutes
    - Scale-in trigger: CPU <30% for 10 minutes
    - Cooldown period: 5 minutes
    - Max instances: 500 (cost protection)
  
  Instance Sizing:
    - Baseline: 10 × c5.large (20 vCPUs, 40GB RAM)
    - Normal peak: 30 × c5.large (60 vCPUs, 120GB RAM)
    - Flash sale: 200 × c5.large (400 vCPUs, 800GB RAM)
    - Black Friday: 500 × c5.large (1,000 vCPUs, 2TB RAM)

Cost Analysis:
  Reserved Instance Strategy:
    - Baseline capacity: 10 × c5.large RI (3-year) = $0.049/hour
    - Cost: 10 × $0.049 × 8,760 = $4,292/year
    - Savings vs on-demand: 60%
  
  Auto-scaling Cost:
    - Additional capacity: 0-490 instances on-demand
    - Average utilization: 50 instances (seasonal average)
    - Cost: 50 × $0.085 × 8,760 = $37,230/year
  
  Spot Instance Integration:
    - 70% of auto-scaling capacity on Spot
    - Spot price: $0.025/hour (70% savings)
    - Diversified across 3 AZs and 4 instance types
    - Cost: 35 × $0.025 × 8,760 = $7,665/year
    - On-demand backup: 15 × $0.085 × 8,760 = $11,169/year
  
  Total Annual Compute Cost:
    - Reserved instances: $4,292
    - Spot instances: $7,665
    - On-demand backup: $11,169
    - Total: $23,126/year (vs $74,460 all on-demand)
    - Savings: 69%

Performance Optimization:
  Warm-up Strategy:
    - Pre-scale 30 minutes before known events
    - Gradual scale-up: 25% capacity every 2 minutes
    - Health check optimization: 15-second intervals
    - Connection pre-warming: Establish DB connections
  
  Multi-AZ Scaling:
    - Distribute load across 3 AZs
    - AZ failure handling: Redistribute to healthy AZs
    - Cross-AZ latency: <2ms impact
    - Network cost: $0.01/GB between AZs
```

## Container Orchestration Cost Analysis

### EKS vs ECS vs Fargate Comparison
```yaml
Microservices Platform (20 services, 100 containers):

EKS (Kubernetes):
  Control Plane: $0.10/hour × 24 × 30 = $72/month
  Worker Nodes: 10 × m5.large × $0.096 × 730 = $700.80/month
  Add-ons (ALB controller, cluster autoscaler): $50/month
  Operational overhead: 40 hours/month × $100/hour = $4,000/month
  Total: $4,822.80/month
  
  Pros:
    - Full Kubernetes ecosystem
    - Multi-cloud portability
    - Advanced scheduling and networking
    - Large community and tooling
  
  Cons:
    - High operational complexity
    - Steep learning curve
    - Significant management overhead

ECS (Elastic Container Service):
  Control Plane: Free
  EC2 instances: 8 × m5.large × $0.096 × 730 = $560.64/month
  Application Load Balancer: $16.20/month
  Operational overhead: 20 hours/month × $100/hour = $2,000/month
  Total: $2,576.84/month
  
  Pros:
    - AWS native integration
    - Simpler than Kubernetes
    - No control plane costs
    - Good AWS tooling integration
  
  Cons:
    - AWS vendor lock-in
    - Less flexible than Kubernetes
    - Smaller ecosystem

Fargate (Serverless containers):
  Compute: 100 containers × 0.5 vCPU × 730h × $0.04048 = $1,477.52/month
  Memory: 100 containers × 1GB × 730h × $0.004445 = $324.49/month
  Application Load Balancer: $16.20/month
  Operational overhead: 5 hours/month × $100/hour = $500/month
  Total: $2,318.21/month
  
  Pros:
    - No server management
    - Pay per use
    - Automatic scaling
    - Reduced operational overhead
  
  Cons:
    - Higher per-hour cost
    - Less control over infrastructure
    - Cold start latency

Decision Matrix:
  Team Size < 5: Fargate (lowest operational overhead)
  Team Size 5-20: ECS (balance of control and simplicity)
  Team Size > 20: EKS (full Kubernetes benefits justify complexity)
  
  Workload Characteristics:
    - Batch/sporadic: Fargate (pay per use)
    - Steady state: ECS on EC2 (cost optimization)
    - Complex networking: EKS (advanced features)
    - Multi-cloud: EKS (portability)
```
