# Load Balancer Selection Decision Matrix

## Decision Framework

| Use Case | ALB | NLB | CloudFront | API Gateway |
|----------|-----|-----|------------|-------------|
| **HTTP/HTTPS traffic** | ✅ Excellent | ❌ No | ✅ Excellent | ✅ Excellent |
| **TCP/UDP traffic** | ❌ No | ✅ Excellent | ❌ No | ❌ No |
| **Global distribution** | ❌ Regional | ❌ Regional | ✅ Excellent | ❌ Regional |
| **SSL termination** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Content caching** | ❌ No | ❌ No | ✅ Excellent | ✅ Yes |
| **Authentication** | ❌ No | ❌ No | ❌ No | ✅ Multiple |

## Selection Criteria

### Choose ALB when:
- HTTP/HTTPS applications
- Advanced routing rules needed
- Integration with AWS services
- Cost-effective for moderate traffic

### Choose NLB when:
- TCP/UDP protocols required
- Ultra-low latency needed
- High throughput requirements
- Static IP addresses required

### Choose CloudFront when:
- Global content delivery
- Static/dynamic content caching
- DDoS protection needed
- Edge computing requirements

### Choose API Gateway when:
- REST/GraphQL APIs
- Authentication/authorization needed
- Request/response transformation
- API versioning and management

## Cost Comparison (Monthly)
- **ALB**: $16.20 base + $0.008/LCU-hour
- **NLB**: $16.20 base + $0.006/LCU-hour  
- **CloudFront**: $0.085/GB + $0.0075/10k requests
- **API Gateway**: $3.50/million requests
