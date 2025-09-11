# Exercise 1 Solution: Network Latency Analysis

## Implementation

```python
import requests
import time
import statistics

def test_latency(url, iterations=100):
    latencies = []
    for _ in range(iterations):
        start = time.time()
        try:
            requests.get(url, timeout=10)
            latencies.append((time.time() - start) * 1000)
        except:
            continue
    
    return {
        'avg_ms': statistics.mean(latencies),
        'p95_ms': statistics.quantiles(latencies, n=20)[18],
        'p99_ms': statistics.quantiles(latencies, n=100)[98]
    }

# Test endpoints
endpoints = {
    'ALB': 'https://alb.example.com/health',
    'NLB': 'https://nlb.example.com/health', 
    'CloudFront': 'https://d123.cloudfront.net/health'
}

results = {}
for name, url in endpoints.items():
    results[name] = test_latency(url)
    print(f"{name}: {results[name]['avg_ms']:.1f}ms avg")
```

## Expected Results
- **ALB**: 50-80ms average latency
- **NLB**: 30-50ms average latency  
- **CloudFront**: 20-40ms average latency

## Analysis
CloudFront shows lowest latency due to edge locations closer to users.
