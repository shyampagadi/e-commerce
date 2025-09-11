# Module 02 Knowledge Check

## Multiple Choice Questions

### Question 1: Load Balancer Selection
Which AWS service is best for ultra-low latency TCP traffic?
a) Application Load Balancer (ALB)
b) Network Load Balancer (NLB)
c) CloudFront
d) API Gateway

**Answer**: b) Network Load Balancer (NLB)

### Question 2: CDN Performance
What is the primary benefit of CloudFront edge locations?
a) Reduced compute costs
b) Improved security
c) Reduced latency
d) Increased storage capacity

**Answer**: c) Reduced latency

### Question 3: DNS Routing
Which Route 53 routing policy routes traffic to the lowest latency endpoint?
a) Weighted routing
b) Latency-based routing
c) Geolocation routing
d) Failover routing

**Answer**: b) Latency-based routing

## Short Answer Questions

### Question 4: Cache Strategy
Explain the difference between TTL settings for static vs dynamic content in CloudFront.

**Expected Answer**: Static content (images, CSS, JS) should have longer TTL (3600s+) as it changes infrequently. Dynamic content (API responses, personalized data) should have shorter TTL (300s or less) to ensure freshness.

### Question 5: Network Performance
List three key metrics for measuring network performance and their target values.

**Expected Answer**: 
- Latency: <100ms for regional, <200ms for global
- Throughput: Match application requirements
- Availability: 99.99% with proper redundancy

## Practical Questions

### Question 6: Architecture Design
Design a network architecture for a global e-commerce site with the following requirements:
- Serve customers in US, Europe, and Asia
- Handle 50,000 concurrent users
- 99.99% availability requirement

**Evaluation Criteria**:
- Multi-region deployment strategy
- Appropriate load balancing choices
- CDN configuration for static/dynamic content
- DNS routing strategy
- Monitoring and alerting setup
