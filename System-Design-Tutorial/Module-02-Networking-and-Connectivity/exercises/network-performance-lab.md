# Network Performance Testing Lab

## Latency Testing

```python
import requests
import time
import statistics

def test_latency(url, iterations=100):
    latencies = []
    for _ in range(iterations):
        start = time.time()
        requests.get(url, timeout=10)
        latencies.append((time.time() - start) * 1000)
    
    return {
        'avg_ms': statistics.mean(latencies),
        'p95_ms': statistics.quantiles(latencies, n=20)[18],
        'p99_ms': statistics.quantiles(latencies, n=100)[98]
    }

# Test ALB vs NLB vs Direct
results = {
    'ALB': test_latency('https://alb.example.com/health'),
    'NLB': test_latency('https://nlb.example.com/health'),
    'Direct': test_latency('https://direct.example.com/health')
}

for lb_type, metrics in results.items():
    print(f"{lb_type}: {metrics['avg_ms']:.1f}ms avg, {metrics['p95_ms']:.1f}ms p95")
```

## CDN Performance Analysis

```bash
#!/bin/bash
# Test CDN vs Origin performance
echo "Testing CDN Performance..."

# CDN endpoint
cdn_time=$(curl -w "%{time_total}" -s -o /dev/null https://d123.cloudfront.net/api/data)

# Origin endpoint  
origin_time=$(curl -w "%{time_total}" -s -o /dev/null https://origin.example.com/api/data)

# Calculate improvement
improvement=$(echo "scale=1; ($origin_time - $cdn_time) / $origin_time * 100" | bc)

echo "CDN: ${cdn_time}s"
echo "Origin: ${origin_time}s" 
echo "Improvement: ${improvement}%"
```

## Key Metrics
- **Target Latency**: < 100ms regional, < 200ms global
- **CDN Hit Rate**: > 90%
- **Availability**: 99.99% with multi-AZ
