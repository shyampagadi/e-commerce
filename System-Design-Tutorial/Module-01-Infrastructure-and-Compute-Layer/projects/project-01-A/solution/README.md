# Project 01-A Solution: Compute Resource Planning

## Solution Overview

This solution demonstrates how to design server sizing for scalable web application components and create capacity planning models for different traffic patterns.

## 1. Web Application Components Analysis

### Component Breakdown
```
┌─────────────────────────────────────────────────────────────┐
│                WEB APPLICATION COMPONENTS                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   Web       │    │ Application │    │   Database      │  │
│  │   Tier      │    │   Tier      │    │   Tier          │  │
│  │             │    │             │    │                 │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Load     │ │    │ │Business │ │    │ │Primary      │ │  │
│  │ │Balancer │ │    │ │Logic    │ │    │ │Database     │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────────┐ │  │
│  │ │Web      │ │    │ │API      │ │    │ │Read         │ │  │
│  │ │Servers  │ │    │ │Gateway  │ │    │ │Replicas     │ │  │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────────┘ │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Resource Requirements

#### Web Tier
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **Count**: 3 instances (min), 10 instances (max)
- **Storage**: 20 GB EBS gp3
- **Network**: 1 Gbps

#### Application Tier
- **Instance Type**: t3.large (2 vCPU, 8 GB RAM)
- **Count**: 2 instances (min), 8 instances (max)
- **Storage**: 50 GB EBS gp3
- **Network**: 1 Gbps

#### Database Tier
- **Instance Type**: r5.large (2 vCPU, 16 GB RAM)
- **Count**: 1 primary, 2 read replicas
- **Storage**: 100 GB EBS gp3
- **Network**: 1 Gbps

## 2. Capacity Planning Models

### Traffic Pattern Analysis

#### Normal Load (1000 requests/minute)
- **Web Tier**: 2 instances (t3.medium)
- **Application Tier**: 2 instances (t3.large)
- **Database Tier**: 1 primary + 1 read replica
- **Total Cost**: ~$200/month

#### Peak Load (5000 requests/minute)
- **Web Tier**: 6 instances (t3.medium)
- **Application Tier**: 4 instances (t3.large)
- **Database Tier**: 1 primary + 2 read replicas
- **Total Cost**: ~$400/month

#### Growth Projection (20% annual)
- **Year 1**: 1200 requests/minute average
- **Year 2**: 1440 requests/minute average
- **Year 3**: 1728 requests/minute average

### Scaling Calculations

#### CPU Utilization
```
CPU Utilization = (Requests per second × Processing time per request) / (Number of instances × CPU cores per instance)

Normal Load:
CPU = (1000/60 × 0.1) / (2 × 2) = 0.42 (42%)

Peak Load:
CPU = (5000/60 × 0.1) / (6 × 2) = 0.69 (69%)
```

#### Memory Utilization
```
Memory Utilization = (Memory per request × Concurrent requests) / (Total memory per instance)

Normal Load:
Memory = (10 MB × 50) / (4 GB) = 0.125 (12.5%)

Peak Load:
Memory = (10 MB × 200) / (4 GB) = 0.5 (50%)
```

## 3. Auto-scaling Configuration

### Auto Scaling Groups

#### Web Tier ASG
```yaml
WebTierASG:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    MinSize: 2
    MaxSize: 10
    DesiredCapacity: 3
    LaunchTemplate:
      LaunchTemplateId: !Ref WebLaunchTemplate
      Version: !GetAtt WebLaunchTemplate.LatestVersionNumber
    TargetGroupARNs:
      - !Ref WebTargetGroup
    ScalingPolicies:
      - PolicyName: ScaleUpPolicy
        AdjustmentType: ChangeInCapacity
        ScalingAdjustment: 2
        Cooldown: 300
      - PolicyName: ScaleDownPolicy
        AdjustmentType: ChangeInCapacity
        ScalingAdjustment: -1
        Cooldown: 300
```

#### Application Tier ASG
```yaml
AppTierASG:
  Type: AWS::AutoScaling::AutoScalingGroup
  Properties:
    MinSize: 2
    MaxSize: 8
    DesiredCapacity: 2
    LaunchTemplate:
      LaunchTemplateId: !Ref AppLaunchTemplate
      Version: !GetAtt AppLaunchTemplate.LatestVersionNumber
    TargetGroupARNs:
      - !Ref AppTargetGroup
```

### CloudWatch Alarms

#### CPU Utilization Alarm
```yaml
CPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: HighCPUUtilization
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 70
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref ScaleUpPolicy
```

## 4. Cost Optimization

### Reserved Instances
- **Web Tier**: 2 t3.medium Reserved Instances (1-year)
- **Application Tier**: 2 t3.large Reserved Instances (1-year)
- **Database Tier**: 1 r5.large Reserved Instance (1-year)
- **Savings**: ~30% cost reduction

### Spot Instances
- **Web Tier**: 50% Spot Instances for non-critical workloads
- **Application Tier**: 25% Spot Instances for batch processing
- **Savings**: ~60% cost reduction for Spot Instances

### Cost Breakdown
```
Monthly Costs:
- Web Tier (3 t3.medium): $90
- Application Tier (2 t3.large): $120
- Database Tier (1 r5.large + 1 read replica): $200
- Load Balancer: $20
- Storage: $30
- Data Transfer: $20
- Total: $480/month
```

## 5. Performance Benchmarks

### Response Time Targets
- **Web Tier**: <100ms average
- **Application Tier**: <200ms average
- **Database Tier**: <50ms average
- **End-to-End**: <500ms average

### Throughput Targets
- **Normal Load**: 1000 requests/minute
- **Peak Load**: 5000 requests/minute
- **Burst Capacity**: 10000 requests/minute (5 minutes)

### Availability Targets
- **Web Tier**: 99.9% availability
- **Application Tier**: 99.9% availability
- **Database Tier**: 99.99% availability
- **Overall**: 99.9% availability

## 6. Monitoring and Alerting

### Key Metrics
- **CPU Utilization**: Target <70%
- **Memory Utilization**: Target <80%
- **Disk Utilization**: Target <80%
- **Network Utilization**: Target <70%
- **Response Time**: Target <500ms
- **Error Rate**: Target <1%

### Alerting Thresholds
- **Critical**: CPU >90%, Memory >95%, Error Rate >5%
- **Warning**: CPU >70%, Memory >80%, Response Time >1s
- **Info**: Scaling events, deployment status

## 7. Implementation Plan

### Phase 1: Basic Setup (Week 1)
1. Launch EC2 instances
2. Configure security groups
3. Deploy application
4. Set up basic monitoring

### Phase 2: Auto Scaling (Week 2)
1. Create Auto Scaling Groups
2. Configure scaling policies
3. Set up CloudWatch alarms
4. Test scaling behavior

### Phase 3: Optimization (Week 3)
1. Implement Reserved Instances
2. Add Spot Instances
3. Optimize instance types
4. Fine-tune scaling policies

### Phase 4: Monitoring (Week 4)
1. Set up comprehensive monitoring
2. Configure alerting
3. Create dashboards
4. Document procedures

## 8. Success Criteria

### Performance
- ✅ Response time <500ms
- ✅ Throughput 5000 requests/minute
- ✅ Availability 99.9%

### Cost
- ✅ Monthly cost <$500
- ✅ Cost per request <$0.01
- ✅ 30% savings with Reserved Instances

### Scalability
- ✅ Auto-scaling working correctly
- ✅ Can handle 10x traffic spikes
- ✅ Recovery time <5 minutes

