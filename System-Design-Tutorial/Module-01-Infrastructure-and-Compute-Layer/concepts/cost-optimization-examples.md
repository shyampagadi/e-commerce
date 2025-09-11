# Cost Optimization Examples

## Real-World Cost Scenarios

### Scenario 1: E-commerce Platform
**Workload**: 10,000 daily active users, peak traffic 8PM-10PM

#### Option A: Always-On EC2
```
- 4x m5.large instances (24/7)
- Monthly cost: $278.40
- Utilization: 30% average
- Waste: $194.88/month
```

#### Option B: Auto Scaling + Spot
```
- 1x m5.large (baseline) + 3x spot instances (peak)
- Monthly cost: $89.60 + $41.76 = $131.36
- Savings: 53% ($147.04/month)
```

#### Option C: Serverless (Lambda + API Gateway)
```
- 2M requests/month, 500ms avg duration
- Lambda: $8.35
- API Gateway: $7.00
- Total: $15.35
- Savings: 94% ($263.05/month)
```

### Scenario 2: Data Processing Pipeline
**Workload**: Daily batch processing, 4-hour window

#### Traditional Approach
```
- c5.4xlarge running 24/7
- Monthly cost: $497.66
- Actual usage: 4 hours/day (17% utilization)
```

#### Optimized Approach
```
- Spot instances for batch jobs
- c5.4xlarge spot (4 hours/day)
- Monthly cost: $82.94
- Savings: 83% ($414.72/month)
```

## Cost Decision Matrix

| Workload Pattern | EC2 On-Demand | EC2 Reserved | Spot Instances | Lambda | Fargate |
|------------------|---------------|--------------|----------------|--------|---------|
| **Predictable 24/7** | ❌ Expensive | ✅ Best | ❌ Unreliable | ❌ Costly | ⚠️ Medium |
| **Variable traffic** | ⚠️ Medium | ❌ Wasteful | ✅ Good | ✅ Best | ✅ Good |
| **Batch processing** | ❌ Wasteful | ❌ Wasteful | ✅ Best | ⚠️ Limited | ✅ Good |
| **Event-driven** | ❌ Wasteful | ❌ Wasteful | ❌ Complex | ✅ Best | ⚠️ Medium |

## Hands-On Cost Calculator

### Interactive Pricing Tool
```bash
# Install cost calculator
pip install aws-cost-calculator

# Calculate scenario costs
aws-cost-calc --service ec2 --instance-type m5.large --hours 720
aws-cost-calc --service lambda --requests 1000000 --duration 500
```

### Cost Optimization Checklist
- [ ] Right-size instances based on actual usage
- [ ] Use Reserved Instances for predictable workloads
- [ ] Implement Auto Scaling for variable traffic
- [ ] Consider Spot Instances for fault-tolerant workloads
- [ ] Evaluate serverless for event-driven patterns
- [ ] Set up billing alerts and budgets
- [ ] Regular cost reviews and optimization
