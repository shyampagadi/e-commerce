# Auto Scaling Groups

## Overview

Auto Scaling Groups (ASG) automatically launch and terminate EC2 instances based on demand. This ensures optimal performance and cost efficiency by maintaining the right number of instances.

## Key Features

### 1. Automatic Scaling
- **Scale Out**: Add instances when demand increases
- **Scale In**: Remove instances when demand decreases
- **Health Checks**: Replace unhealthy instances
- **Multiple AZs**: Distribute instances across availability zones

### 2. Scaling Policies
- **Target Tracking**: Maintain target metrics
- **Step Scaling**: Scale in predefined steps
- **Simple Scaling**: Basic scaling rules
- **Scheduled Scaling**: Time-based scaling

### 3. Launch Templates
- **Instance Configuration**: Define instance specifications
- **Security Groups**: Configure network security
- **IAM Roles**: Set up permissions
- **User Data**: Configure instances on launch

## Configuration Example

```yaml
Resources:
  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      MinSize: 2
      MaxSize: 10
      DesiredCapacity: 4
      VPCZoneIdentifier:
        - !Ref Subnet1
        - !Ref Subnet2
      TargetGroupARNs:
        - !Ref TargetGroup
      HealthCheckType: ELB
      HealthCheckGracePeriod: 300
      Tags:
        - Key: Name
          Value: WebServer
          PropagateAtLaunch: true
```

## Best Practices

### 1. Scaling Configuration
- **Appropriate Limits**: Set realistic min/max values
- **Gradual Scaling**: Use cooldown periods
- **Health Checks**: Implement proper health checks
- **Multiple Metrics**: Use multiple scaling metrics

### 2. Cost Optimization
- **Spot Instances**: Use spot instances for fault-tolerant workloads
- **Reserved Instances**: Use reserved instances for predictable workloads
- **Right-sizing**: Choose appropriate instance types
- **Regular Review**: Review scaling policies regularly

