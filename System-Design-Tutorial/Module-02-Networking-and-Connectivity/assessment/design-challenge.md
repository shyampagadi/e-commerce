# Module 02 Design Challenge

## Challenge: Global Video Streaming Platform

### Scenario
You are the lead architect for a new video streaming platform that needs to serve 10 million users globally with high-quality video content.

### Requirements
- **Global Scale**: Users in North America, Europe, Asia, and South America
- **Performance**: Video startup time <2 seconds, no buffering during playback
- **Quality**: Adaptive bitrate streaming (240p to 4K)
- **Availability**: 99.99% uptime with regional failover
- **Cost**: Optimize for content delivery costs

### Constraints
- Budget: $500K/month for networking infrastructure
- Compliance: GDPR in Europe, data residency requirements
- Peak Traffic: 5x normal load during major events
- Content: 100TB of video content, growing 10TB/month

### Deliverables

#### 1. Network Architecture Design (40 points)
- Global topology diagram
- CDN strategy and edge locations
- Load balancing approach
- DNS routing configuration

#### 2. Performance Optimization (25 points)
- Caching strategy for video content
- Adaptive bitrate delivery mechanism
- Network performance monitoring
- Latency optimization techniques

#### 3. Scalability Plan (20 points)
- Auto-scaling configuration
- Peak traffic handling strategy
- Regional expansion plan
- Capacity planning methodology

#### 4. Cost Analysis (15 points)
- Monthly cost breakdown
- Cost optimization strategies
- ROI analysis for CDN investment
- Budget allocation across regions

### Evaluation Criteria

#### Technical Design (60%)
- Architecture appropriateness for video streaming
- Proper use of AWS networking services
- Scalability and performance considerations
- Security and compliance integration

#### Implementation Feasibility (25%)
- Realistic deployment timeline
- Resource requirements assessment
- Risk mitigation strategies
- Operational complexity management

#### Cost Effectiveness (15%)
- Budget adherence
- Cost optimization strategies
- Value engineering decisions
- Long-term financial sustainability

### Submission Format
- Architecture diagrams (draw.io or similar)
- Technical documentation (10-15 pages)
- Cost analysis spreadsheet
- Implementation timeline
- 30-minute presentation

### Success Metrics
- Video startup time <2 seconds globally
- 99.99% availability across all regions
- <$0.10/GB content delivery cost
- Support for 50,000 concurrent streams per region
