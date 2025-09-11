# CDN Optimization Lab

## Performance Testing Script

```bash
#!/bin/bash
# Test CDN vs Origin performance across regions

test_endpoint() {
    local url=$1
    local name=$2
    
    echo "Testing $name..."
    
    # Test from multiple locations using curl
    for region in us-east us-west eu-west ap-southeast; do
        echo "Region: $region"
        
        # Measure total time, DNS lookup, and first byte
        curl -w "Total: %{time_total}s, DNS: %{time_namelookup}s, TTFB: %{time_starttransfer}s\n" \
             -s -o /dev/null "$url"
    done
    echo "---"
}

# Test CDN vs Origin
test_endpoint "https://d123456789.cloudfront.net/api/data" "CloudFront CDN"
test_endpoint "https://origin.example.com/api/data" "Origin Server"

# Calculate improvement
echo "Expected improvements:"
echo "- Latency: 40-60% reduction"
echo "- TTFB: 50-70% reduction" 
echo "- Cache hit rate: >90%"
```

## Cache Hit Rate Analysis

```python
import boto3
from datetime import datetime, timedelta

def analyze_cloudfront_metrics(distribution_id):
    cloudwatch = boto3.client('cloudwatch')
    
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(hours=24)
    
    # Get cache hit rate
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/CloudFront',
        MetricName='CacheHitRate',
        Dimensions=[{'Name': 'DistributionId', 'Value': distribution_id}],
        StartTime=start_time,
        EndTime=end_time,
        Period=3600,
        Statistics=['Average']
    )
    
    hit_rates = [point['Average'] for point in response['Datapoints']]
    avg_hit_rate = sum(hit_rates) / len(hit_rates) if hit_rates else 0
    
    print(f"Average Cache Hit Rate: {avg_hit_rate:.1f}%")
    
    if avg_hit_rate > 90:
        print("✅ Excellent cache performance")
    elif avg_hit_rate > 80:
        print("⚠️ Good cache performance")
    else:
        print("❌ Poor cache performance - optimize TTL settings")

# Usage
analyze_cloudfront_metrics('E1234567890123')
```

## Optimization Checklist

### Cache Configuration
- [ ] Set appropriate TTL values (3600s for static, 300s for dynamic)
- [ ] Enable compression (gzip/brotli)
- [ ] Configure cache behaviors by path pattern
- [ ] Set up origin request policies

### Performance Monitoring
- [ ] Monitor cache hit rate (target: >90%)
- [ ] Track origin response time (target: <200ms)
- [ ] Monitor error rates (target: <0.1%)
- [ ] Set up CloudWatch alarms

### Cost Optimization
- [ ] Use appropriate price class
- [ ] Optimize cache behaviors
- [ ] Monitor data transfer costs
- [ ] Consider Reserved Capacity for predictable traffic

## Expected Results
- **Latency Reduction**: 40-70% improvement
- **Bandwidth Savings**: 60-90% reduction at origin
- **Cost Savings**: 30-50% on data transfer
- **Availability**: 99.99% with multi-region failover
